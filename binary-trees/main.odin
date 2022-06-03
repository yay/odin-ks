package main

// Build using:
// odin build . -o:speed

// https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/binarytrees-rust-5.html

import "core:os"
import "core:strconv"
import "core:mem"
import "core:fmt"

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
        depth := max_depth + 1
        tree := bottom_up_tree(depth)
        fmt.println("stretch tree of depth", depth, "\tcheck:", check(tree))
    }

    // c := bottom_up_tree(max_depth)
    // results := make([dynamic]struct{depth, checksum: int}, (max_depth - min_depth) / 2 + 1)

    // for i in 0..<len(results) {
    //     results[i].depth = i * 2 + min_depth
    // }

    // for i in 0..<len(results) {
    //     res := results[i]
    //     count := 1 << uint(max_depth - res.depth + min_depth)
    //     // the default temp allocator is thread local
    //     sum := 0
    //     for i in 0..<count {
    //         sum += check(bottom_up_tree(res.depth))
    //     }
    //     res.checksum = sum
    // }

    // for res in results {
    //     fmt.println(1 << uint(max_depth - res.depth + min_depth),
    //         "\t trees of depth", res.depth,
    //         "\t check:", res.checksum)
    // }

    // fmt.println("long lived tree of depth", max_depth, "\tcheck:", check(c))
}

bottom_up_tree :: proc(depth: int) -> ^Tree {
    tree := new(Tree, context.temp_allocator)
    if depth > 0 {
        tree.right = bottom_up_tree(depth - 1)
        tree.left = bottom_up_tree(depth - 1)
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