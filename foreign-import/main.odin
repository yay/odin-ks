package main

// The stdout stream is line buffered by default,
// so will only display what's in the buffer after it reaches a newline (or when it's told to).
// Easy way to check, remove the \n and run it again piping the output to |wc -m,
// should count 7 bytes from "testing".
testing: cstring = "testing\n"

// The other fun thing about zsh is pasting a 'commented' command and having part of it run
// because `#DONTRUN this; that; the other` is interpreted as an attempt to run a command named `#DONTRUN`,
// which fails, and then `that` and `the other` run.

main :: proc() {
    printf(testing)
}

// "/usr/lib/libSystem.B.dylib"
foreign import libc "system:System.B"

@(default_calling_convention = "c")
foreign libc {
	printf :: proc(format: cstring, #c_vararg args: ..any) -> int ---
}
