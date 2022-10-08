package main

import "core:fmt"

MyStruct :: struct {
    fred: int,
    func: proc(s: ^MyStruct) -> int
}

func :: proc(this: ^MyStruct) -> int {
    return this.fred + 42
}

main :: proc() {
    myStruct : MyStruct = {
        fred = 1,
        func = func
    }
    myStruct.func(&myStruct)

    defer fmt.println("1")
    defer fmt.println("2")
    defer fmt.println("3")
    {
        defer fmt.println("4")
        fmt.println("5")
    }
    defer fmt.println("6")
}

basic :: proc() {
    defer { // "Unreachable defer statement due to diverging procedure call at the end of the current scope"
        fmt.println("Still printed!")
    }
    fmt.println("Printed!")
    // panic("Oh no!")
}