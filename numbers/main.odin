package main

import "core:fmt"

main :: proc() {
	fmt.println(max(u32)) // 4294967295
	fmt.println(max(int)) // 9223372036854775807
}
