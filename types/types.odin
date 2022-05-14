package main

import "core:fmt"
import "core:reflect"

main :: proc() {
	// integer_division()
	struct_field_tags()
}

integer_division :: proc() {
	x: int = 10
	y: int = 2
	z := x / y // z is an integer, not a float

	#assert(type_of(x) == type_of(y))
	#assert(type_of(z) == type_of(y))

	fmt.println(reflect.type_kind(type_of(x)))
	fmt.println(reflect.type_kind(type_of(y)))
	fmt.println(reflect.type_kind(type_of(z)))

	n: int = 3
	m := x / n // m is still an integer

	fmt.println(reflect.type_kind(type_of(m)))
}

struct_field_tags :: proc() {
	User :: struct {
		flag: bool, // untagged field
		age:  int "custom whatever information",
		name: string `json:"username" xml:"user-name" fmt:"q"`, // `core:reflect` layout
	}

	user: User

	field_names := reflect.struct_field_names(type_of(user))

	for name in field_names {
		fmt.println(name)
	}

	field_offsets := reflect.struct_field_offsets(type_of(user))
	for offset in field_offsets {
		fmt.println(offset)
	}

	field_tags := reflect.struct_field_tags(type_of(user))
	for tag, i in field_tags {
		fmt.printf("%v: %v\n", field_names[i], tag)
	}
}
