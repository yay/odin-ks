package main

import "core:os"
import "core:fmt"
import "core:mem"
import mem_virtual "core:mem/virtual"
import "core:time"
import "core:slice"
import "core:runtime"
import "core:strings"
import "core:strconv"
import "core:thread"
import "core:encoding/csv"

track_allocations :: proc(scope: proc()) {
	tracking_allocator: mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracking_allocator, context.allocator)
	context.allocator = mem.tracking_allocator(&tracking_allocator)

	scope()

	for key, value in tracking_allocator.allocation_map {
		fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
	}

	mem.tracking_allocator_destroy(&tracking_allocator)
}

main :: proc() {
	track_allocations(entry_point4)
}

csv_file_name :: "/Users/vitaly/pp-monthly.csv"

// growing_arena : mem_virtual.Growing_Arena
// mem_virtual.arena_init(&growing_arena)
// defer mem_virtual.arena_destroy(&growing_arena)
// growing_arena_allocator := mem_virtual.growing_arena_allocator(&growing_arena)
// context.allocator = growing_arena_allocator

entry_point :: proc() {
    data, ok := os.read_entire_file(csv_file_name)
	defer delete(data)

    if !ok {
        fmt.println("Could not read file")
        return
    }

    rows, err := csv.read_all_from_string(string(data))
    if err != nil {
        fmt.println("Could not read CSV data", err)
        return
    }

    fmt.println(rows[123])

    for row in rows {
        for col in row {
            delete(col)
        }
        delete(row)
    }
    delete(rows)
}

entry_point4 :: proc() {
    data, ok := os.read_entire_file(csv_file_name)
    defer delete(data)

    if !ok {
        fmt.println("Could not read file")
        return
    }

    r: csv.Reader
    csv.reader_init_with_string(&r, string(data))
    defer csv.reader_destroy(&r)

    rows, err := csv.read_all(&r)
    fmt.println(rows[123])

    for row in rows {
        for col in row {
            delete(col)
        }
        delete(row)
    }
    delete(rows)
}

entry_point2 :: proc() {
    data, ok := os.read_entire_file(csv_file_name)
    defer delete(data)

    if !ok {
        fmt.println("Could not read file")
        return
    }

    growing_arena : mem_virtual.Growing_Arena
    mem_virtual.arena_init(&growing_arena)
    defer mem_virtual.arena_destroy(&growing_arena)
    growing_arena_allocator := mem_virtual.growing_arena_allocator(&growing_arena)
    context.allocator = growing_arena_allocator

    s := string(data)
    records: [dynamic][]string
    for {
        record, n, err := csv.read_from_string(s)
        if csv.is_io_error(err, .EOF) {
            break
        }
        if err != nil {
            return
        }
        append(&records, record)
        s = s[n:]
    }
    fmt.println(records[123])
}

entry_point3 :: proc() {
    growing_arena : mem_virtual.Growing_Arena
    mem_virtual.arena_init(&growing_arena)
    defer mem_virtual.arena_destroy(&growing_arena)
    growing_arena_allocator := mem_virtual.growing_arena_allocator(&growing_arena)
    context.allocator = growing_arena_allocator

    data, ok := os.read_entire_file(csv_file_name)
    defer delete(data)

    if !ok {
        fmt.println("Could not read file")
        return
    }

    rows: [dynamic][]string
    read_offset: int
    for {
        record, n, err := csv.read_from_string(string(data[read_offset:]))
        if csv.is_io_error(err, .EOF) {
            break
        }
        if err != nil {
            return
        }
        append(&rows, record)
        read_offset += n
    }

    fmt.println(rows[123])
}

Property_Type :: enum {
    Detached,
    Semi_Detached,
    Terraced,
    Flat,
}

Duration_Of_Transfer :: enum {
    Freehold,
    Leasehold,
}

Price_Paid :: struct {
    id: string,
    price: int,
    date: string,
    postcode: string,
    property_type: Property_Type,
    old: bool,
    duration: Duration_Of_Transfer,
    primary_name: string, // for example, the house number or name
    secondary_name: string, // for example, flat number
    street: string,
    locality: string,
    town: string,
    district: string,
    county: string,
}

import bs "big_sheet"

sheet_demo :: proc() {
	data, ok := os.read_entire_file(csv_file_name)
	defer delete(data)

    growing_arena : mem_virtual.Growing_Arena
    mem_virtual.arena_init(&growing_arena)
    defer mem_virtual.arena_destroy(&growing_arena)
    growing_arena_allocator := mem_virtual.growing_arena_allocator(&growing_arena)
    context.allocator = mem_virtual.growing_arena_allocator(&growing_arena)

    price_paid_entries : [dynamic]^Price_Paid
    lines : [dynamic]string

    s := string(data)
	for line in strings.split_lines_iterator(&s) {
        cols := strings.split(line[1:len(line)-1], "\",\"", context.temp_allocator)

        tmp := strings.join(cols, ",")
        append(&lines, tmp)
        // append(&lines, strings.join({"[", tmp, "]"}, ""))

        // entry := new(Price_Paid)
        // entry.id = strings.clone(cols[0])
        // entry.price = strconv.parse_int(cols[1], 10) or_else 0
        // entry.date = strings.clone(cols[2])
        // entry.postcode = strings.clone(cols[3])
        // entry.property_type = parse_property_type(cols[4])
        // entry.old = cols[5] == "Y"
        // entry.duration = parse_duration_of_transfer(cols[6])
        // entry.primary_name = strings.clone(cols[7])
        // entry.secondary_name = strings.clone(cols[8])
        // entry.street = strings.clone(cols[9])
        // entry.locality = strings.clone(cols[10])
        // entry.town = strings.clone(cols[11])
        // entry.district = strings.clone(cols[12])
        // entry.district = strings.clone(cols[13])
        // append(&price_paid_entries, entry)

        // fmt.println(cols)
        // fmt.println(entry)
    }

    fmt.println("Number of entries:", len(price_paid_entries))
    fmt.println(price_paid_entries[:3])

    // nv := bs.Sheet{}
    // fmt.println(nv)

	// parse_start := time.now()
	// sheet, err := bs.new_sheet_from_csv_file("/Users/vitaly/pp-complete.csv")
	// parse_time := time.since(parse_start)

	// if err != nil {
	// 	fmt.printf("Encountered error: %v\n", err)
	// 	bs.destroy(sheet)
	// 	return
	// }
	// fmt.printf(
	// 	"Parsed %v rows x %v cols in %v seconds.\n",
	// 	sheet.rows,
	// 	sheet.cols,
	// 	time.duration_seconds(parse_time),
	// )

	// // Validate
	// validate_start := time.now()
	// for row in 1 ..= sheet.rows {
	// 	for col_name, col_idx in sheet.name_index {
	// 		v, _ := bs.get_int(sheet, row, col_name)
	// 		if v != row * sheet.cols + col_idx {
	// 			fmt.println("Got:", v, "Expected:", row * sheet.cols + col_idx)
	// 			return
	// 		}
	// 	}
	// }
	// validate_time := time.since(validate_start)
	// fmt.printf(
	// 	"Validated %v rows x %v cols (%v cells) in %v seconds.\n",
	// 	sheet.rows,
	// 	sheet.cols,
	// 	sheet.rows * sheet.cols,
	// 	time.duration_seconds(validate_time),
	// )
}

parse_property_type :: proc(s: string) -> Property_Type {
    switch s {
        case "D":
            return .Detached
        case "S":
            return .Semi_Detached
        case "T":
            return .Terraced
        case "F":
            return .Flat
        case:
            return .Detached
    }
}

parse_duration_of_transfer :: proc(s: string) -> Duration_Of_Transfer {
    switch s {
        case "F":
            return .Freehold
        case "L":
            return .Leasehold
        case:
            return .Freehold
    }
}

arena_test :: proc() {
    // arena : mem.Arena
    // backing := make([]byte, mem.Kilobyte * 10)
    // mem.arena_init(&arena, backing)
    // defer delete(backing)

    {
        growing_arena : mem_virtual.Growing_Arena
        mem_virtual.arena_init(&growing_arena)
        defer mem_virtual.arena_destroy(&growing_arena)
        context.allocator = mem_virtual.growing_arena_allocator(&growing_arena)
        fmt.println(context.allocator)
    }

    // growing_arena : virtual.Growing_Arena
    // virtual.growing_arena_init(&growing_arena)
    // defer virtual.growing_arena_destroy(&growing_arena)

    // data, err := virtual.growing_arena_alloc(&growing_arena, 10000, 8)
    // fmt.println("size of data is", len(data))
    // fmt.println("growing_arena", growing_arena)
    // data, err = virtual.growing_arena_alloc(&growing_arena, 2000000, 8)
    // fmt.println("size of data is", len(data))
    // fmt.println("growing_arena", growing_arena)
    // if err != .None {
    //     fmt.println("error", err)
    // }

    //somewhere else in the program I want to use the arenas
    // {
    //     context.allocator = mem.arena_allocator(&arena)
    // }
}

/*

__m128i sse_newline = _mm_set1_epi8('\n');
__m128i sse_quotechar = _mm_set1_epi8(quotechar);
__m128i sse_escapechar = _mm_set1_epi8(escapechar);
int max_simd = buffer_size - 16; // avoid reading past the buffer end due to SIMD
for (; i < buffer_size; i++){
    for (; i < max_simd; i += 16){
        // Load 16 bytes of the CSV in the SSE registers
        __m128i *sse_p = (__m128i *)&buffer[i];
        __m128i sse_a = _mm_loadu_si128(sse_p);
        // compare the 16 bytes to quotechar, and compact the result in the first 16 bits of mask_quoted
        int mask_quoted = _mm_movemask_epi8(_mm_cmpeq_epi8(sse_quotechar, sse_a));
        // compare against the newline
        int mask_newline = _mm_movemask_epi8(_mm_cmpeq_epi8(sse_newline, sse_a));
        int mask = mask_quoted | mask_newline;
        if (escapechar){
            // compare against the escapechar
            mask |= _mm_movemask_epi8(_mm_cmpeq_epi8(sse_escapechar, sse_a));
        }
        if (mask != 0){
            // there is at least one special character in the 16 bytes
            if (mask == mask_quoted){
                // the only special characters are quotes
                // we simply can count the number of quotes
                // the quoting state will change if this count is an odd number
                int quotes = __builtin_popcount(mask_quoted);
                state = (state + quotes) % 2;
            } else if (mask == mask_newline) {
                // the only special characters are newlines
                if (state == NORMAL) {
                    // and we were outside quotes
                    // the last bit set to '1' in the mask indicates where the last line was found
                    last_new_line_found = i + (31 - __builtin_clz(mask));
                }
            } else {
                // there is a complex combination of special characters
                // however, we can advance `i` by the number of initial bits on the mask that are set
                // to '0'
                i += __builtin_ctz(mask);
                break;
            }
        }
    }
    if (buffer[i] == quotechar){
        state = !state;
    } else if (state == NORMAL && buffer[i] == '\n') {
        last_new_line_found = i;
    } else if (buffer[i] == escapechar) {
        i++;
    }
}

*/