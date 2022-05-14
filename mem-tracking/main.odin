package  main

import "core:mem"
import "core:fmt"
import "core:strings"

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
    hello := "Hello" // static string
    hello_world := strings.concatenate({hello, ", World!"}) // heap allocated string
    fmt.println(hello_world)
    // Leaked 13 bytes
}