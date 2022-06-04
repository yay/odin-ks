package main

import "core:fmt"
import "core:thread"
import "core:time"
import "core:runtime"
import "core:sys/darwin"
import "core:strings"
import "core:os"
import "core:c"
import "core:math"
import "core:testing"

width :: 640
height :: 480

main :: proc() {
    render(proc(x, y: int) -> Color {
        return Color{
            r = f32(x) / f32(width - 1),
            g = f32(y) / f32(height - 1),
            b = f32(0.25),
        }
    })
}

Color :: struct {
    r, g, b: f32,
}

Work :: struct {
    m: ^[width][height]Color,
    x1, y1, x2, y2: int,
    init: proc(int, int) -> Color,
}

render :: proc(init: proc(int, int) -> Color) {
    m := &[width][height]Color{}

    chunks := 10
    bandwidth := int(math.floor(f64(width) / f64(chunks)))

    pool: thread.Pool
    thread.pool_init(&pool, context.allocator, chunks)
    defer thread.pool_destroy(&pool)

    k := chunks - 1
    for i in 0..<chunks {
        x1 := i * bandwidth
        work := new_clone(Work{
            m = m,
            x1 = x1,
            y1 = 0,
            x2 = i == k ? width : x1 + bandwidth,
            y2 = height,
            init = init,
        })
        thread.pool_add_task(&pool, context.allocator, fill_region, work, i)
    }

    thread.pool_start(&pool)
    thread.pool_finish(&pool)

    save_ppm(m)
}

save_ppm :: proc(m: ^[width][height]Color) {
    f, err := os.open("out.ppm", os.O_CREATE | os.O_WRONLY, 0o0777)
    if err != os.ERROR_NONE {
        fmt.print("Failed to open file:", err)
        return
    }
    defer os.close(f)

    fmt.fprintf(f, "P3\n%d %d\n255\n", width, height)
    for y in 0..<height {
        for x in 0..<width {
            c := m[x][y]
            fmt.fprintf(f, "%d %d %d\n", int(math.floor(c.r * 255)), int(math.floor(c.g * 255)), int(math.floor(c.b * 255)))
        }
    }
}

fill_region :: proc(t: thread.Task) {
    work := (^Work)(t.data)
    using work
    for x in x1..<x2 {
        for y in y1..<y2 {
            m[x][y] = init(x, y)
        }
    }
    free(work)
}

CTL_HW :: 6  // generic cpu/io
HW_NCPU :: 3 // number of cpus

get_darwin_ncpu :: proc() -> int {
    mib := [2]i32{CTL_HW, HW_NCPU}
	out := u32(0)
	nout := i64(size_of(out))
	ret := darwin.syscall_sysctl(&mib[0], 2, &out, &nout, nil, 0)
	if ret >= 0 && int(out) > 0 {
		return int(out)
	}
	return 1
}

@test
test_me :: proc(^testing.T) {
    assert(get_darwin_ncpu() == 10) // Apple M1 Pro
}

prefix_table := [?]string{"White", "Red", "Green", "Blue", "Octarine", "Black"}

basic_threads :: proc() {
	fmt.println("Basic Threads\n")

	worker := proc(t: ^thread.Thread) {
		for iteration in 1 ..= 5 {
			fmt.printf("Thread %d: %d\n", t.id, iteration)
            fmt.printf("`%s`: iteration %d\n", prefix_table[t.user_index], iteration)
			time.sleep(1 * time.Millisecond)
		}
	}

    threads := make([dynamic]^thread.Thread, 0, len(prefix_table))
    defer delete(threads)

    for in prefix_table {
        if t := thread.create(worker); t != nil {
            t.init_context = context // Maybe(runtime.Context)
            t.user_index = len(threads)
            append(&threads, t)
            thread.start(t)
        }
    }

    // counter := 0
    // for len(threads) > 0 {
    //     counter += 1
    //     for i := 0; i < len(threads); {
    //         if t := threads[i]; thread.is_done(t) {
    //             fmt.printf("Thread %d is done\n", t.user_index)
    //             thread.destroy(t)
    //             ordered_remove(&threads, i)
    //         } else {
    //             i += 1
    //         }
    //     }
    // }
    // fmt.println("Counter:", counter) // 77567

    for t in threads {
        thread.join(t)
    }
    for t in threads {
        fmt.println("Thread", t.user_index, "is done:", thread.is_done(t))
    }
}

// @thread_local is the same as @static but thread local.

// Thread local storage is supported at the file scope:
// @(thread_local="default") or @thread_local
// @(thread_local="localdynamic")
// @(thread_local="initialexec")
// @(thread_local="localexec")
