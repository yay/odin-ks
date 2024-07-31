package main

import "../mem_leaks"
import "base:runtime"
import "base:intrinsics"
import "core:fmt"
import "core:math"
import CF "core:sys/darwin/CoreFoundation"
import NS "core:sys/darwin/Foundation"

// @(require)
// foreign import "system:Cocoa.framework"

// Odin language overview:
// https://odin-lang.org/docs/overview/

main :: proc() {
	mem_leaks.track(run)
}

// Calls here rely on [`objc_msgsend`](https://developer.apple.com/documentation/objectivec/1456712-objc_msgsend/)
// that sends a message with a simple return value to an instance of a class:
//
// ```
// objc_msgsend(self, op, ...)
// ```
//
// - self - A pointer that points to the instance of the class that is to receive the message.
// - op - The selector (basically name) of the method that handles the message.
// - ... - A variable argument list containing the arguments to the method.
//
// `objc_msgsend` is not called directly, rather Odin's `msgSend` is used instead.
//
// ```
// msgSend(type, self, op, ...)
//
// Application_run :: proc "c" (self: ^Application) {
//     msgSend(nil, self, "run")
// }
//
// Application_isRunning :: proc "c" (self: ^Application) -> BOOL {
// 	   return msgSend(BOOL, self, "isRunning")
// }
// ```
//
// From gingerBill: msgSend internally generates a procedure type from the arguments passed.
run :: proc() {
	// An object that supports Cocoa’s reference-counted memory management system.
	// An autorelease pool stores objects that are sent a release message when the pool itself is drained.
	// If you use Automatic Reference Counting (ARC), you cannot use autorelease pools directly.
	// Instead, you use @autoreleasepool blocks (in Objective C).
	// Cocoa expects there to be an autorelease pool always available. If you send an `autorelease` message
	// outside of an autorelease pool block, Cocoa logs a suitable error message.
	// https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/MemoryMgmt/Articles/mmAutoreleasePools.html
	// https://developer.apple.com/documentation/foundation/nsautoreleasepool
	// https://developer.apple.com/documentation/os/logging/viewing_log_messages?language=objc
	// https://useyourloaf.com/blog/fetching-oslog-messages-in-swift/
	NS.scoped_autoreleasepool()
	// Abbreviations:
	// NS = NextStep
	// CF = Core Foundation

	// Core Foundation is a relatively low-level framework that does some of the same things
	// that Foundation does, but is written in C, instead of Objective-C.

	// An object that manages an app’s main event loop and resources used by all of that app’s objects.
	// Returns the application instance, creating it if it doesn’t exist yet.
	// This method also makes a connection to the window server and completes other initialization.
	// Your program should invoke this method as one of the first statements in main().
	// https://developer.apple.com/documentation/appkit/nsapplication?language=objc
	// https://developer.apple.com/documentation/appkit/nsapplication/1428360-shared
	app := NS.Application.sharedApplication()
	// The application is an ordinary app that appears in the Dock and may have a user interface.
	// https://developer.apple.com/documentation/appkit/nsapplication/activationpolicy
	if (!app->setActivationPolicy(.Regular)) do return

	// A delegate is an object that is notified when the app starts or terminates, is hidden or activated,
	// should open a file selected by the user, and so forth. By setting the delegate and implementing
	// the delegate methods, you customize the behavior of your app without having to subclass NSApplication.
	app_delegate := NS.application_delegate_register_and_alloc({
		applicationShouldTerminateAfterLastWindowClosed = proc(
			_: ^NS.Application,
		) -> NS.BOOL {return true},
		applicationShouldTerminate = proc(
			_: ^NS.Application,
		) -> NS.ApplicationTerminateReply { return .TerminateNow },
	}, "AppDelegate", context)

	app->setDelegate(app_delegate)

	create_main_menu(app)

	screen_rect := get_main_screen_rect()

	window_size := NS.Size{500, 400}
	window_origin: NS.Point =  {
		NS.Float(math.floor(f64(screen_rect.size.width - window_size.width) / 2)),
		NS.Float(math.floor(f64(screen_rect.size.height - window_size.height) / 2)),
	}

	// https://developer.apple.com/documentation/appkit/nswindow/1419477-initwithcontentrect
	window := NS.Window.alloc()->initWithContentRect(
		{window_origin, window_size},
		{.Titled, .Closable, .Resizable},
		// The window renders all drawing into a display buffer and then flushes it to the screen.
		// The other values (such as drawing directly to the screen) have been deprecated.
		.Buffered,
		// Whether the window server should defer creating a window device for the window
		// until it's moved onscreen.
		false,
	)
	window->setTitle(ns_str("NSWindow"))
	window->makeKeyAndOrderFront(nil)

	app->activate()

	app->run()
}

ns_str :: proc(str: string) -> ^NS.String {
	return NS.String.alloc()->initWithOdinString(str)
}

create_main_menu :: proc(app: ^NS.Application) {
	main_menu := NS.Menu.alloc()->init()
	main_menu_app_item := main_menu->addItemWithTitle(ns_str(""), nil, ns_str(""))
	main_menu_edit_item := main_menu->addItemWithTitle(ns_str("Edit"), nil, ns_str(""))

	app_menu := NS.Menu.alloc()->init()
	app_menu->addItemWithTitle(ns_str("Quit"), intrinsics.objc_find_selector("terminate:"), ns_str("q"))

	edit_menu := NS.Menu.alloc()->init()

	main_menu_app_item->setSubmenu(app_menu)
	main_menu_edit_item->setSubmenu(edit_menu)

	app->setMainMenu(main_menu)
}

get_main_screen_rect :: proc() -> NS.Rect {
	the_screen: NS.Screen
	main_screen := the_screen.mainScreen()

	return main_screen->visibleFrame()
}

list_screens :: proc() {
	// https://developer.apple.com/documentation/appkit/nsscreen?language=objc
	the_screen: NS.Screen
	screens := the_screen.screens() // NSArray
	screen_count := screens->count()

	for i in 0 ..< screen_count {
		screen := screens->objectAs(i, ^NS.Screen)

		fmt.printf("\nScreen: %v\n", i)
		fmt.println("\n\tdepth:", screen->depth())
		fmt.printf("\tframe: %v\n\n", screen->visibleFrame())
	}
}
