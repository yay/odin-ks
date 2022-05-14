package main

import "core:fmt"
import CF "core:sys/darwin/CoreFoundation"

// CFSTR() allows creation of compile-time constant CFStringRefs; the argument
// should be a constant C-string.
// https://developer.apple.com/documentation/corefoundation/cfstr
// https://developer.apple.com/documentation/corefoundation/cfstringref
// On Apple platforms, CFSTR uses a compiler built-in to generate the string
// at compile time. It is embedded in the executable as a fully-constructed, usable object;
// the program doesn't perform any allocation at runtime for CFSTR. The compiler merges duplicate
// string objects within a single translation unit.
// On other platforms, Apple doesn't control the compiler, so it can't use a compiler built-in
// to embed a constructed object in the executable. Instead, at runtime, it calls the private
// library function __CFStringMakeConstantString. You can find source code for it here:
// https://opensource.apple.com/source/CF/CF-1153.18/CFString.h.auto.html
// It keeps a hash table that maps the argument (as a C string) to a CFString.
// This is the “de-duplication”. It generally doesn't remove entries from the table.
// So each unique C string passed to CFSTR will allocate some memory that persists
// until the program exists.

main :: proc() {
	cf_str := CF.StringMakeConstantString("Hello")
	fmt.println("size_of(cf_str):", size_of(cf_str))
	fmt.println("StringGetLength(cf_str):", CF.StringGetLength(cf_str))
}