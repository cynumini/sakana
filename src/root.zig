const std = @import("std");
pub const raylib = @import("raylib.zig");
pub const math = @import("math.zig");
pub const input = @import("input.zig");

pub const Image = @import("image.zig");
pub const Texture = @import("texture.zig");
pub const Color = @import("color.zig");
pub const Vector2 = math.Vector2;
pub const Key = input.Key;
pub const Mods = input.Mods;
pub const Action = input.Action;

pub const Config = struct {
    title: []const u8 = "sakana",
    size: Vector2 = Vector2.init(1280, 720),
    clear_color: Color = Color.white,
    resize_callback: ?ResizeCallback = null,
    // input_callback: ?InputCallback = null,
};

const ResizeCallback = *const fn (Vector2) void;
var resize_callback: ?ResizeCallback = null;
var clear_color: Color = Color.black;
var should_run = true;

pub fn init(
    allocator: std.mem.Allocator,
    config: Config,
) !void {
    _ = allocator;
    raylib.initWindow(try config.size.getX(i32), try config.size.getY(i32), config.title.ptr);

    clear_color = config.clear_color;
    if (config.resize_callback) |rc| resize_callback = rc;
}

pub fn deinit() void {
    raylib.closeWindow();
}

pub fn drawTexture(
    texture: Texture,
    position: Vector2,
    scale: f32,
) void {
    raylib.drawTextureEx(
        texture.texture2D,
        position.to_raylib(),
        0,
        scale,
        raylib.white,
    );
}

pub fn drawRectangle(position: Vector2, size: Vector2, color: Color) !void {
    raylib.drawRectangleV(position.to_raylib(), size.to_raylib(), color.to_raylib());
}

pub fn run(comptime update_callback: *const fn () anyerror!void, comptime draw_callback: *const fn () anyerror!void) !void {
    while (!raylib.windowShouldClose() and should_run) {
        if (raylib.isWindowResized()) {
            if (resize_callback) |rc| rc(getScreenSize());
        }
        try update_callback();
        raylib.beginDrawing();
        raylib.clearBackground(clear_color.to_raylib());
        try draw_callback();
        raylib.endDrawing();
    }
}

pub fn exit() void {
    should_run = false;
}

pub fn isKeyReleased(key: Key) bool {
    return raylib.isKeyReleased(@intFromEnum(key));
}

pub fn getMaxMonitorSize() Vector2 {
    const monitor_count: usize = @intCast(raylib.getMonitorCount());
    var max_width: i32 = 0;
    var max_height: i32 = 0;
    for (0..monitor_count) |i| {
        max_width = @max(raylib.getMonitorWidth(@intCast(i)), max_width);
        max_height = @max(raylib.getMonitorHeight(@intCast(i)), max_height);
    }
    return .init(max_width, max_height);
}

pub fn getScreenSize() Vector2 {
    return .init(raylib.getScreenWidth(), raylib.getScreenHeight());
}

pub fn drawText(text: []const u8, position: Vector2, font_size: i32, color: Color) void {
    raylib.drawText(
        text.ptr,
        try position.getX(i32),
        try position.getY(i32),
        font_size,
        color.to_raylib(),
    );
}

pub fn measureText(text: []const u8, font_size: i32) i32 {
    return raylib.measureText(text.ptr, font_size);
}
