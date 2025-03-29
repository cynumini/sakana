const std = @import("std");

const gl = @import("gl.zig");
const glfw = @import("glfw.zig");
const stb = @import("stb.zig");
const Shader = @import("shader.zig");
pub const Color = @import("color.zig");

const Self = @This();

window: glfw.Window,

pub fn init(screen_width: i32, screen_height: i32, title: []const u8) !Self {
    try glfw.init();
    glfw.setupOpenGL(3, 3, .core_profile);
    const window = try glfw.Window.init(screen_width, screen_height, title);
    window.makeContextCurrent();

    try gl.init();
    return .{ .window = window };
}

pub fn deinit(self: *Self) void {
    _ = self;
    glfw.deinit();
}

pub fn shouldClose(self: *Self) bool {
    return self.window.shouldClose();
}

pub fn beginDrawing() void {}

pub fn clearColor(color: Color) void {
    gl.clearColor(color.r, color.g, color.b, color.a);
    gl.clear(gl.color_buffer_bit);
}

pub fn endDrawing(self: *Self) void {
    self.window.swapBuffers();
    glfw.pollEvents();
}
