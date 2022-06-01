package main

import "core:os"
import "core:fmt"
import "core:mem"
import "core:slice"
import "core:runtime"
import "core:strings"
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
    s := fetch("https://www.google.com")
    if os.write_entire_file("page.html", transmute([]byte)s) {
        fmt.println("File written successfully")
    }
}

fetch :: proc(url: string) -> string {
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
        return ""
    }
    if curl.E_OK != curl.easy_setopt(handle, curl.OPT_WRITEFUNCTION, write_callback) {
        return ""
    }
    if curl.E_OK != curl.easy_setopt(handle, curl.OPT_WRITEDATA, &data) {
        return ""
    }
    if curl.E_OK != curl.easy_perform(handle) {
        return ""
    }

    return string(data[:])
}