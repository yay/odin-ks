package main

import "core:fmt"

main :: proc() {
    Person :: struct {
        name: string,
        age: int,
    }
    Maybe :: union($T: typeid) {T} // this is already built-in
    mi: Maybe(u8)
    mpi: Maybe(^u8)
    p: Person
    mp: Maybe(Person)
    mpp: Maybe(^Person) // no tag is stored for pointers, nil is the sentinel value

    fmt.println(size_of(mi)) // 2
    fmt.println(size_of(mpi)) // 8
    fmt.println(size_of(p)) // 24
    fmt.println(size_of(mp)) // 32
    fmt.println(size_of(mpp)) // 8

    #assert(size_of(mpi) == size_of(^u8))
    #assert(size_of(mpp) == size_of(^Person))

    fmt.println(mi) // nil
    // xx := mi.? // Invalid type assertion from Maybe(u8) to u8, actual type: nil

    i, i_ok := mi.?
    fmt.println(i, i_ok) // 0 false

    mi = 123
    x := mi.?
    i, i_ok = mi.?
    fmt.println(x) // 123
    fmt.println(i, i_ok) // 123 true

    {
        maybe_int: union { int }
        i, i_ok := maybe_int.?
        fmt.println(i, i_ok) // 0 false

        maybe_int = 42
        i, i_ok = maybe_int.?
        fmt.println(i, i_ok) // 42 true
    }

    // mp.name = "Fred" // 'mp' of type 'Maybe(Person)' has no field 'name'
    // mp.?.name = "Fred" // 'Cannot assign to 'mp.?.name'
}