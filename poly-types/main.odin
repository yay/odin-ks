package main

import "core:fmt"

main :: proc() {
    Table_Slot :: struct($Key, $Value: typeid) {
        occupied: bool,
        hash: u32,
        key: Key,
        value: Value,
    }
    TABLE_SIZE_MIN :: 32
    Table :: struct($Key, $Value: typeid) {
        count: int,
        allocator: mem.Allocator,
        slots: []Table_Slot(Key, Value),
    }

    // `typeid/[]$E` means: only allow types that are specializations of a slice
    make_slice :: proc($T: typeid/[]$E, len: int) -> T {
        return make(T, len)
    }

    allocate :: proc(table: ^$T/Table, capacity: int) {
        c := context
        if table.allocator.procedure != nil {
            c.allocator = table.allocator
        }
        context = c

        table.slots = make_slice(type_of(table.slots), max(capacity, TABLE_SIZE_MIN))
    }

    expand :: proc(table: ^$T/Table) {
        c := context
        if table.allocator.procedure != nil {
            c.allocator = table.allocator
        }
        context = c

        old_slots := table.slots
        defer delete(old_slots)
    }
}