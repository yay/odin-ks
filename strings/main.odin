package main

import "core:fmt"
import "core:strings"
// import "core:mem"

// odin build . -o:speed -no-bounds-check -disable-assert

main :: proc() {
    concat_strings()
}

concat_strings :: proc() {
    s := ""
    name := "World!"

    s = strings.concatenate({s, name})
    defer delete(s)

    fmt.print(s)
}

concat_strings_buf :: proc() {
    buf := make([dynamic]u8)
    defer delete(buf)

    hello := "Hello"
    append(&buf, hello)

    world := "World!"
    for i in 0..1_000_000_000 {
        append(&buf, world)
    }
    s := string(buf[:])
    fmt.printf("%c %c %c {}\n", s[0], s[3_000_000_000], s[6_000_000_000], len(s))
}

string_builder_test :: proc() {
    using strings
    b := make_builder()
    defer destroy_builder(&b)
    grow_builder(&b, 6000000011)
    write_string(&b, "Hello")
    name := "World!"
    for i in 0..1_000_000_000 {
        write_string(&b, name)
    }
    fmt.println(builder_len(b))
}

cheating_strings_test :: proc() {
    buf := make([]u8, 6_000_000_011)
    defer delete(buf)

    buf[0] = 'H'
    buf[1] = 'e'
    buf[2] = 'l'
    buf[3] = 'l'
    buf[4] = 'o'

    world: [8]u8 = { 'W', 'o', 'r', 'l', 'd', '!', 0, 0 }
    optimized_world: u64 = transmute(u64)(world)

    for i in 0..1_000_000_000 {
        offset := len("Hello") + i * len("World!")
        buf_ptr := (^u64)(&buf[offset])
        buf_ptr^ = optimized_world
    }
    s := string(buf[:])
    fmt.printf("%c %c %c {}\n", s[0], s[3_000_000_000], s[6_000_000_000], len(s))
}