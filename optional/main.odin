package main

import "core:fmt"

main :: proc() {
	basics()
	embedded()
}

basics :: proc() {
	Person :: struct {
        name: string,
        age: int,
    }
    // Maybe :: union($T: typeid) {T} // this is already built-in
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

Embed_Maybe :: struct {
	f1: int,
	f2: string,
	m: Maybe(Maybe_Struct),
}

Maybe_Struct :: struct {
	f3: int,
	f4: string,
}


embedded :: proc() {
	embed1 := new(Embed_Maybe)
	defer free(embed1)

	embed2 := new(Embed_Maybe)
	defer free(embed2)
	embed2.m = {}

	embed3 := new(Embed_Maybe)
	defer free(embed3)
	// embed3.m = Maybe_Struct{
	// 	f3 = 42,
	// 	f4 = "fourty two",
	// }
	{
		fmt.printf("%v\n", embed3.m)

		m, ok := embed3.m.?
		if ok {
			fmt.printf("%v\n", m)
		}

		// below line compiles but prints
		// "Invalid type assertion from Maybe($T) to Maybe_Struct, actual type: nil"
		// when the app runs
		// fmt.printf("maybe struct field %v\n", embed3.m.?.f3)
	}

	fmt.printf("%v\n", embed1)
	fmt.printf("%v\n", embed2)
	fmt.printf("%v\n", embed3)

	fmt.println("size_of", size_of(Embed_Maybe)) // 56 bytes (48 bytes without Maybe)
}