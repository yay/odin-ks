package main

import "../../mem_leaks"
import "base:runtime"
import "core:fmt"
import "core:strconv"
import "core:sys/windows"
import "core:time"

main :: proc() {
	mem_leaks.track(run)
}

run :: proc() {
	using windows
	module_handle := HINSTANCE(GetModuleHandleW(nil))
	assert(module_handle != nil)

	window_class := WNDCLASSEXW {
		cbSize        = size_of(WNDCLASSEXW),
		style         = CS_HREDRAW | CS_VREDRAW,
		lpfnWndProc   = wnd_proc,
		hInstance     = module_handle,
		hIcon         = LoadIconW(nil, ([^]u16)(_IDI_APPLICATION)),
		hCursor       = LoadCursorW(nil, ([^]u16)(_IDC_ARROW)),
		lpszClassName = L("MyWindowClass"),
		hIconSm       = LoadIconW(nil, ([^]u16)(_IDI_APPLICATION)),
	}
	if (RegisterClassExW(&window_class) == 0) {
		MessageBoxW(nil, L("RegisterClassEx failed"), nil, MB_OK)
		print_error(GetLastError())
		return
	}

	initial_rect := RECT{0, 0, 1024, 768}
	AdjustWindowRectEx(&initial_rect, WS_OVERLAPPEDWINDOW, FALSE, WS_EX_OVERLAPPEDWINDOW)
	initial_width: LONG = initial_rect.right - initial_rect.left
	initial_height: LONG = initial_rect.bottom - initial_rect.top

	window_handle := CreateWindowExW(
		WS_EX_OVERLAPPEDWINDOW,
		window_class.lpszClassName,
		L("00. Opening a Win32 Window"),
		WS_OVERLAPPEDWINDOW | WS_VISIBLE,
		CW_USEDEFAULT,
		CW_USEDEFAULT,
		initial_width,
		initial_height,
		nil,
		nil,
		module_handle,
		nil,
	)

	if (window_handle == nil) {
		MessageBoxW(nil, L("Creating window failed"), nil, MB_OK)
		print_error(GetLastError())
		return
	}

	is_running := true

	for is_running {
		message: MSG
		for PeekMessageW(&message, nil, 0, 0, PM_REMOVE) {
			if (message.message == WM_QUIT) {
				is_running = false
			}
			TranslateMessage(&message)
			DispatchMessageW(&message)
		}
		time.sleep(1 * time.Millisecond)
	}
}

print_error :: proc(message_id: windows.DWORD) {
	using windows
	size: u32 = 4096
	data_pointer := make([^]u16, size)
	data := data_pointer[:size]
	defer delete(data)

	FormatMessageW(
		FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
		nil,
		message_id,
		0,
		data_pointer,
		size,
		nil,
	)

	message_str, err := utf16_to_utf8(data)
	if err != .None {
		fmt.println("String conversion error:", err)
	}

	fmt.print("Error:", message_str)
}

// Callback function that processes messages sent to a window.
// 'w' stands for 'word', and 'l' stands for 'long' (16-bit Windows legacy).
// Pointers are usually passed in LPARAM, whereas handles or integers in WPARAM.
wnd_proc :: proc "system" (
	window_handle: windows.HWND,
	message: windows.UINT,
	wparam: windows.WPARAM,
	lparam: windows.LPARAM,
) -> windows.LRESULT {
	using windows
	result: LRESULT

	switch (message) {
	case WM_KEYDOWN:
		if (wparam == VK_ESCAPE) {
			DestroyWindow(window_handle)
		}
	case WM_DESTROY:
		PostQuitMessage(0)
	case:
		result = DefWindowProcW(window_handle, message, wparam, lparam)
	}

	return result
}
