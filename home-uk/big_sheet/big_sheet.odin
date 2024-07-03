package big_sheet

import "base:runtime"
import "core:fmt"
import "core:io"
import "core:os"
import "core:strconv"
import "core:strings"

Cell :: struct {
	row_index: int,
	col_name:  string,
}

Row :: [dynamic]string

Sheet :: struct {
	cells:      [dynamic]Row `fmt:"-"`,
	rows:       int, // 1-indexed
	cols:       int, // 1-indexed
	name_index: map[string]int `fmt:"-"`,
	interner:   strings.Intern `fmt:"-"`,
	data:       []u8 `fmt:"-"`,
	transforms: Transform_Register,
}

Sheet_Error :: enum {
	Unable_To_Read_File,
	Invalid_Column_Count,
}

Error :: union {
	Sheet_Error,
	io.Error,
	runtime.Allocator_Error,
}

new_sheet :: proc(allocator := context.allocator) -> (sheet: ^Sheet) {
	context.allocator = allocator
	sheet = new(Sheet)
	strings.intern_init(&sheet.interner)
	return
}

/*
	Reads file into `sheet.data` and keeps it around.
	Cell contens are string views into the file data. This avoids extra allocations.

	We make two passes:
	- Count columns and store column names, count rows. Presize Cell map.
	- Read rows into Cell map.

	Doing this in one pass and having the Cell map resize as needed takes 1.5x as long.
*/
new_sheet_from_csv_file :: proc(
	filename: string,
	allocator := context.allocator,
) -> (
	sheet: ^Sheet,
	err: Error,
) {
	context.allocator = allocator

	data, ok := os.read_entire_file(filename)
	if !ok {
		return nil, .Unable_To_Read_File
	}

	sheet = new_sheet()
	sheet.data = data

	// Initial scan
	s := string(data)
	for line in strings.split_lines_iterator(&s) {
		if sheet.rows == 0 {
			// Grab headers
			cols := strings.split(line, ",", context.temp_allocator)
			sheet.cols = len(cols)
			for col, col_idx in cols {
				// Strip quotes from column names
				col_name := strings.trim(col, "\"")
				sheet.name_index[col_name] = col_idx + 1
			}
		}
		sheet.rows += 1
	}

	// Remove header row from row count
	sheet.rows -= 1

	// Allocate rows
	sheet.cells = make([dynamic]Row, sheet.rows)

	// Scan data into sheet.cells
	s = string(data)
	row_idx := 0
	for line in strings.split_lines_iterator(&s) {
		if row_idx == 0 {
			row_idx = 1
			continue
		}

		// Grab row values
		cols := strings.split(line, ",", context.temp_allocator)
		if len(cols) != sheet.cols {
			return sheet, .Invalid_Column_Count
		}
		sheet.cells[row_idx - 1] = make(Row, len(cols))

		for col, col_idx in cols {
			// Strip quotes from column values
			value := strings.trim(col, "\"")
			sheet.cells[row_idx - 1][col_idx] = value
		}
		row_idx += 1
	}
	return
}

destroy :: proc(sheet: ^Sheet) {
	assert(sheet != nil, "Must pass a valid ^Sheet")
	strings.intern_destroy(&sheet.interner)
	delete(sheet.name_index)

	for row in &sheet.cells {
		delete(row)
	}
	delete(sheet.cells)
	delete(sheet.data)
	delete(sheet.transforms)
	free(sheet)
}

// Accessors
get_by_index :: #force_inline proc(
	sheet: ^Sheet,
	row: int,
	col_idx: int,
) -> (
	res: string,
	ok: bool,
) {
	if row >= 1 && row <= sheet.rows && col_idx >= 1 && col_idx <= sheet.cols {
		return sheet.cells[row - 1][col_idx - 1], true
	}
	return {}, false
}

get_by_name :: #force_inline proc(
	sheet: ^Sheet,
	row: int,
	col_name: string,
) -> (
	res: string,
	ok: bool,
) {
	if col_idx, idx_ok := sheet.name_index[col_name]; idx_ok {
		return get(sheet, row, col_idx)
	}
	return {}, false
}

get :: proc {
	get_by_name,
	get_by_index,
}

get_int_by_index :: #force_inline proc(
	sheet: ^Sheet,
	row: int,
	col_idx: int,
) -> (
	res: int,
	ok: bool,
) {
	str, str_ok := get_by_index(sheet, row, col_idx)
	if !str_ok {
		return {}, false
	}
	res, ok = strconv.parse_int(str)
	return
}

get_int_by_name :: #force_inline proc(
	sheet: ^Sheet,
	row: int,
	col_name: string,
) -> (
	res: int,
	ok: bool,
) {
	if col_idx, idx_ok := sheet.name_index[col_name]; idx_ok {
		return get_int(sheet, row, col_idx)
	}
	return {}, false
}

get_int :: proc {
	get_int_by_name,
	get_int_by_index,
}

get_f64_by_index :: #force_inline proc(
	sheet: ^Sheet,
	row: int,
	col_idx: int,
) -> (
	res: f64,
	ok: bool,
) {
	str, str_ok := get_by_index(sheet, row, col_idx)
	if !str_ok {
		return {}, false
	}
	res, ok = strconv.parse_f64(str)
	return
}

get_f64_by_name :: #force_inline proc(
	sheet: ^Sheet,
	row: int,
	col_name: string,
) -> (
	res: f64,
	ok: bool,
) {
	if col_idx, idx_ok := sheet.name_index[col_name]; idx_ok {
		return get_f64(sheet, row, col_idx)
	}
	return {}, false
}

get_f64 :: proc {
	get_f64_by_name,
	get_f64_by_index,
}


set_string_by_index :: #force_inline proc(
	sheet: ^Sheet,
	row: int,
	col_idx: int,
	new_value: string,
) -> (
	ok: bool,
) {
	if row >= 1 && row <= sheet.rows && col_idx >= 1 && col_idx <= sheet.cols {
		val, _ := strings.intern_get(&sheet.interner, new_value)
		sheet.cells[row - 1][col_idx - 1] = val
	}
	return false
}

set_string_by_name :: #force_inline proc(
	sheet: ^Sheet,
	row: int,
	col_name: string,
	new_value: string,
) -> (
	ok: bool,
) {
	if row >= 1 && row <= sheet.rows {
		if col_idx, idx_ok := sheet.name_index[col_name]; idx_ok {
			val, _ := strings.intern_get(&sheet.interner, new_value)
			sheet.cells[row - 1][col_idx - 1] = val
		}
	}
	return false
}

set_f64_by_index :: #force_inline proc(
	sheet: ^Sheet,
	row: int,
	col_idx: int,
	new_value: f64,
	format := "%5.3f",
) -> (
	ok: bool,
) {
	val := fmt.tprintf(format, new_value)
	return set(sheet, row, col_idx, val)
}

set_f64_by_name :: #force_inline proc(
	sheet: ^Sheet,
	row: int,
	col_name: string,
	new_value: f64,
	format := "%5.3f",
) -> (
	ok: bool,
) {
	val := fmt.tprintf(format, new_value)
	return set(sheet, row, col_name, val)
}

set_int_by_index :: #force_inline proc(
	sheet: ^Sheet,
	row: int,
	col_idx: int,
	new_value: int,
	format := "%v",
) -> (
	ok: bool,
) {
	val := fmt.tprintf(format, new_value)
	return set(sheet, row, col_idx, val)
}

set_int_by_name :: #force_inline proc(
	sheet: ^Sheet,
	row: int,
	col_name: string,
	new_value: int,
	format := "%v",
) -> (
	ok: bool,
) {
	val := fmt.tprintf(format, new_value)
	return set(sheet, row, col_name, val)
}

set :: proc {
	set_string_by_name,
	set_string_by_index,
	set_f64_by_name,
	set_f64_by_index,
	set_int_by_name,
	set_int_by_index,
}


/*
	Adds column
*/
add_column :: proc(sheet: ^Sheet, column_name: string) -> (ok: bool) {
	assert(sheet != nil)

	// Column name already in use
	if column_name in sheet.name_index {
		return false
	}

	name, _ := strings.intern_get(&sheet.interner, column_name)

	sheet.cols += 1
	sheet.name_index[name] = sheet.cols

	for row in &sheet.cells {
		resize(&row, sheet.cols)
	}
	return
}

// Process
Transform_Register :: map[int]Transform

Transform :: union {
	proc(sheet: ^Sheet, value: string),
	proc(sheet: ^Sheet, value: f64),
	proc(sheet: ^Sheet, value: int),
}

register :: proc(sheet: ^Sheet, col_name: string, transform: Transform) -> (ok: bool) {
	// Does the column name exist? If so, grab index.
	idx := sheet.name_index[col_name] or_return

	if idx in sheet.transforms {
		return false // Column already has a transform registered.
	}
	sheet.transforms[idx] = transform
	return true
}

perform_transforms :: proc(sheet: ^Sheet) -> (ok: bool) {
	for row in 1 ..= sheet.rows {
		for col_idx in sheet.transforms {
			switch v in sheet.transforms[col_idx] {
			case proc(sheet: ^Sheet, value: string):
				cell_value := get(sheet, row, col_idx) or_return
				v(sheet, cell_value)
			case proc(sheet: ^Sheet, value: f64):
				cell_value := get_f64(sheet, row, col_idx) or_return
				v(sheet, cell_value)
			case proc(sheet: ^Sheet, value: int):
				cell_value := get_int(sheet, row, col_idx) or_return
				v(sheet, cell_value)
			case:
			}
		}
	}
	return true
}
