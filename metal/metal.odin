package main

import "../mem_leaks"
import "base:runtime"
import "base:intrinsics"
import "core:fmt"
import "core:os"
import "core:math"
import CF "core:sys/darwin/CoreFoundation"
import NS "core:sys/darwin/Foundation"
import MTL "vendor:darwin/Metal"
import CA  "vendor:darwin/QuartzCore"

@(require)
foreign import "system:Cocoa.framework"

main :: proc() {
	mem_leaks.track(run)
}

run :: proc() {
	NS.scoped_autoreleasepool()

	app := NS.Application.sharedApplication()
	if (!app->setActivationPolicy(.Regular)) do return

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
	window := NS.Window.alloc()->initWithContentRect(
		{window_origin, window_size},
		{.Titled, .Closable, .Resizable},
		.Buffered,
		false,
	)
	window->setTitle(ns_str("Metal"))
	window->makeKeyAndOrderFront(nil)

	app->activate()
	app->run()

	run_metal(app, window)
}

run_metal :: proc(app: ^NS.Application, window: ^NS.Window) {
	device := MTL.CreateSystemDefaultDevice()
	defer device->release()

	fmt.println(device->name()->odinString())

	swapchain := CA.MetalLayer.layer()
	defer swapchain->release()

	swapchain->setDevice(device)
	swapchain->setPixelFormat(.BGRA8Unorm_sRGB)
	swapchain->setFramebufferOnly(true)
	swapchain->setFrame(window->frame())

	window->contentView()->setLayer(swapchain)
	window->setOpaque(true)
	window->setBackgroundColor(nil)

	command_queue := device->newCommandQueue()
	defer command_queue->release()

	fmt.println("lol")
	for {
		event := app->nextEventMatchingMask(NS.EventMaskAny, nil, NS.DefaultRunLoopMode, true)
		if event == nil do break
		app->sendEvent(event)

		drawable := swapchain->nextDrawable()
		assert(drawable != nil)
		defer drawable->release()

		pass := MTL.RenderPassDescriptor.renderPassDescriptor()
		defer pass->release()

		color_attachment := pass->colorAttachments()->object(0)
		assert(color_attachment != nil)
		color_attachment->setClearColor(MTL.ClearColor{0.25, 0.5, 1.0, 1.0})
		color_attachment->setLoadAction(.Clear)
		color_attachment->setStoreAction(.Store)
		color_attachment->setTexture(drawable->texture())


		command_buffer := command_queue->commandBuffer()
		defer command_buffer->release()

		render_encoder := command_buffer->renderCommandEncoderWithDescriptor(pass)
		defer render_encoder->release()

		render_encoder->endEncoding()

		command_buffer->presentDrawable(drawable)
		command_buffer->commit()
	}
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