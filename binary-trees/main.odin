package main

// https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/binarytrees-rust-5.html

import "core:os"
import "core:strconv"
import "core:mem"
import "core:thread"
import "core:sys/darwin"
import "core:intrinsics"
import "core:fmt"

import "bump"
// import "core:mem/virtual" // Growing_Arena is not implemented on Darwin yet

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
        arena := bump.create()
        defer bump.destroy(&arena)
        depth := max_depth + 1
        tree := bottom_up_tree(&arena, depth)
        fmt.println("stretch tree of depth", depth, "\tcheck:", check(tree))
    }

    // long_lived_arena := bump.create()
    // defer bump.destroy(&long_lived_arena)
    // long_lived_tree := bottom_up_tree(&long_lived_arena, max_depth)

    // results := make([dynamic]struct{depth, checksum: int}, (max_depth - min_depth) / 2 + 1)
    // defer delete(results)

    // for i in 0..<len(results) {
    //     results[i].depth = i * 2 + min_depth
    // }

    // pool: thread.Pool
    // thread.pool_init(&pool, context.allocator, get_darwin_ncpu())
    // defer thread.pool_destroy(&pool)

    // for i in 0..<len(results) {
    //     depth := results[i].depth
    //     iterations := 1 << uint(max_depth - depth + min_depth)
    //     work := new_clone(Work{
    //         depth = depth,
    //         iterations = iterations,
    //         result = &results[i],
    //     })
    //     thread.pool_add_task(&pool, context.allocator, worker, work, i)
    // }

    // thread.pool_start(&pool)
    // thread.pool_finish(&pool)

    // for res in results {
    //     fmt.println(1 << uint(max_depth - res.depth + min_depth),
    //         "\t trees of depth", res.depth,
    //         "\t check:", res.checksum)
    // }

    // fmt.println("long lived tree of depth", max_depth, "\tcheck:", check(long_lived_tree))
}

Work :: struct {
    depth, iterations: int,
    result: ^struct{depth, checksum: int},
}

worker :: proc(t: thread.Task) {
    work := (^Work)(t.data)

    // thread_print(work)

    using work
    result.checksum = inner(depth, iterations)
    free(work)
}

bottom_up_tree :: proc(arena: ^bump.Bump, depth: int) -> ^Tree {
    // The default temp allocator is thread local.
    // Temp allocator is a ring buffer with a fixed size of only a few megabytes.
    // For example, to increase the size to 128MB compile with:
    // odin build . -o:speed -no-bounds-check -define:DEFAULT_TEMP_ALLOCATOR_BACKING_SIZE=134217728
    // tree := new(Tree, context.temp_allocator)
    tree := bump.alloc(arena, Tree{})
    if depth > 0 {
        tree.right = bottom_up_tree(arena, depth - 1)
        tree.left = bottom_up_tree(arena, depth - 1)
    }
    return tree
}

check :: proc(tree: ^Tree) -> int {
    using tree
    if left != nil && right != nil {
        return 1 + check(right) + check(left)
    } else {
        return 1
    }
}

inner :: proc(depth, iterations: int) -> int {
    arena := bump.create()
    defer bump.destroy(&arena)

    sum := 0
    for i in 0..<iterations {
        tree := bottom_up_tree(&arena, depth)
        sum += check(tree)
    }
    return sum
}

CTL_HW :: 6  // generic cpu/io
HW_NCPU :: 3 // number of cpus

get_darwin_ncpu :: proc() -> int {
    mib := [2]i32{CTL_HW, HW_NCPU}
	out := u32(0)
	nout := i64(size_of(out))
	ret := darwin.syscall_sysctl(&mib[0], 2, &out, &nout, nil, 0)
	if ret >= 0 && int(out) > 0 {
		return int(out)
	}
	return 1
}

print_mutex := b64(false)
thread_print :: proc(args: ..any) { // allow one thread to print at a time
    for !did_acquire(&print_mutex) { thread.yield() }
    fmt.println(..args)
    print_mutex = false
}

did_acquire :: proc(m: ^b64) -> (acquired: bool) {
    res, ok := intrinsics.atomic_compare_exchange_strong(m, false, true)
    return ok && res == false
}