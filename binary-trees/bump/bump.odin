package bump

import "core:intrinsics"
import "core:mem"

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

ChunkFooter :: struct {
    data: rawptr,
    size: int,
    align: int,

    // Link to the previous chunk.
    //
    // Note that the last node in the `prev` linked list is the canonical empty
    // chunk, whose `prev` link points to itself.
    prev: ^ChunkFooter,

    // Bump allocation finger that is always in the range `self.data..=self`.
    ptr: rawptr,
}

EMPTY_CHUNK := ChunkFooter{
    data = nil,
    size = 0,
    align = 1,
}

Bump :: struct {
    // The current chunk we are bump allocating within.
    current_chunk_footer: ChunkFooter,
}

create :: proc() -> Maybe(Bump) {
    return init_with_capacity(0)
}

init_with_capacity :: proc(capacity: int) -> Maybe(Bump) {
    if capacity == 0 {
        return Bump {}
    }

    chunk_footer, ok := new_chunk(nil, capacity, 1, &EMPTY_CHUNK).?
    if !ok {
        return nil
    }

    return Bump {
        current_chunk_footer = chunk_footer,
    }
}

new_chunk :: proc(
    new_size_without_footer: Maybe(int),
    size: int,
    align: int,
    prev: ^ChunkFooter,
) -> Maybe(^ChunkFooter) {
    new_size_without_footer := new_size_without_footer.? or_else DEFAULT_CHUNK_SIZE_WITHOUT_FOOTER
    align := max(CHUNK_ALIGN, align)
    if requested_size, ok := round_up_to(size, align).?; ok {
        new_size_without_footer = max(new_size_without_footer, requested_size)
    } else {
        panic("requested allocation size overflowed")
    }

    if new_size_without_footer < PAGE_STRATEGY_CUTOFF {
        new_size_without_footer =
            next_power_of_two(new_size_without_footer + OVERHEAD) - OVERHEAD
    } else if rounded, ok := round_up_to(new_size_without_footer + OVERHEAD, 0x1000).?; ok {
        new_size_without_footer = rounded - OVERHEAD
    } else {
        return nil
    }

    size, ok := intrinsics.overflow_add(new_size_without_footer, FOOTER_SIZE)
    if !ok {
        panic("requested allocation size overflowed")
    }

    data := (^u8)(mem.alloc(size, align))
    if data == nil {
        return nil
    }

    footer_ptr := (^ChunkFooter)(intrinsics.ptr_offset(data, new_size_without_footer))

    mem.copy_non_overlapping(&ChunkFooter{
        data = data,
        size = size,
        align = align,
        prev = prev,
        ptr = footer_ptr,
    }, footer_ptr, 1)

    return footer_ptr
}

// `divisor` must be a power of 2.
round_up_to :: proc(n, divisor: int) -> Maybe(int) {
    if sum, ok := intrinsics.overflow_add(n, divisor - 1); ok {
        return sum & ~(divisor - 1)
    }
    return nil
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
    size := size_of(T)
    align := align_of(T)
}

destroy :: proc() {

}