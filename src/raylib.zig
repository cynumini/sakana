const std = @import("std");

const c = @import("raylib_c");
const Backend = @import("sakana").user_interface.Backend;

// cdef -----------------------------------------------------------------------
/// Since I want extend stuct, any function that will use this extand struct,
/// must be redefined by me
const ABI = struct {
    pub const ConfigFlags = enum(c_int) {
        vsync_hint = 0x00000040, // 344
        fullscreen_mode = 0x00000002, // 345
        window_resizable = 0x00000004, // 346
        window_undecorated = 0x00000008, // 347
        window_hidden = 0x00000080, // 348
        window_minimized = 0x00000200, // 349
        window_maximized = 0x00000400, // 350
        window_unfocused = 0x00000800, // 351
        window_topmost = 0x00001000, // 352
        window_always_run = 0x00000100, // 353
        window_transparent = 0x00000010, // 354
        window_highdpi = 0x00002000, // 355
        window_mouse_passthrough = 0x00004000, // 356
        borderless_windowed_mode = 0x00008000, // 357
        msaa_4x_hint = 0x00000020, // 358
        interlaced_hint = 0x00010000, // 359
    };

    pub extern fn ClearBackground(color: Color) void; // 730
    pub extern fn DrawRectangleRec(rec: Rectangle, color: Color) void; // 909
};
// Adaptations ----------------------------------------------------------------
/// Vector2, 2 components
pub const Vector2 = extern struct { // 66
    /// Vector x component
    x: f32,
    /// Vector y component
    y: f32,

    pub const zero = Vector2{.x = 0, .y = 0};
};
/// Color, 4 components, R8G8B8A8 (32bit)
pub const Color = extern struct { // 104
    /// Color red value
    r: u8,
    /// Color green value
    g: u8,
    /// Color blue value
    b: u8,
    /// Color alpha value
    a: u8,
    // Custom raylib color palette for amazing visuals on WHITE background
    /// Light Gray
    pub const light_gray = Color{ .r = 200, .g = 200, .b = 200, .a = 255 };
    /// Gray
    pub const gray = Color{ .r = 130, .g = 130, .b = 130, .a = 255 };
    /// Dark Gray
    pub const dark_gray = Color{ .r = 80, .g = 80, .b = 80, .a = 255 };
    /// Yellow
    pub const yellow = Color{ .r = 253, .g = 249, .b = 0, .a = 255 };
    /// Gold
    pub const gold = Color{ .r = 255, .g = 203, .b = 0, .a = 255 };
    /// Orange
    pub const orange = Color{ .r = 255, .g = 161, .b = 0, .a = 255 };
    /// Pink
    pub const pink = Color{ .r = 255, .g = 109, .b = 194, .a = 255 };
    /// Red
    pub const red = Color{ .r = 230, .g = 41, .b = 55, .a = 255 };
    /// Maroon
    pub const maroon = Color{ .r = 190, .g = 33, .b = 55, .a = 255 };
    /// Green
    pub const green = Color{ .r = 0, .g = 228, .b = 48, .a = 255 };
    /// Lime
    pub const lime = Color{ .r = 0, .g = 158, .b = 47, .a = 255 };
    /// Dark Green
    pub const dark_green = Color{ .r = 0, .g = 117, .b = 44, .a = 255 };
    /// Sky Blue
    pub const sky_blue = Color{ .r = 102, .g = 191, .b = 255, .a = 255 };
    /// Blue
    pub const blue = Color{ .r = 0, .g = 121, .b = 241, .a = 255 };
    /// Dark Blue
    pub const dark_blue = Color{ .r = 0, .g = 82, .b = 172, .a = 255 };
    /// Purple
    pub const purple = Color{ .r = 200, .g = 122, .b = 255, .a = 255 };
    /// Violet
    pub const violet = Color{ .r = 135, .g = 60, .b = 190, .a = 255 };
    /// Dark Purple
    pub const dark_purple = Color{ .r = 112, .g = 31, .b = 126, .a = 255 };
    /// Beige
    pub const beige = Color{ .r = 211, .g = 176, .b = 131, .a = 255 };
    /// Brown
    pub const brown = Color{ .r = 127, .g = 106, .b = 79, .a = 255 };
    /// Dark Brown
    pub const dark_brown = Color{ .r = 76, .g = 63, .b = 47, .a = 255 };

    /// White
    pub const white = Color{ .r = 255, .g = 255, .b = 255, .a = 255 };
    /// Black
    pub const black = Color{ .r = 0, .g = 0, .b = 0, .a = 255 };
    /// Blank (Transparent)
    pub const blank = Color{ .r = 0, .g = 0, .b = 0, .a = 0 };
    /// Magenta
    pub const magenta = Color{ .r = 255, .g = 0, .b = 255, .a = 255 };
    /// My own White (raylib logo)
    pub const ray_white = Color{ .r = 245, .g = 245, .b = 245, .a = 255 };
};
/// Rectangle, 4 components
pub const Rectangle = extern struct { // 111
    /// Rectangle top-left corner position x
    x: f32,
    /// Rectangle top-left corner position y
    y: f32,
    /// Rectangle width
    width: f32,
    /// Rectangle height
    height: f32,

    pub const zero = Rectangle{ .x = 0, .y = 0, .width = 0, .height = 0 };
};
/// System/Window config flags
/// By default all flags are set to false
pub const ConfigFlags = struct { // 344
    /// Set to try enabling V-Sync on GPU
    vsync_hint: bool = false,
    /// Set to run program in fullscreen
    fullscreen_mode: bool = false,
    /// Set to allow resizable window
    window_resizable: bool = false,
    /// Set to disable window decoration (frame and buttons)
    window_undecorated: bool = false,
    /// Set to hide window
    window_hidden: bool = false,
    /// Set to minimize window (iconify)
    window_minimized: bool = false,
    /// Set to maximize window (expanded to monitor)
    window_maximized: bool = false,
    /// Set to window non focused
    window_unfocused: bool = false,
    /// Set to window always on top
    window_topmost: bool = false,
    /// Set to allow windows running while minimized
    window_always_run: bool = false,
    /// Set to allow transparent framebuffer
    window_transparent: bool = false,
    /// Set to support HighDPI
    window_highdpi: bool = false,
    /// Set to support mouse passthrough, only supported when FLAG_WINDOW_UNDECORATED
    window_mouse_passthrough: bool = false,
    /// Set to run program in borderless windowed mode
    borderless_windowed_mode: bool = false,
    /// Set to try enabling MSAA 4X
    msaa_4x_hint: bool = false,
    /// Set to try enabling interlaced video format (for V3D)
    interlaced_hint: bool = false,

    pub fn toC(self: ConfigFlags) c_uint {
        var result: c_uint = 0;
        if (self.vsync_hint) result |= @intFromEnum(ABI.ConfigFlags.vsync_hint);
        if (self.fullscreen_mode) result |= @intFromEnum(ABI.ConfigFlags.fullscreen_mode);
        if (self.window_resizable) result |= @intFromEnum(ABI.ConfigFlags.window_resizable);
        if (self.window_undecorated) result |= @intFromEnum(ABI.ConfigFlags.window_undecorated);
        if (self.window_hidden) result |= @intFromEnum(ABI.ConfigFlags.window_hidden);
        if (self.window_minimized) result |= @intFromEnum(ABI.ConfigFlags.window_minimized);
        if (self.window_maximized) result |= @intFromEnum(ABI.ConfigFlags.window_maximized);
        if (self.window_unfocused) result |= @intFromEnum(ABI.ConfigFlags.window_unfocused);
        if (self.window_topmost) result |= @intFromEnum(ABI.ConfigFlags.window_topmost);
        if (self.window_always_run) result |= @intFromEnum(ABI.ConfigFlags.window_always_run);
        if (self.window_transparent) result |= @intFromEnum(ABI.ConfigFlags.window_transparent);
        if (self.window_highdpi) result |= @intFromEnum(ABI.ConfigFlags.window_highdpi);
        if (self.window_mouse_passthrough) result |= @intFromEnum(ABI.ConfigFlags.window_mouse_passthrough);
        if (self.borderless_windowed_mode) result |= @intFromEnum(ABI.ConfigFlags.borderless_windowed_mode);
        if (self.msaa_4x_hint) result |= @intFromEnum(ABI.ConfigFlags.msaa_4x_hint);
        if (self.interlaced_hint) result |= @intFromEnum(ABI.ConfigFlags.interlaced_hint);
        return result;
    }
};
// module: rcore →
// Window-related functions
/// Initialize window and OpenGL context
pub fn initWindow(width: i32, height: i32, title: []const u8) void {
    c.InitWindow(width, height, title.ptr);
}
/// Close window and unload OpenGL context
pub fn closeWindow() void {
    c.CloseWindow();
}
/// Check if application should close (KEY_ESCAPE pressed or windows close icon clicked)
pub fn windowShouldClose() bool {
    return c.WindowShouldClose();
}
/// Check if window has been resized last frame
pub fn isWindowResized() bool {
    return c.IsWindowResized();
}
/// Get current screen width
pub fn getScreenWidth() i32 {
    return c.GetScreenWidth();
}
/// Get current screen height
pub fn getScreenHeight() i32 {
    return c.GetScreenHeight();
}
// Drawing-related functions
/// Set background color (framebuffer clear color)
pub fn clearBackground(color: Color) void {
    ABI.ClearBackground(color);
}
/// Setup canvas (framebuffer) to start drawing
pub fn beginDrawing() void {
    c.BeginDrawing();
}
/// End canvas drawing and swap buffers (double buffering)
pub fn endDrawing() void {
    c.EndDrawing();
}
// Misc. functions
/// Setup init configuration flags (view ConfigFlags)
pub fn setConfigFlags(flags: ConfigFlags) void {
    c.SetConfigFlags(flags.toC());
}
/// Draw a color-filled rectangle
pub fn drawRectangleRec(rec: Rectangle, color: Color) void {
    ABI.DrawRectangleRec(rec, color);
}

/// UI backend ----------------------------------------------------------------
pub const RaylibUIBackend = struct {
    pub fn backend(self: *RaylibUIBackend) Backend {
        return .{
            .ptr = self,
            .vtable = &.{
                .isResized = isResized,
                .getWidth = getWidth,
                .getHeight = getHeight,
                .drawRectangle = drawRectangle,
            },
        };
    }

    fn isResized(_: *anyopaque) bool {
        return isWindowResized();
    }
    fn getWidth(_: *anyopaque) f32 {
        return @floatFromInt(getScreenWidth());
    }
    fn getHeight(_: *anyopaque) f32 {
        return @floatFromInt(getScreenHeight());
    }
    fn drawRectangle(_: *anyopaque, rect: Rectangle, color: Color) void {
        drawRectangleRec(rect, color);
    }
};
