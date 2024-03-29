package main

import "core:fmt"
import "core:strings"

// odin build . -o:speed -no-bounds-check -disable-assert

main :: proc() {
    // character_based_strings()
    // string_builder_test()
    concat_strings_buf()
}

character_based_strings :: proc() {
    phrase := "日本語は話せません" // I don't speak Japanese
    fmt.println("`phrase` length:", len(phrase)) // UTF-8

    #unroll for r, i in "日本語は話せません" {
        fmt.println(r, i)
    }
}

concat_strings :: proc() {
    s := ""
    name := "World!"

    s = strings.concatenate({s, name})
    defer delete(s)

    fmt.print(s)
}

// Takes 4.87s on Intel 12900H.
concat_strings_buf :: proc() {
    buf := make([dynamic]byte)
    defer delete(buf)

    hello := "Hello"
    append(&buf, hello)

    world := "World!"
    for i in 0 ..= 1_000_000_000 {
        append(&buf, world)
    }
    s := string(buf[:])
    fmt.printf("%c %c %c {}\n", s[0], s[3_000_000_000], s[6_000_000_000], len(s))
}

string_builder_test :: proc() {
    using strings
    b := builder_make()
    defer builder_destroy(&b)
    // builder_grow(&b, 6000000011)
    write_string(&b, "Hello")
    name := "World!"
    for i in 0 ..= 1_000_000_000 {
        write_string(&b, name)
    }
    s := to_string(b)
    // fmt.println(builder_len(b))
    fmt.printf("%c %c %c {}\n", s[0], s[3_000_000_000], s[6_000_000_000], len(s))
}

cheating_strings_test :: proc() {
    buf := make([]u8, 6_000_000_011)
    defer delete(buf)

    buf[0] = 'H'
    buf[1] = 'e'
    buf[2] = 'l'
    buf[3] = 'l'
    buf[4] = 'o'

    world: [8]u8 = {'W', 'o', 'r', 'l', 'd', '!', 0, 0}
    optimized_world: u64 = transmute(u64)(world)

    for i in 0 ..= 1_000_000_000 {
        offset := len("Hello") + i * len("World!")
        buf_ptr := (^u64)(&buf[offset])
        buf_ptr^ = optimized_world
    }
    s := string(buf[:])
    fmt.printf("%c %c %c {}\n", s[0], s[3_000_000_000], s[6_000_000_000], len(s))
}
