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

export fn framebufferSizeCallback(window: ?*c.GLFWwindow, width: i32, height: i32) void {
    _ = window;
    shader.use();
    projection = Matrix.ortho(0, @floatFromInt(width), @floatFromInt(height), 0, -1, 1);
    c.glViewport(0, 0, width, height);
}

pub fn init(
    allocator: std.mem.Allocator,
    config: Config,
) !Self {
    const error_writer = std.io.getStdErr().writer();

    // cglfw.glfwInitHint(cglfw.GLFW_PLATFORM, cglfw.GLFW_PLATFORM_X11);
    if (c.glfwInit() != c.GLFW_TRUE) return error.GLFWInitError;

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
    // Enable debug;
    c.glfwWindowHint(c.GLFW_OPENGL_DEBUG_CONTEXT, 0); // 1 = true, 0 = false
    // c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_LINE);

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
    _ = c.glfwSetFramebufferSizeCallback(window, framebufferSizeCallback);

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

    var flags: i32 = undefined;
    c.glGetIntegerv(c.GL_CONTEXT_FLAGS, &flags);

    if ((flags & c.GL_CONTEXT_FLAG_DEBUG_BIT) != 0) {
        c.glEnable(c.GL_DEBUG_OUTPUT);
        c.glEnable(c.GL_DEBUG_OUTPUT_SYNCHRONOUS);
        c.glDebugMessageCallback(glDebugOutput, null);
        c.glDebugMessageControl(c.GL_DONT_CARE, c.GL_DONT_CARE, c.GL_DONT_CARE, 0, null, c.GL_TRUE);
    }

    return .{ .window = window };
}

export fn glDebugOutput(source: u32, @"type": u32, id: u32, severity: u32, length: i32, message: [*c]const u8, user_param: ?*const anyopaque) void {
    _ = length;
    _ = user_param;
    if (id == 131169 or id == 131185 or id == 131218 or id == 131204) return;
    std.debug.print("---------------\n", .{});
    std.debug.print("Debug message ({}): {s}\n", .{ id, message });
    switch (source) {
        c.GL_DEBUG_SOURCE_API => std.debug.print("Source: API\n", .{}),
        c.GL_DEBUG_SOURCE_WINDOW_SYSTEM => std.debug.print("Source: Window System\n", .{}),
        c.GL_DEBUG_SOURCE_SHADER_COMPILER => std.debug.print("Source: Shader Compiler\n", .{}),
        c.GL_DEBUG_SOURCE_THIRD_PARTY => std.debug.print("Source: Third Party\n", .{}),
        c.GL_DEBUG_SOURCE_APPLICATION => std.debug.print("Source: Application\n", .{}),
        c.GL_DEBUG_SOURCE_OTHER => std.debug.print("Source: Other\n", .{}),
        else => std.debug.print("error.DebugUnknownSource\n", .{}),
    }
    switch (@"type") {
        c.GL_DEBUG_TYPE_ERROR => std.debug.print("Type: Error\n", .{}),
        c.GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR => std.debug.print("Type: Deprecated Behaviour\n", .{}),
        c.GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR => std.debug.print("Type: Undefined Behaviour\n", .{}),
        c.GL_DEBUG_TYPE_PORTABILITY => std.debug.print("Type: Portability\n", .{}),
        c.GL_DEBUG_TYPE_PERFORMANCE => std.debug.print("Type: Performance\n", .{}),
        c.GL_DEBUG_TYPE_MARKER => std.debug.print("Type: Marker\n", .{}),
        c.GL_DEBUG_TYPE_PUSH_GROUP => std.debug.print("Type: Push Group\n", .{}),
        c.GL_DEBUG_TYPE_POP_GROUP => std.debug.print("Type: Pop Group\n", .{}),
        c.GL_DEBUG_TYPE_OTHER => std.debug.print("Type: Other\n", .{}),
        else => std.debug.print("error.DebugUnknownType\n", .{}),
    }
    switch (severity) {
        c.GL_DEBUG_SEVERITY_HIGH => std.debug.print("Severity: high\n", .{}),
        c.GL_DEBUG_SEVERITY_MEDIUM => std.debug.print("Severity: medium\n", .{}),
        c.GL_DEBUG_SEVERITY_LOW => std.debug.print("Severity: low\n", .{}),
        c.GL_DEBUG_SEVERITY_NOTIFICATION => std.debug.print("Severity: notification\n", .{}),
        else => std.debug.print("error.DebugUnknownSeverity\n", .{}),
    }
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
    const model = Matrix.translate(2, position);

    const vertices = [_]f32{
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
    try shader.uniformMatrix("projection", projection);
    try shader.uniform4f("color", color.normalize());

    c.glBindVertexArray(VAO);
    defer c.glBindVertexArray(0);

    c.glBindBuffer(c.GL_ARRAY_BUFFER, VBO);
    defer c.glBindBuffer(c.GL_ARRAY_BUFFER, 0);

    c.glBufferData(
        c.GL_ARRAY_BUFFER,
        @sizeOf(f32) * vertices.len,
        @ptrCast(&vertices),
        c.GL_DYNAMIC_DRAW,
    );

    c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, EBO);
    defer c.glBindBuffer(c.GL_ELEMENT_ARRAY_BUFFER, 0);

    c.glBufferData(
        c.GL_ELEMENT_ARRAY_BUFFER,
        @sizeOf(u32) * indices.len,
        @ptrCast(&indices),
        c.GL_DYNAMIC_DRAW,
    );

    c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 3 * @sizeOf(f32), @ptrFromInt(0));
    c.glEnableVertexAttribArray(0);

    c.glDrawElements(c.GL_TRIANGLES, 6, c.GL_UNSIGNED_INT, @ptrFromInt(0));
}

pub fn run(self: *Self, comptime update_callback: *const fn () anyerror!void) !void {
    while (c.glfwWindowShouldClose(self.window) == c.GL_FALSE) {
        try update_callback();
        c.glfwSwapBuffers(self.window);
        c.glfwPollEvents();
    }
}
