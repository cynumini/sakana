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
// const InputCallback = *const fn (key: input.Key, action: input.Action, mods: input.Mods) anyerror!void;
var resize_callback: ?ResizeCallback = null;
// var input_callback: ?InputCallback = null;
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

pub fn clear() void {
    raylib.clearBackground(.{
        .r = clear_color.r,
        .g = clear_color.g,
        .b = clear_color.b,
        .a = clear_color.a,
    });
}

const StretchAspect = enum { ignore, keep };

pub fn drawTexture(
    texture: Texture,
    position: Vector2,
    size: Vector2,
    stretch_aspect: StretchAspect,
) !void {
    const scale = @min(size.x / texture.size.x, size.y / texture.size.y);
    const new_position = blk: switch (stretch_aspect) {
        .keep => {
            const texture_ratio = texture.size.x / texture.size.y;
            const current_ratio = size.x / size.y;

            if (current_ratio > texture_ratio) {
                const new_x = size.y * texture_ratio;
                break :blk Vector2.init(position.x + (size.x - new_x) / 2, position.y);
            } else {
                const new_y = size.x / texture_ratio;
                break :blk Vector2.init(position.x, position.y + (size.y - new_y) / 2);
            }
        },
        else => size,
    };
    raylib.drawTextureEx(
        texture.texture2D,
        .{ .x = new_position.x, .y = new_position.y },
        0,
        scale,
        raylib.white,
    );
}

pub fn drawRectangle(position: Vector2, size: Vector2, color: Color) !void {
    raylib.drawRectangleV(
        .{ .x = position.x, .y = position.y },
        .{ .x = size.x, .y = size.y },
        .{ .r = color.r, .g = color.g, .b = color.b, .a = color.a },
    );
}

pub fn run(comptime update_callback: *const fn () anyerror!void, comptime draw_callback: *const fn () anyerror!void) !void {
    while (!raylib.windowShouldClose() and should_run) {
        if (raylib.isWindowResized()) {
            if (resize_callback) |rc| rc(
                .init(
                    @floatFromInt(raylib.getScreenWidth()),
                    @floatFromInt(raylib.getScreenHeight()),
                ),
            );
        }
        try update_callback();
        raylib.beginDrawing();
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
