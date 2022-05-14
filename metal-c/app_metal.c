// How to build:
// # compile the metal shaders
// xcrun -sdk macosx metal -c shaders.metal -o shaders.air
// xcrun -sdk macosx metallib shaders.air -o shaders.metallib
// # compile the c file
// clang app_metal.c -framework Cocoa -framework Metal -o metal_c.app
//
//
// Draw a triangle using metal
// Metal tutorial followed here: https://www.raywenderlich.com/7475-metal-tutorial-getting-started

#include <objc/runtime.h>
#include <objc/message.h>

#include <Carbon/Carbon.h>

#define cls objc_getClass
#define sel sel_getUid

typedef id (*object_message_send)(id, SEL, ...);
typedef id (*class_message_send)(Class, SEL, ...);

#define msg ((object_message_send)objc_msgSend)
#define cls_msg ((class_message_send)objc_msgSend)

typedef id (*MethodImp)(id, SEL, ...);
typedef MethodImp (*get_method_imp)(Class, SEL);
#define method ((get_method_imp)class_getMethodImplementation)


// poor man's bindings!
void NSLog(id format, ...);
typedef enum NSApplicationActivationPolicy {
    NSApplicationActivationPolicyRegular,
    NSApplicationActivationPolicyAccessory,
    NSApplicationActivationPolicyERROR,
} NSApplicationActivationPolicy;

typedef enum NSWindowStyleMask {
    NSWindowStyleMaskBorderless     = 0,
    NSWindowStyleMaskTitled         = 1 << 0,
    NSWindowStyleMaskClosable       = 1 << 1,
    NSWindowStyleMaskMiniaturizable = 1 << 2,
    NSWindowStyleMaskResizable      = 1 << 3,
} NSWindowStyleMask;

typedef enum NSBackingStoreType {
    NSBackingStoreBuffered = 2,
} NSBackingStoreType;

// metal bindings
id MTLCreateSystemDefaultDevice();
typedef enum MTLPixelFormat {
    MTLPixelFormatBGRA8Unorm = 80,
    MTLPixelFormatRGBA8Unorm = 70,
} MTLPixelFormat;
typedef enum MTLCPUCacheMode {
    MTLCPUCacheModeDefaultCache = 0,
    MTLCPUCacheModeWriteCombined = 1,
} MTLCPUCacheMode;
#define MTLResourceCPUCacheModeShift 0
#define MTLResourceCPUCacheModeMask  (0xfUL << MTLResourceCPUCacheModeShift)
#define MTLResourceStorageModeShift  4
#define MTLResourceStorageModeMask   (0xfUL << MTLResourceStorageModeShift)
typedef enum MTLResourceOptions {
    MTLResourceCPUCacheModeDefaultCache  = MTLCPUCacheModeDefaultCache << MTLResourceCPUCacheModeShift,
    MTLResourceCPUCacheModeWriteCombined = MTLCPUCacheModeWriteCombined << MTLResourceCPUCacheModeShift,
} MTLResourceOptions;
typedef enum MTLLoadAction {
    MTLLoadActionDontCare = 0,
    MTLLoadActionLoad     = 1,
    MTLLoadActionClear    = 2,
} MTLLoadAction;
typedef struct MTLClearColor {
    double red;
    double green;
    double blue;
    double alpha;
} MTLClearColor;
typedef enum MTLPrimitiveType {
    MTLPrimitiveTypePoint         = 0,
    MTLPrimitiveTypeLine          = 1,
    MTLPrimitiveTypeLineStrip     = 2,
    MTLPrimitiveTypeTriangle      = 3,
    MTLPrimitiveTypeTriangleStrip = 4,
} MTLPrimitiveType;

Class NSString;
SEL stringWithUTF8String;

SEL init;
SEL alloc;
SEL name;

Class NSAutoreleasePool;
SEL drain;

Class NSApplication;

id NSDefaultRunLoopMode;

id nsstring(const char *str) {
    return cls_msg(NSString, stringWithUTF8String, str);
}

Class NSApp;
SEL selNextEvent;
MethodImp App_NextEvent_Imp;

void init_refs() {
    NSString = cls("NSString");
    stringWithUTF8String = sel("stringWithUTF8String:");

    NSApplication = cls("NSApplication");
    selNextEvent = sel("nextEventMatchingMask:untilDate:inMode:dequeue:");
    App_NextEvent_Imp = method(NSApplication, selNextEvent);

    NSAutoreleasePool = cls("NSAutoreleasePool");
    drain = sel("drain");

    init = sel("init");
    alloc = sel("alloc");
    name = sel("name");

    NSApplication = cls("NSApplication");

    NSDefaultRunLoopMode = nsstring("kCFRunLoopDefaultMode");
}

typedef struct AppData {
    id app;
    id window;

    // CAMetalLayer
    id metalLayer;

    // MTLCommandQueue
    id cmdQueue;

    // MTLRenderPipelineState
    id pipelineState;

    // MTLBuffer
    id vertexBuffer; // the thing the app wants to render for this frame
} AppData;

// app delegate bits from https://gist.github.com/andsve/2a154a82faa806b3b1d6d71f18a2ad24
Class AppDelegate;
Ivar AppDelegate_AppData;
SEL AppDelegate_windowObserve;
SEL AppDelegate_frameSel;

BOOL delegate_method_yes(id self, SEL cmd)
{
    return YES;
}

// self is AppDelegate instance
// NSNotification nsNotification
void on_window_notification(id self, SEL cmd, id nsNotification) {
    printf("window notification\n");
    id eventName = msg(nsNotification, name);
    NSLog(nsstring("event: %@"), eventName);
    // AppData *appData = (AppData *) object_getIvar(self, AppDelegate_AppData);

}

// displayLink: CADisplayLink
void render_frame(id self, SEL cmd, id displayLink) {
    // printf("self: %lx\n", (uintptr_t) self);
    AppData *appData = (AppData *) object_getIvar(self, AppDelegate_AppData);
    // printf("appData: %lx\n", (uintptr_t) appData);

    id autoreleasePool = msg(cls_msg(NSAutoreleasePool, alloc), init);
    {
        // read events
        id event = App_NextEvent_Imp(appData->app, selNextEvent, INT_MAX, 0, NSDefaultRunLoopMode, 1);
        if (event) {
            printf("event: %lx\n", (uintptr_t) event);
            // TODO!
        }

        // draw with metal
        {
            id drawable = msg(appData->metalLayer, sel("nextDrawable"));
            // MTLRenderPassDescriptor
            id renderPassDesc = cls_msg(cls("MTLRenderPassDescriptor"), sel("renderPassDescriptor"));
            // renderPassDesc.colorAttachments[0]
            id renderPassColor0 = msg(msg(renderPassDesc, sel("colorAttachments")), sel("objectAtIndexedSubscript:"), 0);
            msg(renderPassColor0, sel("setTexture:"), msg(drawable, sel("texture")));
            msg(renderPassColor0, sel("setLoadAction:"), MTLLoadActionClear);
            msg(renderPassColor0, sel("setClearColor:"), (MTLClearColor) { .red = 0, .green = 104.0/255.0, .blue = 55.0/255.0, .alpha = 1.0 });

            // MTLCommandBuffer
            id cmdBuffer = msg(appData->cmdQueue, sel("commandBuffer"));
            id cmdEnc = msg(cmdBuffer, sel("renderCommandEncoderWithDescriptor:"), renderPassDesc);
            msg(cmdEnc, sel("setRenderPipelineState:"), appData->pipelineState);
            msg(cmdEnc, sel("setVertexBuffer:offset:atIndex:"), appData->vertexBuffer, 0, 0);
            msg(cmdEnc, sel("drawPrimitives:vertexStart:vertexCount:"), MTLPrimitiveTypeTriangle, 0, 3, 1);
            msg(cmdEnc, sel("endEncoding"));

            msg(cmdBuffer, sel("presentDrawable:"), drawable);
            msg(cmdBuffer, sel("commit"));
        }
    }
    msg(autoreleasePool, drain);
}

static void init_delegate_class()
{
    AppData app_data_instance;
    AppDelegate = objc_allocateClassPair(objc_getClass("NSObject"), "AppDelegate", 0);
    AppDelegate_windowObserve = sel("windowObserve:");
    AppDelegate_frameSel = sel("frame:");
    class_addMethod(AppDelegate, sel("applicationShouldTerminateAfterLastWindowClosed:"), (IMP) delegate_method_yes, "B@:");
    class_addMethod(AppDelegate, AppDelegate_windowObserve, (IMP) on_window_notification, "v@:@");
    class_addMethod(AppDelegate, AppDelegate_frameSel, (IMP) render_frame, "v@:@");
    class_addIvar(AppDelegate, "app_data", sizeof(AppData *), log2(sizeof(AppData *)), "@");
    objc_registerClassPair(AppDelegate);
    AppDelegate_AppData = class_getInstanceVariable(AppDelegate, "app_data");
    printf("AppDelegate_AppData: %lx\n", (uintptr_t) AppDelegate_AppData);
}

int main(int argc, char *argv[])
{
    init_refs();
    init_delegate_class();

    AppData appData;

    // based on https://stackoverflow.com/a/30269562/35364

    // [NSApplication sharedApplication];
    id app = cls_msg(NSApplication, sel("sharedApplication"));
    appData.app = app;

    // [app setActivationPolicy:NSApplicationActivationPolicyRegular];
    SEL setActivationPolicy = sel("setActivationPolicy:");
    msg(app, setActivationPolicy, NSApplicationActivationPolicyRegular);


    struct CGRect frameRect = {0, 0, 600, 500};

    // id window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 120, 120)
    // styleMask:NSWindowStyleMaskTitled backing:NSBackingStoreBuffered defer:NO];
    Class NSWindow = cls("NSWindow");
    id window = msg(cls_msg(NSWindow, alloc), sel("initWithContentRect:styleMask:backing:defer:"),
                    frameRect, NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|NSWindowStyleMaskResizable, NSBackingStoreBuffered, false);
    appData.window = window;
    msg(window, sel("setTitle:"), nsstring("Pure C Metal"));

    // [window makeKeyAndOrderFront:nil];
    msg(window, sel("makeKeyAndOrderFront:"), nil);


    // [app activateIgnoringOtherApps:YES];
    SEL activateIgnoringOtherApps = sel("activateIgnoringOtherApps:");
    msg(app, activateIgnoringOtherApps, true);

    // id delegate = [[AppDelegate alloc] init]
    // [app setDelegate:delegate]
    id delegate = msg(cls_msg(AppDelegate, alloc), init);
    msg(app, sel("setDelegate:"), delegate);

    object_setIvar(delegate, AppDelegate_AppData, (id) &appData);

    // get the content view and add a metal layer to it!
    // id view = [window contentView];
    id view = msg(window, sel("contentView"));
    printf("view: %lx\n", (uintptr_t) view);
    NSLog(nsstring("contentView: %@\n"), view);
    msg(view, sel("setFrame:"), frameRect);

    msg(view, sel("setWantsLayer:"), YES); // otherwise there will be no layer!
    id viewLayer = msg(view, sel("layer"));
    // printf("viewLayer: %lx\n", (uintptr_t) viewLayer);
    // NSLog(nsstring("layer: %@\n"), viewLayer);

    id metalDevice = MTLCreateSystemDefaultDevice();
    printf("metalDevice: %lx\n", (uintptr_t) metalDevice);

    Class CAMetalLayer = cls("CAMetalLayer");
    id metalLayer = cls_msg(CAMetalLayer, sel("layer"));
    printf("metalLayer: %lx\n", (uintptr_t) metalLayer);
    appData.metalLayer = metalLayer;

    msg(metalLayer, sel("setDevice:"), metalDevice);
    msg(metalLayer, sel("setPixelFormat:"), MTLPixelFormatBGRA8Unorm);
    msg(metalLayer, sel("setFrame:"), frameRect);

    msg(viewLayer, sel("addSublayer:"), metalLayer);

    // draw a triangle
    float vertexData[] = {
       0.0,  1.0, 0.0,
      -1.0, -1.0, 0.0,
       1.0, -1.0, 0.0
    };

    // vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: []) // Swift version
    SEL makeBuffer = sel("newBufferWithBytes:length:options:");
    id vertexBuffer = msg(metalDevice, makeBuffer, vertexData, sizeof(vertexData), MTLResourceCPUCacheModeDefaultCache);
    appData.vertexBuffer = vertexBuffer;

    id metalLib = msg(metalDevice, sel("newLibraryWithFile:error:"), nsstring("shaders.metallib"), 0);
    printf("metalLib: %lx\n", (uintptr_t) metalLib);

    SEL newFunctionWithName = sel("newFunctionWithName:");
    id fragmentProgram = msg(metalLib, newFunctionWithName, nsstring("basic_fragment"));
    id vertexProgram = msg(metalLib, newFunctionWithName, nsstring("basic_vertex"));

    Class MTLRenderPipelineDescriptor = objc_getClass("MTLRenderPipelineDescriptor");
    id pipelineDesc = msg(cls_msg(MTLRenderPipelineDescriptor, alloc), init);
    printf("pipelineDesc: %lx\n", (uintptr_t) pipelineDesc);
    msg(pipelineDesc, sel("setFragmentFunction:"), fragmentProgram);
    msg(pipelineDesc, sel("setVertexFunction:"), vertexProgram);
    // piplineDesc.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm
    msg(
        msg(
            msg(pipelineDesc, sel("colorAttachments")),
            sel("objectAtIndexedSubscript:"),
            0
        ),
        sel("setPixelFormat:"),
        MTLPixelFormatBGRA8Unorm
    );
    printf("pipelineDesc: %lx\n", (uintptr_t) pipelineDesc);

    id pipelineState = msg(metalDevice, sel("newRenderPipelineStateWithDescriptor:error:"), pipelineDesc, 0);
    printf("pipelineState: %lx\n", (uintptr_t) pipelineState);
    appData.pipelineState = pipelineState;

    SEL newCommandQueue = sel("newCommandQueue");
    id cmdQueue = msg(metalDevice, newCommandQueue);
    printf("cmdQueue: %lx\n", (uintptr_t) cmdQueue);
    appData.cmdQueue = cmdQueue;

    Class CADisplayLink = cls("CADisplayLink");
    id timer = cls_msg(CADisplayLink, sel("displayLinkWithTarget:selector:"), delegate, AppDelegate_frameSel);
    msg(timer, sel("addToRunLoop:forMode:"),
        cls_msg(cls("NSRunLoop"), sel("mainRunLoop")), // NSRunLoop.mainRunLoop
        NSDefaultRunLoopMode);

    msg(app, sel("run"));

}