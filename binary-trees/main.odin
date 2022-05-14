package main

// https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/binarytrees-rust-5.html

import "core:fmt"
import "core:intrinsics"
import "core:mem"
import "core:mem/virtual"
import "core:os"
import "core:runtime"
import "core:strconv"
import "core:thread"

Tree :: struct {
	left, right: ^Tree,
}

main :: proc() {
	depth := 10
	if len(os.args) == 2 {
		if d, ok := strconv.parse_int(os.args[1]); ok {
			depth = d
		}
	}
	min_depth := 4
	max_depth := max(min_depth + 2, depth)

	{
		arena: virtual.Arena
		allocator := virtual.arena_allocator(&arena)
		defer virtual.arena_free_all(&arena)

		depth := max_depth + 1
		tree := bottom_up_tree(allocator, depth)
		fmt.println("stretch tree of depth", depth, "\tcheck:", check(tree))
	}

	long_lived_arena: virtual.Arena
	allocator := virtual.arena_allocator(&long_lived_arena)
	defer virtual.arena_free_all(&long_lived_arena)
	long_lived_tree := bottom_up_tree(allocator, max_depth)

	results := make([dynamic]struct {
			depth, checksum: int,
		}, (max_depth - min_depth) / 2 + 1)
	defer delete(results)

	for i in 0 ..< len(results) {
		results[i].depth = i * 2 + min_depth
	}

	pool: thread.Pool
	thread.pool_init(&pool, context.allocator, processor_core_count())
	defer thread.pool_destroy(&pool)

	for i in 0 ..< len(results) {
		depth := results[i].depth
		iterations := 1 << uint(max_depth - depth + min_depth)
		work := new_clone(Work{depth = depth, iterations = iterations, result = &results[i]})
		thread.pool_add_task(&pool, context.allocator, worker, work, i)
	}

	thread.pool_start(&pool)
	thread.pool_finish(&pool)

	for res in results {
		fmt.println(
			int(1) << uint(max_depth - res.depth + min_depth),
			"\t trees of depth",
			res.depth,
			"\t check:",
			res.checksum,
		)
	}

	fmt.println("long lived tree of depth", max_depth, "\tcheck:", check(long_lived_tree))
}

Work :: struct {
	depth, iterations: int,
	result:            ^struct {
		depth, checksum: int,
	},
}

worker :: proc(t: thread.Task) {
	arena: virtual.Arena
	allocator := virtual.arena_allocator(&arena)
	defer virtual.arena_free_all(&arena)

	work := (^Work)(t.data)

	// thread_print(work)

	using work
	result.checksum = inner(allocator, depth, iterations)
	free(work)
}

bottom_up_tree :: proc(allocator: runtime.Allocator, depth: int) -> ^Tree {
	// The default temp allocator is thread local.
	// Temp allocator is a ring buffer with a fixed size of only a few megabytes.
	// For example, to increase the size to 128MB compile with:
	// odin build . -o:speed -no-bounds-check -define:DEFAULT_TEMP_ALLOCATOR_BACKING_SIZE=134217728
	// tree := new(Tree, context.temp_allocator)
	tree := new(Tree, context.temp_allocator)
	if depth > 0 {
		tree.right = bottom_up_tree(allocator, depth - 1)
		tree.left = bottom_up_tree(allocator, depth - 1)
	}
	return tree
}

check :: proc(tree: ^Tree) -> int {
	using tree
	if left != nil && right != nil {
		return 1 + check(right) + check(left)
	}
	return 1
}

inner :: proc(allocator: runtime.Allocator, depth, iterations: int) -> int {
	sum := 0
	for i in 0 ..< iterations {
		tree := bottom_up_tree(allocator, depth)
		sum += check(tree)
	}
	return sum
}

print_mutex := b64(false)
thread_print :: proc(args: ..any) { 	// allow one thread to print at a time
	for !did_acquire(&print_mutex) {thread.yield()}
	fmt.println(..args)
	print_mutex = false
}

did_acquire :: proc(m: ^b64) -> (acquired: bool) {
	res, ok := intrinsics.atomic_compare_exchange_strong(m, false, true)
	return ok && res == false
}
