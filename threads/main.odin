package main

import "core:fmt"
import "core:thread"
import "core:time"
import "core:runtime"
import "core:sys/darwin"
import "core:strings"
import "core:c"
import "core:testing"

main :: proc() {
    basic_threads()
    // parallel_loop()
}

get_darwin_ncpu :: proc() -> int {
    mib := [2]i32{6, 3} // CTL_HW (generic cpu/io), HW_NCPU (number of cpus)
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

parallel_loop :: proc() {
    threads := make([dynamic]^thread.Thread, 0, get_darwin_ncpu())
    defer delete(threads)
}

// @thread_local is the same as @static but thread local.

// Thread local storage is supported at the file scope:
// @(thread_local="default") or @thread_local
// @(thread_local="localdynamic")
// @(thread_local="initialexec")
// @(thread_local="localexec")
