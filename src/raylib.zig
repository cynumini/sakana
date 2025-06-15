const std = @import("std");

pub const ABI = struct {
    // const c = @cImport({
    //     @cInclude("raylib.h");
    // });

    //----------------------------------------------------------------------------------
    // Enumerators Definition
    //----------------------------------------------------------------------------------
    // System/Window config flags
    // NOTE: Every bit registers one state (use it with bit masks)
    // By default all flags are set to 0
    pub const ConfigFlags = enum(c_uint) {
        /// Set to run program in fullscreen
        window_resizable = 0x00000004,
        /// Set to allow resizable window
        fullscreen_mode = 0x00000002,
    };

    // Window-related functions
    /// Initialize window and OpenGL context
    pub extern fn InitWindow(width: c_int, height: c_int, title: [*c]const u8) void;
    /// Close window and unload OpenGL context
    pub extern fn CloseWindow() void;
    /// Check if application should close (KEY_ESCAPE pressed or windows close icon clicked)
    pub extern fn WindowShouldClose() bool;
    /// Check if window has been resized last frame
    pub extern fn IsWindowResized() bool;
    /// Set window minimum dimensions (for FLAG_WINDOW_RESIZABLE)
    pub extern fn SetWindowMinSize(width: c_int, height: c_int) void;
    /// Get current screen width
    pub extern fn GetScreenWidth() c_int;
    /// Get current screen height
    pub extern fn GetScreenHeight() c_int;

    // Drawing-related functions
    /// Set background color (framebuffer clear color)
    pub extern fn ClearBackground(color: Color) void;
    /// Setup canvas (framebuffer) to start drawing
    pub extern fn BeginDrawing() void;
    /// End canvas drawing and swap buffers (double buffering)
    pub extern fn EndDrawing() void;

    /// Setup init configuration flags (view FLAGS)
    pub extern fn SetConfigFlags(flags: c_uint) void;

    //------------------------------------------------------------------------------------
    // Basic Shapes Drawing Functions (Module: shapes)
    //------------------------------------------------------------------------------------
    // Set texture and rectangle to be used on shapes drawing
    // NOTE: It can be useful when using basic shapes and one single font,
    // defining a font char white rectangle would allow drawing everything in a single draw call

    // Basic shapes drawing functions
    /// Draw a color-filled rectangle
    pub extern fn DrawRectangle(posX: c_int, posY: c_int, width: c_int, height: c_int, color: Color) void;

    // Text drawing functions
    /// Draw text (using default font)
    pub extern fn DrawText(text: [*c]const u8, posX: c_int, posY: c_int, fontSize: c_int, color: Color) void;
};

/// Vector2, 2 components
pub const Vector2 = extern struct {
    /// Vector x component
    x: f32,
    /// Vector y component
    y: f32,
    /// Vector with components value 0
    pub const zero = Vector2{ .x = 0, .y = 0 };
};

/// Color, 4 components, R8G8B8A8 (32bit)
pub const Color = extern struct {
    /// Color red value
    r: u8,
    /// Color green value
    g: u8,
    /// Color blue value
    b: u8,
    /// Color alpha value
    a: u8,

    // Some Basic Colors
    // NOTE: Custom raylib color palette for amazing visuals on WHITE background
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

    pub fn get(hex_value: u32) Color {
        return Color{
            .r = @intCast((hex_value >> 24) & 0xFF),
            .g = @intCast((hex_value >> 16) & 0xFF),
            .b = @intCast((hex_value >> 8) & 0xFF),
            .a = @intCast(hex_value & 0xFF),
        };
    }
};

/// Rectangle, 4 components
pub const Rectangle = extern struct {
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

/// Window-related struct
pub const Window = struct {
    /// Initialize window and OpenGL context
    pub fn init(width: usize, height: usize, title: []const u8, config_flags: ConfigFlags) Window {
        setConfigFlags(config_flags);
        ABI.InitWindow(@intCast(width), @intCast(height), title.ptr);
        return .{};
    }
    /// Close window and unload OpenGL context
    pub fn deinit(_: Window) void {
        ABI.CloseWindow();
    }
    /// Check if application should close (KEY_ESCAPE pressed or windows close icon clicked)
    pub fn shouldClose(_: Window) bool {
        return ABI.WindowShouldClose();
    }
    /// Check if window has been resized last frame
    pub fn isResized(_: Window) bool {
        return ABI.IsWindowResized();
    }
    /// Set window minimum dimensions (for ConfigFlags.window_resizable)
    pub fn setMinSize(_: Window, width: usize, height: usize) void {
        ABI.SetWindowMinSize(@intCast(width), @intCast(height));
    }
    /// Get current screen width
    pub fn getWidth(_: Window) usize {
        return @intCast(ABI.GetScreenWidth());
    }
    /// Get current screen height
    pub fn getHeight(_: Window) usize {
        return @intCast(ABI.GetScreenHeight());
    }
};

pub const ConfigFlags = struct {
    /// Set to run program in fullscreen
    fullscreen_mode: bool = false,
    /// Set to allow resizable window
    window_resizable: bool = false,

    pub fn toC(self: ConfigFlags) c_uint {
        var result: c_uint = 0;
        if (self.window_resizable) result |= @intFromEnum(ABI.ConfigFlags.window_resizable);
        if (self.fullscreen_mode) result |= @intFromEnum(ABI.ConfigFlags.fullscreen_mode);
        return result;
    }
};

// Drawing-related functions
/// Setup canvas (framebuffer) to start drawing
pub fn clearBackground(color: Color) void {
    ABI.ClearBackground(color);
}

/// Setup canvas (framebuffer) to start drawing
pub fn beginDrawing() void {
    ABI.BeginDrawing();
}

/// End canvas drawing and swap buffers (double buffering)
pub fn endDrawing() void {
    ABI.EndDrawing();
}

/// Setup init configuration flags (view FLAGS)
pub fn setConfigFlags(flags: ConfigFlags) void {
    ABI.SetConfigFlags(flags.toC());
}

// Basic shapes drawing functions
/// Draw a color-filled rectangle
pub fn drawRectangle(pos_x: i32, pos_y: i32, width: usize, height: usize, color: Color) void {
    ABI.DrawRectangle(
        @intCast(pos_x),
        @intCast(pos_y),
        @intCast(width),
        @intCast(height),
        color,
    );
}

// Text drawing functions
/// Draw text (using default font)
pub fn drawText(text: []const u8, pos_x: i32, pos_y: i32, font_size: usize, color: Color) void {
    ABI.DrawText(
        text.ptr,
        @intCast(pos_x),
        @intCast(pos_y),
        @intCast(font_size),
        color,
    );
}
