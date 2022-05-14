package main

import "core:fmt"
import "core:mem"

Node :: struct($T: typeid) {
	value: T,
	next: ^Node(T),
}

main :: proc() {
	track_allocations(run)
}

run :: proc() {
	node: Node(int) = { 5, nil }
	fmt.println(node)
	node_ptr := new(Node(int)) // tracking allocator detects memory leaks
	fmt.println(node_ptr)
	free(node_ptr)
	// fmt.println(node_ptr) // address sanitizer detects use after free
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