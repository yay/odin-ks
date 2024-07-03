package main

import "../mem_leaks"
import "core:fmt"
import "core:mem"
import "core:os"
import "core:slice"
import "core:strings"
import "core:thread"
import "base:runtime"

import "curl"

main :: proc() {
	mem_leaks.track(run)
}

run :: proc() {
	if s, ok := fetch("https://www.google.com"); ok {
		if os.write_entire_file("page.html", transmute([]byte)s) {
			fmt.println("File written successfully")
		}
	} else {
		fmt.println("Failed to fetch page")
	}
}

fetch :: proc(url: string) -> (string, bool) {
	handle := curl.easy_init()
	defer curl.easy_cleanup(handle)

	data := [dynamic]byte{}
	write_callback :: proc "c" (chunk: rawptr, size, count: uint, data: ^[dynamic]byte) -> uint {
		context = runtime.default_context()
		byte_count := size * count
		s := slice.bytes_from_ptr(chunk, int(byte_count))
		append(data, ..s[:])
		return byte_count
	}

	if curl.E_OK != curl.easy_setopt(handle, curl.OPT_URL, url) {
		return "", false
	}
	if curl.E_OK != curl.easy_setopt(handle, curl.OPT_WRITEFUNCTION, write_callback) {
		return "", false
	}
	if curl.E_OK != curl.easy_setopt(handle, curl.OPT_WRITEDATA, &data) {
		return "", false
	}
	if curl.E_OK != curl.easy_perform(handle) {
		return "", false
	}

	return string(data[:]), true
}
