package main

import "core:fmt"
import "core:mem"
import CF "core:sys/darwin/CoreFoundation"
import NS "vendor:darwin/Foundation"

main :: proc() {
    track_allocations(run)
}

run :: proc() {
}

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
