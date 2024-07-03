package main

import "core:fmt"

main :: proc() {
	octal()
	// unsigned_bits()
	// signed_bits()
}

octal :: proc() {
	fmt.printf("%o\n", 0o777)
	fmt.printf("%b\n", 0o777)
}

unsigned_bits :: proc() {
	a: u32 = 0
	bit0: u32  = 1 << 0
	bit1: u32  = 1 << 1
	bit31: u32 = 1 << 31

	fmt.printf("max(u32):  %32b\n", max(u32))
	fmt.printf("min(u32):  %32b\n", min(u32))

	// setting bit n:
	// storage |= 1 << n;
	fmt.printf("a          %32b\n", a)
	fmt.printf("a | bit0   %32b\n", a | bit0)
	fmt.printf("a | bit1   %32b\n", a | bit1)
	fmt.printf("a | bit31  %32b\n", a | bit31)

	// clearing bit n:
	// storage &= ~(1 << n); // bitwise complement unary operator (changes 0 to 1 and 1 to 0)
	fmt.printf("bit31      %32b\n", bit31)
	fmt.printf("~bit31     %32b\n", ~bit31)
	fmt.printf("a          %32b\n", a | bit31 & ~bit31) // unary operators have the highest precedence

	line_sep()
}

signed_bits :: proc() {
	a: i32 = 0
	bit0: i32  = 1 << 0
	bit1: i32  = 1 << 1
	bit30: i32 = 1 << 30

	fmt.printf("i8(-1):    %8b\n", i32(-1))
	fmt.printf("i8(-2):    %8b\n", i32(-2))
	fmt.printf("i8(-3):    %8b\n", i32(-3))
	fmt.printf("min(i8):   %v\n", min(i8))
	fmt.printf("max(i8):   %v\n", max(i8))
	fmt.printf("min(i8):   %8b\n", min(i8))
	fmt.printf("min(i8)+1: %8b\n", min(i8) + 1)
	fmt.printf("max(i8):   %8b\n", max(i8))

	fmt.printf("max(i32):  %32b\n", max(i32))
	fmt.printf("min(i32): %32b\n", min(i32))

	fmt.printf("a          %32b\n", a)
	fmt.printf("a | bit0   %32b\n", a | bit0)
	fmt.printf("a | bit1   %32b\n", a | bit1)
	fmt.printf("a | bit30  %32b\n", a | bit30)

	fmt.printf("i32(-3):   %32b\n", i32(-3))
	fmt.printf("i32(-2):   %32b\n", i32(-2))
	fmt.printf("i32(-1):   %32b\n", i32(-1))
	fmt.printf("bit30      %32b\n", bit30)
	fmt.printf("~bit30     %32b\n", ~bit30)
	fmt.printf("-1 ~ bit30 %32b\n", i32(-1) ~ bit30)
	fmt.printf("a          %32b\n", a | bit30 & ~bit30)

	line_sep()
}

// For any integer n, bitwise complement of n will be -(n + 1)
// Note: Overflow is ignored while computing 2's complement.

line_sep :: proc() {
	fmt.println("--- --- --- --- --- --- --- --- --- --- ---")
}