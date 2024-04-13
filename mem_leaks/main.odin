package mem_tracking

import "core:fmt"
import "core:mem"
import "core:strings"

main :: proc() {
	track(entry_point)
}

entry_point :: proc() {
	hello := "Hello" // static string
	hello_world := strings.concatenate({hello, ", World!"}) // heap allocated string
	fmt.println(hello_world)
	// Leaked 13 bytes
}

track :: proc(code: proc()) {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)

	defer {
		if len(track.allocation_map) > 0 {
			fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
			for _, entry in track.allocation_map {
				fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
			}
		}
		if len(track.bad_free_array) > 0 {
			fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
			for entry in track.bad_free_array {
				fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
			}
		}
		mem.tracking_allocator_destroy(&track)
	}

	code()
}
