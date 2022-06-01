package main

import "core:os"
import "core:fmt"
import "core:mem"
import "core:slice"
import "core:runtime"
import "core:strings"
import "core:thread"

import "curl"

track_allocations :: proc(code: proc()) {
    tracking_allocator: mem.Tracking_Allocator
    mem.tracking_allocator_init(&tracking_allocator, context.allocator)
    context.allocator = mem.tracking_allocator(&tracking_allocator)

    code()

    for key, value in tracking_allocator.allocation_map {
        fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
    }

    mem.tracking_allocator_destroy(&tracking_allocator)
}

main :: proc() {
    track_allocations(entry_point)
}

entry_point :: proc() {
    if s, ok := fetch("https://www.google.com"); ok {
        if os.write_entire_file("page.html", transmute([]byte)s) {
            fmt.println("File written successfully")
        }
    } else {
        fmt.println("Failed to fetch page")
    }
}

fetch :: proc(url: string) -> (string, bool) {
    handle := curl.easy_init()
    defer curl.easy_cleanup(handle)

    data := [dynamic]byte{}
    write_callback :: proc "c" (chunk: rawptr, size, count: uint, data: ^[dynamic]byte) -> uint {
        context = runtime.default_context()
        byte_count := size * count
        s := slice.bytes_from_ptr(chunk, int(byte_count))
        append(data, ..s[:])
        return byte_count
    }

    if curl.E_OK != curl.easy_setopt(handle, curl.OPT_URL, url) {
        return "", false
    }
    if curl.E_OK != curl.easy_setopt(handle, curl.OPT_WRITEFUNCTION, write_callback) {
        return "", false
    }
    if curl.E_OK != curl.easy_setopt(handle, curl.OPT_WRITEDATA, &data) {
        return "", false
    }
    if curl.E_OK != curl.easy_perform(handle) {
        return "", false
    }

    return string(data[:]), true
}

FETCH_THREAD_COUNT :: 16
pool: thread.Pool
easy_handle_table :: [FETCH_THREAD_COUNT]rawptr

async_fetch_init :: proc() {
    thread.pool_init(&pool, context.allocator, FETCH_THREAD_COUNT)
}

async_fetch_destroy :: proc() {
    thread.pool_destroy(&pool)
}

async_fetch :: proc(url: string, cb: proc(string, bool)) {
    task :: proc(t: thread.Task) {
        index := t.user_index % len(easy_handle_table)
        // for iteration in 1..=5 {
        //     for !did_acquire(&print_mutex) { thread.yield() } // Allow one thread to print at a time.

        //     fmt.printf("Worker Task %d is on iteration %d\n", t.user_index, iteration)
        //     fmt.printf("`%s`: iteration %d\n", easy_handle_table[index], iteration)

        //     print_mutex = false

        //     time.sleep(1 * time.Millisecond)
        // }
    }

    thread.pool_add_task(pool=&pool, procedure=task_proc, data=nil, user_index=i, allocator=context.allocator)

    thread.pool_start(&pool)
}