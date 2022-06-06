package bump

import "core:intrinsics"
import "core:mem"
import "core:math"

// After this point, we try to hit page boundaries instead of powers of 2.
PAGE_STRATEGY_CUTOFF :: 0x1000

// We only support alignments of up to 16 bytes for iter_allocated_chunks.
SUPPORTED_ITER_ALIGNMENT :: 16
CHUNK_ALIGN :: SUPPORTED_ITER_ALIGNMENT
FOOTER_SIZE :: size_of(ChunkFooter)

// Maximum typical overhead per allocation imposed by allocators.
MALLOC_OVERHEAD :: 16

// This is the overhead from malloc, footer and alignment. For instance, if
// we want to request a chunk of memory that has at least X bytes usable for
// allocations (where X is aligned to CHUNK_ALIGN), then we expect that the
// after adding a footer, malloc overhead and alignment, the chunk of memory
// the allocator actually sets aside for us is X+OVERHEAD rounded up to the
// nearest suitable size boundary.
OVERHEAD :: (MALLOC_OVERHEAD + FOOTER_SIZE + (CHUNK_ALIGN - 1)) & ~int(CHUNK_ALIGN - 1)

// Choose a relatively small default initial chunk size, since we double chunk
// sizes as we grow bump arenas to amortize costs of hitting the global
// allocator.
FIRST_ALLOCATION_GOAL :: 1 << 9

// The actual size of the first allocation is going to be a bit smaller
// than the goal. We need to make room for the footer, and we also need
// take the alignment into account.
DEFAULT_CHUNK_SIZE_WITHOUT_FOOTER :: FIRST_ALLOCATION_GOAL - OVERHEAD

Layout :: struct {
    size: int,
    align: int,
}

ChunkFooter :: struct {
    data: rawptr,
    layout: Layout,
    // Link to the previous chunk.
    //
    // Note that the last node in the `prev` linked list is the canonical empty
    // chunk, whose `prev` link points to itself.
    prev: ^ChunkFooter,

    // Bump allocation finger that is always in the range `self.data..=self`.
    ptr: rawptr,
}

EMPTY_CHUNK := create_empty_chunk()

create_empty_chunk :: proc() -> ChunkFooter {
    empty := ChunkFooter{
        // This chunk is empty (except the foot itself).
        layout = Layout {
            size = size_of(ChunkFooter),
            align = align_of(ChunkFooter),
        },
    }
    // The start of the (empty) allocatable region for this chunk is itself.
    empty.data = &empty
    // The end of the (empty) allocatable region for this chunk is also itself.
    empty.ptr = &empty
    // Invariant: the last chunk footer in all `ChunkFooter.prev` linked lists
    // is the empty chunk footer, whose `prev` points to itself.
    empty.prev = &empty
    return empty
}
// EMPTY_CHUNK.data = &EMPTY_CHUNK

Bump :: struct {
    // The current chunk we are bump allocating within.
    current_chunk_footer: ^ChunkFooter,
}

create :: proc() -> Bump {
    return Bump {
        current_chunk_footer = &EMPTY_CHUNK,
    }
}

destroy :: proc(bump: ^Bump) {
    dealloc_chunk_list(bump.current_chunk_footer)
}

dealloc_chunk_list :: proc(footer: ^ChunkFooter) {
    footer := footer
    for footer != &EMPTY_CHUNK {
        f := footer
        footer = footer.prev
        mem.free(f.data)
    }
}

create_with_capacity :: proc(capacity: int) -> Maybe(Bump) {
    if capacity <= 0 {
        return nil
    }

    layout := Layout{
        size = capacity,
        align = 1,
    }
    if chunk_footer := new_chunk(nil, layout, &EMPTY_CHUNK); chunk_footer != nil {
        return Bump {
            current_chunk_footer = chunk_footer,
        }
    }

    return nil
}

// Allocate a new chunk and return its initialized footer.
new_chunk :: proc(new_size_without_footer: Maybe(int), layout: Layout, prev: ^ChunkFooter) -> ^ChunkFooter {
    new_size_without_footer := new_size_without_footer.? or_else DEFAULT_CHUNK_SIZE_WITHOUT_FOOTER
    align := max(layout.align, CHUNK_ALIGN)
    new_size_without_footer = max(new_size_without_footer, round_up_to(layout.size, align))

    if new_size_without_footer < PAGE_STRATEGY_CUTOFF {
        new_size_without_footer = next_power_of_two(new_size_without_footer + OVERHEAD) - OVERHEAD
    } else {
        new_size_without_footer = round_up_to(new_size_without_footer + OVERHEAD, 0x1000) - OVERHEAD
    }

    size := new_size_without_footer + FOOTER_SIZE
    data := (^u8)(mem.alloc(size, align))
    if data == nil {
        return nil
    }

    footer_ptr := (^ChunkFooter)(intrinsics.ptr_offset(data, new_size_without_footer))

    mem.copy_non_overlapping(&ChunkFooter{
        data = data,
        layout = Layout {
            size = size,
            align = align,
        },
        prev = prev,
        ptr = footer_ptr,
    }, footer_ptr, 1)

    return footer_ptr
}

round_up_to :: proc(n, divisor: int) -> int {
    assert(divisor > 0)
    assert(math.is_power_of_two(divisor))
    return (n + divisor - 1) & ~(divisor - 1)
}

round_down_to :: proc(n, divisor: int) -> int {
    assert(divisor > 0)
    assert(math.is_power_of_two(divisor))
    return n & ~(divisor - 1)
}

next_power_of_two :: proc(n: int) -> int {
    if n <= 1 {
        return 0
    }
    p := n - 1
    z := intrinsics.count_leading_zeros(p)
    return (max(int) >> uint(z)) + 1
}

alloc :: proc(bump: ^Bump, val: $T) -> ^T {
    layout := Layout {
        size = size_of(T),
        align = align_of(T),
    }
    p := (^T)(try_alloc_layout(bump, layout))
    if p == nil {
        return nil
    }
    val := val
    mem.copy_non_overlapping(p, &val, size_of(T))
    return p
}

try_alloc_layout :: proc(bump: ^Bump, layout: Layout) -> rawptr {
    if p := try_alloc_layout_fast(bump, layout); p != nil {
        return p
    }
    return alloc_layout_slow(bump, layout)
}

try_alloc_layout_fast :: proc(bump: ^Bump, layout: Layout) -> rawptr {
    footer := bump.current_chunk_footer
    ptr := uint(uintptr(footer.ptr))
    if ptr < uint(layout.size) {
        return nil
    }

    ptr -= uint(layout.size)
    rem := ptr % uint(layout.align)
    aligned_ptr := ptr - rem

    if aligned_ptr >= uint(uintptr(footer.data)) {
        aligned_ptr := rawptr(uintptr(aligned_ptr))
        footer.ptr = aligned_ptr
        return aligned_ptr
    }

    return nil
}

// Slow path allocation for when we need to allocate a new chunk from the
// parent bump set because there isn't enough room in our current chunk.
alloc_layout_slow :: proc(bump: ^Bump, layout: Layout) -> rawptr {
    footer := bump.current_chunk_footer

    // By default, we want our new chunk to be about twice as big
    // as the previous chunk. If the global allocator refuses it,
    // we try to divide it by half until it works or the requested
    // size is smaller than the default footer size.
    min_new_chunk_size := max(layout.size, DEFAULT_CHUNK_SIZE_WITHOUT_FOOTER)
    base_size := max((footer.layout.size - FOOTER_SIZE) * 2, min_new_chunk_size)

    new_footer: ^ChunkFooter
    for {
        if base_size >= min_new_chunk_size {
            if new_footer = new_chunk(base_size, layout, footer); new_footer != nil {
                break
            }
            base_size /= 2
        } else {
            break
        }
    }
    if new_footer == nil {
        return nil
    }

    bump.current_chunk_footer = new_footer
    ptr := intrinsics.ptr_offset((^u8)(new_footer.ptr), -layout.size)
    ptr = intrinsics.ptr_offset(ptr, -(uint(uintptr(ptr)) % uint(layout.align)))
    new_footer.ptr = ptr

    return ptr
}