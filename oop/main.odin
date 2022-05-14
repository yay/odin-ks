package main

import "core:fmt"
import "core:os"

// In this case the struct itself contains pointers to "method" names (rather unnecessarily).
Cat :: struct {
    name: string,
    x:    int,
    y:    int,
    meow: proc(cat: ^Cat),
    move: proc(cat: ^Cat, x, y: int),
}

meow :: proc(cat: ^Cat) {
    fmt.println(cat.name, "-", "meow")
}

move :: proc(cat: ^Cat, x, y: int) {
    cat.x += x
    cat.y += y
    fmt.println(cat.name, "-", "position:", cat.x, cat.y)
}

newCat :: proc(name: string) -> ^Cat {
    cat := new(Cat)
    cat.name = name
    cat.x = 0
    cat.y = 0
    cat.meow = meow
    cat.move = move
    return cat
}

makeRudeCat :: proc(name: string) -> ^Cat {
    cat := new(Cat)
    cat.name = name
    cat.x = 0
    cat.y = 0
    cat.meow = proc(cat: ^Cat) {
        fmt.println(cat.name, "-", "hsssss!")
    }
    cat.move = move
    return cat
}

cats :: proc() {
    tom := newCat("Tom")
    defer free(tom)

    // x->y(5) is the same as x.y(x, 5)
    tom->meow()
    tom->move(2, 2)

    tom.meow(tom)
    tom.move(tom, 2, 2)

    rudeTom := makeRudeCat("Rude Tom")
    defer free(rudeTom)
    rudeTom->meow()
}

Base :: struct {
    greeting: string,
}

Derived :: struct {
    using base: Base,
    name:       string,
}

DerivedByPtr :: struct {
    // `using` can be applied anywhere and even to a pointer.
    // This allows for a huge amount of control over the memory
    // layout of the data structure.
    using base: ^Base,
    name:       string,
}

derived :: proc() {
    base: Base
    derived: Derived
    derivedByPtr: DerivedByPtr

    // Regular print.
    // fmt.println(base)
    // fmt.println(derived)
    // fmt.println(derivedByPtr)

    // Pretty print.
    fmt.printf("%#v\n", base)
    fmt.printf("%#v\n", derived)
    fmt.printf("%#v\n", derivedByPtr)

    base.greeting = "What's up?"
    fmt.println(base)

    derived.greeting = "Hello"
    derived.name = "Vitaly"
    fmt.println(derived)

    derivedByPtr.base = new(Base)
    derivedByPtr.greeting = "Hey"
    derivedByPtr.name = "Ya!"
    fmt.println(derivedByPtr)
}

main :: proc() {
    derived()
}
