package main

import "core:fmt"
import "base:intrinsics"

main :: proc() {
	variable_length_array(100)
}

variable_length_array :: proc(n: int,) {
    // https://man7.org/linux/man-pages/man3/alloca.3.html
	u8_pointer := intrinsics.alloca(8 * n, 8) // stack allocated, uninitialized memory
	int_pointer := transmute([^]int)u8_pointer
	int_slice := int_pointer[0:100]
	for value, index in int_slice {
		int_slice[index] = 0
	}
	fmt.println(u8_pointer)
	fmt.println(int_pointer)
	fmt.println(int_slice)
}