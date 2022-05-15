package main

import "core:fmt"
import "core:thread"
import "core:time"

main :: proc() {
    basic_threads()
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

    counter := 0
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

    fmt.println("Counter:", counter) // 77567

    for t in threads {
        thread.join(t)
    }
    for t in threads {
        fmt.println("Thread", t.user_index, "is done:", thread.is_done(t))
    }
}
