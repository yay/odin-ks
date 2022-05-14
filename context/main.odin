package main

import "core:fmt"
import "core:mem"

main :: proc() {
}

basic :: proc() {
    // `context` variable is implicitly passed by pointer to any procedure call
    // c := context // copy the current scope's context
    context.user_index = 456
    {
        context.allocator = mem.nil_allocator()
        context.user_index = 123
        what_a_fool_believes() // the `context` for this scope is implicitly passed to `what_a_fool_believes`
    }
    assert(context.user_index == 456) // `context` value is local to the scope it is in

    what_a_fool_believes :: proc() {
		assert(context.user_index == 123)

		// `new` and `free` use the `context.allocator` by default unless explicitly specified otherwise
		china_grove := new(int)
		free(china_grove)
	}
}