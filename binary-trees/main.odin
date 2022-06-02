package main

// https://benchmarksgame-team.pages.debian.net/benchmarksgame/program/binarytrees-gpp-7.html

import "core:os"
import "core:strconv"
import "core:mem"
import "core:fmt"

Node :: struct {
    l, r: ^Node,
}

MIN_DEPTH :: 4

main :: proc() {
    depth := 0
    if len(os.args) == 2 {
        if d, ok := strconv.parse_int(os.args[1]); ok {
            depth = d
        } else {
            fmt.println("Invalid depth:", os.args[1])
            os.exit(1)
        }
    }
    max_depth := max(MIN_DEPTH + 2, depth)
    stretch_depth := max_depth + 1

    {
        c := make_node(stretch_depth)
        fmt.println("stretch tree of depth", stretch_depth, "\tcheck:", check(c))
    }

    c := make_node(max_depth)
    results := make([dynamic]struct{depth, checksum: int}, (max_depth - MIN_DEPTH) / 2 + 1)

    for i in 0..<len(results) {
        results[i].depth = i * 2 + MIN_DEPTH
    }

    for res in results {
        count := 1 << uint(max_depth - res.depth + MIN_DEPTH)
        // the default temp allocator is thread local
        sum := 0
        for i in 0..<count {
            sum += check(make_node(res.depth))
        }
        // res.checksum = sum
    }
}

check :: proc(n: ^Node) -> int {
    if n.l != nil {
        return check(n.l) + 1 + check(n.r)
    }
    return 1
}

make_node :: proc(d: int) -> ^Node {
    n := new(Node, context.temp_allocator)
    if d > 0 {
        n.l = make_node(d - 1)
        n.r = make_node(d - 1)
    } else {
        n.l = nil
        n.r = nil
    }
    return n
}