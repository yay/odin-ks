package main

import NS "vendor:darwin/Foundation"

@(require)
foreign import "system:Cocoa.framework"

main :: proc() {
	NS.scoped_autoreleasepool()

	app := NS.Application.sharedApplication()
	app->setActivationPolicy(.Regular)

	window := NS.Window.alloc()->initWithContentRect({{100, 100}, {500, 400}},
	{.Titled, .Closable, .Resizable},
	.Buffered,
	false)
	window->makeKeyAndOrderFront(nil)

	app->activateIgnoringOtherApps(true)

	app->run()
}
