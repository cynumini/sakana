const std = @import("std");

const c = @import("c.zig").c;
const Shader = @import("shader.zig");
pub const Color = @import("color.zig");
pub const math = @import("math.zig");
pub const Matrix = math.Matrix;
pub const Vector2 = math.Vector2;
pub const Vector3 = math.Vector3;
pub const Vector4 = math.Vector4;

const Self = @This();

var VAO: u32 = undefined;
var VBO: u32 = undefined;
var EBO: u32 = undefined;
var projection: Matrix = undefined;
var shader: Shader = undefined;

window: *c.GLFWwindow,

pub const Config = struct {
    title: []const u8 = "sakana",
    size: Vector2 = .{ 1280, 720 },
    clear_color: Color = Color.white,
};

pub fn init(
    allocator: std.mem.Allocator,
    config: Config,
) !Self {
    const error_writer = std.io.getStdErr().writer();

    // cglfw.glfwInitHint(cglfw.GLFW_PLATFORM, cglfw.GLFW_PLATFORM_X11);
    if (c.glfwInit() != c.GLFW_TRUE) return error.GLFWInitError;

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);

    const window = c.glfwCreateWindow(
        @intFromFloat(config.size[0]),
        @intFromFloat(config.size[1]),
        config.title.ptr,
        null,
        null,
    ) orelse {
        return error.GLFWCreateWindowError;
    };
    c.glfwMakeContextCurrent(window);

    if (c.gladLoadGLLoader(@ptrCast(&c.glfwGetProcAddress)) == 0) {
        return error.GLInitError;
    }

    c.glGenVertexArrays(1, @ptrCast(&VAO));

    c.glGenBuffers(1, @ptrCast(&VBO));
    c.glGenBuffers(1, @ptrCast(&EBO));

    projection = Matrix.ortho(0, config.size[0], config.size[1], 0, -1, 1);
    shader = try Shader.init(allocator, error_writer, "shaders/basic.glsl");
    shader.use();
    try shader.uniformMatrix("projection", projection);

    setClearColor(config.clear_color);

    return .{ .window = window };
}

pub fn deinit(self: *Self) void {
    _ = self;
    defer c.glfwTerminate();
    defer shader.deinit();
    defer c.glDeleteVertexArrays(1, @ptrCast(&VAO));
    defer c.glDeleteBuffers(1, @ptrCast(&VBO));
    defer c.glDeleteBuffers(1, @ptrCast(&EBO));
}

pub fn setClearColor(color: Color) void {
    const normalized = color.normalize();
    c.glClearColor(normalized[0], normalized[1], normalized[2], normalized[3]);
}

pub fn clear() void {
    c.glClear(c.GL_COLOR_BUFFER_BIT);
}

pub fn drawRectangle(position: Vector2, size: Vector2, color: Color) !void {
    _ = color;
    const model = Matrix.translate(2, position);

    const vertices = [_]f32{
        // positions (3) colors (3) texture coords (2)
        size[0], 0.0, 0.0, //
        size[0], size[1], 0.0, //
        0.0, size[1], 0.0, //
        0.0, 0.0, 0.0, //
    };

    const indices = [_]u32{ // note that we start from 0!
        0, 1, 3, // first triangle
        1, 2, 3, // second triangle
    };

    shader.use();
    try shader.uniformMatrix("model", model);

    c.glBindVertexArray(VAO);
    defer c.glBindVertexArray(0);

    c.glBindBuffer(c.GL_ARRAY_BUFFER, VBO);
    defer c.glBindBuffer(c.GL_ARRAY_BUFFER, 0);

    c.glBufferData(
        c.GL_ARRAY_BUFFER,
        @sizeOf(f32) * vertices.len,
        @ptrCast(&vertices),
        c.GL_STATIC_DRAW,
    );

    c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, EBO);
    defer c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, 0);

    c.glBufferData(
        c.GL_ELEMENT_ARRAY_BUFFER,
        @sizeOf(u32) * indices.len,
        @ptrCast(&indices),
        c.GL_STATIC_DRAW,
    );

    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 3 * @sizeOf(f32), @ptrFromInt(0));
    c.glEnableVertexAttribArray(0);

    // cgl.glPolygonMode(cgl.GL_FRONT_AND_BACK, cgl.GL_LINE);
    c.glDrawElements(c.GL_TRIANGLES, 6, c.GL_UNSIGNED_INT, @ptrFromInt(0));
}

pub fn run(self: *Self, comptime update_callback: *const fn () anyerror!void) !void {
    while (c.glfwWindowShouldClose(self.window) == c.GL_FALSE) {
        try update_callback();
        c.glfwSwapBuffers(self.window);
        c.glfwPollEvents();
    }
}
