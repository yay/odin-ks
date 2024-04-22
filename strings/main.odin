package main

import "../mem_leaks"
import "base:runtime"
import "core:c/libc"
import "core:fmt"
import "core:mem"
import "core:strings"

// Build with:
// odin build . -o:speed -no-bounds-check -disable-assert

main :: proc() {
	mem_leaks.track(run)
}

run :: proc() {
	// slice_and_string_internals()
	string_example()
	// run_benchmarks()
	// slice_memory()
}

slice_memory :: proc() {
	result, err := strings.concatenate({"123", "456", "789"})
	// defer delete(result) // would leak 9 bytes without this statement

	sub_str := result[3:6] // points to a section of the original slice
	fmt.println("sub_str", sub_str)
	delete(sub_str) // no effect, still would leak 9 bytes, if `result` is not deleted
}

run_benchmarks :: proc() {
	benchmark_string_builder()
	benchmark_dynamic_array()
	benchmark_cheating_strings()
}

// Notes:
// - strings are immutable in Odin
// - `make` allocates memory for a backing data structure of either a slice, dynamic array, or map,
//   while `delete` frees it

slice_and_string_internals :: proc() {
	// A slice and a string are the same structs internally,
	// and represent a view to some data, but you have to have that data (or source of it)
	// in the first place.
	str := "string"
	fmt.println("size_of(str)", size_of(str)) // 16

	// Raw_String :: struct {
	//     data: [^]byte, // <-- multi-pointer to bytes
	//     len:  int,
	// }
	raw_str := transmute(runtime.Raw_String)str
	fmt.println(raw_str)

	dyn := make([dynamic]int, 6, 6) // dyn array with length & capacity of 5
	defer delete(dyn)

	// Raw_Dynamic_Array :: struct {
	// 	   data:      rawptr,
	// 	   len:       int,
	// 	   cap:       int,
	// 	   allocator: Allocator,
	// }
	fmt.println("size_of(dyn)", size_of(dyn)) // 40
	raw_dyn := transmute(runtime.Raw_Dynamic_Array)dyn
	fmt.println(raw_dyn)

	slice := dyn[:]
	fmt.println("size_of(slice)", size_of(slice)) // 16
	// Raw_Slice :: struct {
	// 	   data: rawptr,
	// 	   len:  int,
	// }
	raw_slice := transmute(runtime.Raw_Slice)slice
	fmt.println(raw_slice)
}

string_example :: proc() {
	name := "Vitaly 😛"
	if strings.compare(name, "Vitaly 😛") == 0 {
		fmt.println("The names match!")
	} else {
		fmt.println("The names do not match!")
	}

	if strings.contains_rune(name, '😛') {
		fmt.println("name contains the rune!")
	} else {
		fmt.println("name does not contain the rune!")
	}

	index_of_rune := strings.index(name, "😛")
	if index_of_rune == -1 {
		fmt.println("name does not contain the needle!")
	} else {
		fmt.println("name contains the needle and is located at index:", index_of_rune)
	}

	fmt.println("name is", strings.rune_count(name), "rune(s) long.")
	fmt.println("name is", len(name), "bytes long.")

	phrase := "日本語は話せません" // I don't speak Japanese
	fmt.println("len(phrase):", len(phrase)) // UTF-8

	for r, i in phrase {
		fmt.println(r, i)
	}

	{
		address, err := strings.join({"43 Naval House", "London", "SE18 6FN"}, ", ")
		defer delete(address) // would leak 32 bytes without this statement

		if err == nil {
			fmt.println("Joined strings:", address)
		} else {
			fmt.println("Joining strings failed. Allocation error:", err)
		}
	}

	{
		result, err := strings.concatenate({"123", "456", "789"})
		defer delete(result) // would leak 9 bytes without this statement

		if err == nil {
			fmt.println("Concatenated strings:", result)
		} else {
			fmt.println("Concatenating strings failed. Allocation error:", err)
		}
	}

	{
		static_str := "static"
		defer delete(static_str) // pointless here
	}

	{
		dyn_string := fmt.aprintf("Some value: %v", libc.rand())
		defer delete(dyn_string)
		fmt.println(dyn_string)
	}

	FILE_CONTENTS :: `README.md
	 .gitignore
	 main.odin`

	file_names := strings.split(FILE_CONTENTS, "\n")
	defer delete(file_names)
	file_count := len(file_names)
	markdown_file_count: int

	for line in file_names {
		if strings.contains(line, ".md") {
			markdown_file_count += 1
		}
	}

	fmt.printf(
		"There are %i files and %i of them are markdown files.\n",
		file_count,
		markdown_file_count,
	)

	// The `fields` proc will split the string with the separator being whitespace. Extra whitespace will be trimmed.
	command_string := "ls   Downloads"
	command_tokens := strings.fields(command_string)
	defer delete(command_tokens)
	fmt.println(command_tokens)
}

concat_strings :: proc() {
	s := ""
	name := "World!"

	s = strings.concatenate({s, name})
	defer delete(s)

	fmt.print(s)
}

expected_str_len := 6_000_000_011

// Takes:
// - 5.149s on Intel 12900H
// - 6.436s on Apple M1 Pro
benchmark_dynamic_array :: proc() {
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

// Takes:
// - 6.327s on Apple M1 Pro
benchmark_string_builder :: proc() {
	b := strings.builder_make()
	defer strings.builder_destroy(&b)
	// strings.builder_grow(&b, expected_str_len) // makes barely any difference
	strings.write_string(&b, "Hello")
	name := "World!"
	for i in 0 ..= 1_000_000_000 {
		strings.write_string(&b, name)
	}
	s := strings.to_string(b)
	// fmt.println("builder_len:", strings.builder_len(b)) // expected_str_len
	fmt.printf("%c %c %c {}\n", s[0], s[3_000_000_000], s[6_000_000_000], len(s))
}

// Takes:
// - 0.660s on Apple M1 Pro
benchmark_cheating_strings :: proc() {
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
	// fmt.printf("%c %c %c {}\n", s[0], s[3_000_000_000], s[6_000_000_000], len(s))
	log_str(&s)
}

log_str :: proc(s: ^string) {
	fmt.printf("%c %c %c {}\n", s[0], s[3_000_000_000], s[6_000_000_000], len(s))
}
