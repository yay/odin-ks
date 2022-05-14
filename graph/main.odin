package main

import "core:fmt"
import "core:math"

// Dijkstra algorithm is a greedy algorithm for finding the shortest path
// in a weighted undirected graph.

// For a given source node in the graph, the algorithm finds the shortest path
// between the source node and every other node. The algorithm can be stopped
// when it finds the shortest path to a given destination node.

// Implemented in response to this Reddit post:
//
//   Learning the syntax of programming for GPU is easy.
//   The problem is porting algorithms to utilize the GPU most efficiently.
//   This means taking into account SIMD architecture, warps, different kinds of memory.
//   It's easy to port code to run on the GPU,
//   it's not easy to actually make it run faster than on a general purpose CPU.
//

add_edge :: proc(m: ^[$M][M]f64, v1, v2: int, w: f64) {
    m[v1][v2] = w
    m[v2][v1] = w
}

dijkstra :: proc(m: ^[$M][M]f64, src: int) -> (dist: [M]f64) {
    spt := [M]bool{} // shortest path tree

    for i := 0; i < M; i += 1 {
        dist[i] = math.INF_F64
    }

    dist[src] = 0

    for i := 0; i < M; i += 1 {
        u := get_min_dist(&dist, &spt)
        if u < 0 { return }
        spt[u] = true
        for v := 0; v < M; v += 1 {
            if m[u][v] > 0 && !spt[v] && m[u][v] != math.INF_F64 {
                if d := dist[u] + m[u][v]; d < dist[v] {
                    dist[v] = d
                }
            }
        }
    }

    return
}

get_min_dist :: proc(dist: ^[$M]f64, spt: ^[M]bool) -> int {
    min_dist := math.INF_F64
    min_idx := -1

    for i := 0; i < M; i += 1 {
        if !spt[i] && dist[i] < min_dist {
            min_dist = dist[i]
            min_idx = i
        }
    }

    return min_idx
}

main :: proc() {
    m := &[9][9]f64{} // adjacency matrix

    add_edge(m, 0, 1, 4)
    add_edge(m, 0, 7, 8)
    add_edge(m, 1, 2, 8)
    add_edge(m, 1, 7, 11)
    add_edge(m, 2, 3, 7)
    add_edge(m, 2, 8, 2)
    add_edge(m, 2, 5, 4)
    add_edge(m, 3, 4, 9)
    add_edge(m, 3, 5, 14)
    add_edge(m, 4, 5, 10)
    add_edge(m, 5, 6, 2)
    add_edge(m, 6, 7, 1)
    add_edge(m, 6, 8, 6)
    add_edge(m, 7, 8, 7)

    fmt.println(dijkstra(m, 0))
}