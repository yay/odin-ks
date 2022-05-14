package main

import "core:fmt"

main :: proc() {
    phone_book := make(map[string]map[string]string)
    phone_book["peter"] = make(map[string]string)

    // Doing `A := phone_book["peter"]` would copy the struct rather than map contents,
    // and will result in a use after free bug.
    A := &phone_book["peter"] // note the &
    A["name"] = "peter"
    A["phone"] = "+555"

    B := &phone_book["peter"] // note the &
    B["phone"] = "+333"

    fmt.println(phone_book)

    delete(phone_book)
}