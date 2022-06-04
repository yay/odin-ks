package bump

// Maximum typical overhead per allocation imposed by allocators.
MALLOC_OVERHEAD :: uint(16)

// This is the overhead from malloc, footer and alignment. For instance, if
// we want to request a chunk of memory that has at least X bytes usable for
// allocations (where X is aligned to CHUNK_ALIGN), then we expect that the
// after adding a footer, malloc overhead and alignment, the chunk of memory
// the allocator actually sets aside for us is X+OVERHEAD rounded up to the
// nearest suitable size boundary.
OVERHEAD :: uint((MALLOC_OVERHEAD + FOOTER_SIZE + (CHUNK_ALIGN - 1)) & !(CHUNK_ALIGN - 1))

// Choose a relatively small default initial chunk size, since we double chunk
// sizes as we grow bump arenas to amortize costs of hitting the global
// allocator.
FIRST_ALLOCATION_GOAL :: uint(1 << 9)

// The actual size of the first allocation is going to be a bit smaller
// than the goal. We need to make room for the footer, and we also need
// take the alignment into account.
DEFAULT_CHUNK_SIZE_WITHOUT_FOOTER :: uint(FIRST_ALLOCATION_GOAL - OVERHEAD)

//  Layout of a block of memory.
Layout :: struct {
    // Size of the requested block of memory, measured in bytes.
    size: uint,

    // Alignment of the requested block of memory, measured in bytes.
    align: uint,
}

ChunkFooter :: struct {
    // Pointer to the start of this chunk allocation.
    // This footer is always at the end of the chunk.
    data: ^u8,

    // The layout of this chunk's allocation.
    layout: Layout,

    // Link to the previous chunk.
    //
    // Note that the last node in the `prev` linked list is the canonical empty
    // chunk, whose `prev` link points to itself.
    prev: ChunkFooter,

    // Bump allocation finger that is always in the range `self.data..=self`.
    ptr: ^u8,
}

Bump :: struct {
    // The current chunk we are bump allocating within.
    current_chunk_footer: ChunkFooter,
}

bump_create :: proc() -> Maybe(Bump) {
    return bump_init_with_capacity(0)
}

bump_init_with_capacity :: proc(capacity: uint) -> Maybe(Bump) {
    if capacity == 0 {
        return Bump {}
    }

    // chunk_footer =
}

bump_new_chunk :: proc(
    new_size_without_footer: Maybe(uint),
    requested_layout: Layout,
    prev: ChunkFooter,
) -> Maybe(ChunkFooter) {
    new_size_without_footer, ok := new_size_without_footer.?
    if !ok {
        new_size_without_footer = DEFAULT_CHUNK_SIZE_WITHOUT_FOOTER
    }
}

bump_destroy :: proc() {

}