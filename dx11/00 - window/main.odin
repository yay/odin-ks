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
	hInstance := HINSTANCE(GetModuleHandleW(nil))
	assert(hInstance != nil)

	hwnd: windows.HWND
	{
		winClass := WNDCLASSEXW {
			cbSize        = size_of(WNDCLASSEXW),
			style         = CS_HREDRAW | CS_VREDRAW,
			lpfnWndProc   = WndProc,
			hInstance     = hInstance,
			hIcon         = LoadIconW(nil, ([^]u16)(_IDI_APPLICATION)),
			hCursor       = LoadCursorW(nil, ([^]u16)(_IDC_ARROW)),
			lpszClassName = windows.L("MyWindowClass"),
			hIconSm       = LoadIconW(nil, ([^]u16)(_IDI_APPLICATION)),
		}
		if (RegisterClassExW(&winClass) == 0) {
			MessageBoxW(nil, windows.L("RegisterClassEx failed"), nil, MB_OK)
			print_error(GetLastError())
			return
		}

		initialRect := RECT{0, 0, 1024, 768}
		AdjustWindowRectEx(&initialRect, WS_OVERLAPPEDWINDOW, FALSE, WS_EX_OVERLAPPEDWINDOW)
		initialWidth: LONG = initialRect.right - initialRect.left
		initialHeight: LONG = initialRect.bottom - initialRect.top

		hwnd = CreateWindowExW(
			WS_EX_OVERLAPPEDWINDOW,
			winClass.lpszClassName,
			windows.L("00. Opening a Win32 Window"),
			WS_OVERLAPPEDWINDOW | WS_VISIBLE,
			CW_USEDEFAULT,
			CW_USEDEFAULT,
			initialWidth,
			initialHeight,
			nil,
			nil,
			hInstance,
			nil,
		)

		if (hwnd == nil) {
			MessageBoxW(nil, windows.L("CreateWindowEx failed"), nil, MB_OK)
			print_error(GetLastError())
			return
		}
	}

	isRunning := true

	for isRunning {
		message: MSG
		for PeekMessageW(&message, nil, 0, 0, PM_REMOVE) {
			if (message.message == WM_QUIT) {
				isRunning = false
			}
			TranslateMessage(&message)
			DispatchMessageW(&message)
		}
		time.sleep(1 * time.Millisecond)
	}
}

print_error :: proc(error: windows.DWORD) {
	using windows
	size: u32 = 4096
	data_pointer := make([^]u16, size)
	data := data_pointer[:size]
	defer delete(data)

	len := FormatMessageW(
		FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
		nil,
		error,
		0,
		data_pointer,
		size,
		nil,
	)

	msg, err := utf16_to_utf8(data)
	if err != .None {
		fmt.println("String conversion error:", err)
	}

	fmt.print("Error:", msg)
}

WndProc :: proc "system" (
	hwnd: windows.HWND,
	msg: windows.UINT,
	wparam: windows.WPARAM,
	lparam: windows.LPARAM,
) -> windows.LRESULT {
	using windows
	result: LRESULT

	switch (msg) {
	case WM_KEYDOWN:
		if (wparam == VK_ESCAPE) {
			DestroyWindow(hwnd)
		}
	case WM_DESTROY:
		PostQuitMessage(0)
	case:
		result = DefWindowProcW(hwnd, msg, wparam, lparam)
	}

	return result
}
