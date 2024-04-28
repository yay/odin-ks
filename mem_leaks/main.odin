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

	code()

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

	if track.total_memory_allocated == track.total_memory_freed &&
	   track.total_allocation_count == track.total_free_count &&
	   track.current_memory_allocated == 0 {
		fmt.printf(
			"Allocated (bytes): %i, Alloc count: %i, Peak (bytes): %i\n",
			track.total_memory_allocated,
			track.total_allocation_count,
			track.peak_memory_allocated,
		)
	} else {
		fmt.printf(
			"Allocated/Freed (bytes): %i/%i, Alloc/Free count: %i/%i, Peak (bytes): %i, Current (bytes): %i\n",
			track.total_memory_allocated,
			track.total_memory_freed,
			track.total_allocation_count,
			track.total_free_count,
			track.peak_memory_allocated,
			track.current_memory_allocated,
		)
	}
	mem.tracking_allocator_destroy(&track)
}
