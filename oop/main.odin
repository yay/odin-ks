package main

import "core:fmt"
import "core:os"

main :: proc() {
	// derived()
	// cats()
	vtables()
}

derived :: proc() {
	base: Base
	derived: Derived
	derivedByPtr: DerivedByPtr

	// Pretty print.
	fmt.printf("%#v\n", base)
	fmt.printf("%#v\n", derived)
	fmt.printf("%#v\n", derivedByPtr)

	base.greeting = "What's up?"
	fmt.println(base)

	derived.greeting = "Hello"
	// derived.base.greeting = "Hi" // same as `derived.greeting`
	derived.name = "Vitaly"
	fmt.println(derived)

	derivedByPtr.base = new(Base)
	derivedByPtr.greeting = "Hey"
	derivedByPtr.name = "Ya!"
	fmt.println(derivedByPtr)
}

cats :: proc() {
	tom := newCat("Tom")
	defer free(tom)

	// x->y(5) is the same as x.y(x, 5)
	tom->meow()
	tom->move(2, 2)
	// two lines below are equivalent to two lines above
	tom.meow(tom)
	tom.move(tom, 2, 2)

	rudeTom := newRudeCat("Rude Tom")
	defer free(rudeTom)
	rudeTom->meow()
}

Redactable :: struct {
	redact: proc(l: ^Redactable),
}

Loggable :: struct {
	using redactable: Redactable,
	format:           proc(l: ^Loggable) -> string,
}

User :: struct {
	// `loggable` is a table of functions (virtual table)
	using loggable: Loggable, // has to be the 1st field as methods take pointer to Loggable
	name:           string,
	age:            int,
	SSN:            string,
}

user_redact :: proc(l: ^Redactable) {
	u := cast(^User)l
	u.SSN = "REDACTED"
}

user_format :: proc(l: ^Loggable) -> string {
	return fmt.tprintf("%v", cast(^User)l)
}

log_redacted :: proc(l: ^Loggable) {
	l->redact()
	fmt.printf("%s\n", l->format())
}

vtables :: proc() {
	u := User {
		name   = "Rickard",
		age    = 36,
		SSN    = "1234567890",
		redact = user_redact,
		format = user_format,
	}
	fmt.println("size_of(User):", size_of(User))
	log_redacted(&u)
}

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

newRudeCat :: proc(name: string) -> ^Cat {
	cat := newCat(name)
	cat.meow = proc(cat: ^Cat) {
		fmt.println(cat.name, "-", "hsssss!")
	}
	return cat
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
