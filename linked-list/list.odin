package main

import "../mem_leaks"
import "core:fmt"
import "core:mem"

Node :: struct($T: typeid) {
	value: T,
	next:  ^Node(T),
}

main :: proc() {
	mem_leaks.track(run)
}

run :: proc() {
	ll := create_singly_linked_list()
	defer free_linked_list(ll)

	print_linked_list(ll)

	ll = reverse_linked_list(ll) // very important to reassign for defer to work
	print_linked_list(ll)
}

create_singly_linked_list :: proc(n: int = 10) -> ^Node(int) {
	if n <= 0 do return nil

	head: ^Node(int)
	prev: ^Node(int)

	for i := 0; i < n; i += 1 {
		node: ^Node(int) = new(Node(int))
		node.value = i + 1
		// `node.next` is zero initialized, so effectively nil
		if prev != nil {
			prev.next = node
		}
		prev = node
		if i == 0 {
			head = node
		}
	}

	return head
}

print_linked_list :: proc(head: ^Node(int)) {
	tip := head
	for tip != nil {
		fmt.println(tip)
		tip = tip.next
	}
}

free_linked_list :: proc(head: ^Node(int)) {
	tip := head // Parameters are not always copies, which is why they are immutable.
	tmp: ^Node(int)

	for tip != nil {
		tmp = tip
		tip = tip.next
		free(tmp)
	}
}

// Multiple return in Odin
// p :: proc(a: u8) -> (b: i32, c: f32, d: u64)
// Is equivalent to this in C (implicit context pointer is passed in,
// and two of the numbers are passed as out parameters):
// u8, ^context, ^i32, ^f32 -> u64

reverse_linked_list :: proc(head: ^Node(int)) -> ^Node(int) {
	tip := head
	prev: ^Node(int)

	for tip != nil {
		next := tip.next
		tip.next = prev
		prev = tip
		if next == nil {
			break
		}
		tip = next
	}

	return tip
}

free_after_use :: proc() {
	node: Node(int) = {5, nil}
	fmt.println(node)

	node_ptr := new(Node(int)) // tracking allocator detects memory leaks
	fmt.println(node_ptr)

	free(node_ptr)
	// fmt.println(node_ptr) // address sanitizer detects use after free
}
