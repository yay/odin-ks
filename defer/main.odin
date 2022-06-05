package main

import "core:fmt"

main :: proc() {
    defer { // "Unreachable defer statement due to diverging procedure call at the end of the current scope"
        fmt.println("Still printed!")
    }
    fmt.println("Printed!")
    panic("Oh no!")
}