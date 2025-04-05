const std = @import("std");

const c = @import("c.zig").c;
const Shader = @import("shader.zig");
pub const Color = @import("color.zig");
pub const math = @import("math.zig");
pub const Matrix = math.Matrix;
pub const Vector2 = math.Vector2;
pub const Vector3 = math.Vector3;
pub const Vector4 = math.Vector4;
pub const Texture = @import("texture.zig");
pub const Image = @import("image.zig");
pub const Input = @import("input.zig");
pub const Key = Input.Key;
pub const Action = Input.Action;
pub const Mods = Input.Mods;

const Self = @This();

var VAO: u32 = undefined;
var VBO: u32 = undefined;
var EBO: u32 = undefined;
var projection: Matrix = undefined;
var shader: Shader = undefined;
const ResizeCallback = *const fn (Vector2) void;
const InputCallback = *const fn (key: Key, action: Action, mods: Mods) anyerror!void;
var resize_callback: ?ResizeCallback = null;
var input_callback: ?InputCallback = null;

var main_window: *c.GLFWwindow = undefined;

pub const Config = struct {
    title: []const u8 = "sakana",
    size: Vector2 = Vector2.init(1280, 720),
    clear_color: Color = Color.white,
    resize_callback: ?ResizeCallback = null,
    input_callback: ?InputCallback = null,
};

export fn framebufferSizeCallback(window: ?*c.GLFWwindow, width: i32, height: i32) void {
    _ = window;
    shader.use();
    const size = Vector2.init(@floatFromInt(width), @floatFromInt(height));
    projection = Matrix.ortho(0, size.x, size.y, 0, -1, 1);
    c.glViewport(0, 0, width, height);
    if (resize_callback) |rc| {
        rc(size);
    }
}

export fn keyCallback(window: ?*c.GLFWwindow, key: i32, _: i32, action: i32, mods: i32) void {
    _ = window;
    if (input_callback) |kc| {
        kc(@enumFromInt(key), @enumFromInt(action), .{
            .shift = (mods | 1) != 0,
            .control = (mods | 2) != 0,
            .alt = (mods | 4) != 0,
            .super = (mods | 8) != 0,
        }) catch unreachable;
    }
}

pub fn init(
    allocator: std.mem.Allocator,
    config: Config,
) !void {
    const error_writer = std.io.getStdErr().writer();

    // cglfw.glfwInitHint(cglfw.GLFW_PLATFORM, cglfw.GLFW_PLATFORM_X11);
    if (c.glfwInit() != c.GLFW_TRUE) return error.GLFWInitError;

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 4);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
    // Enable debug;
    c.glfwWindowHint(c.GLFW_OPENGL_DEBUG_CONTEXT, 1); // 1 = true, 0 = false
    // c.glPolygonMode(c.GL_FRONT_AND_BACK, c.GL_LINE);

    main_window = c.glfwCreateWindow(
        config.size.intX(),
        config.size.intY(),
        config.title.ptr,
        null,
        null,
    ) orelse {
        return error.GLFWCreateWindowError;
    };
    c.glfwMakeContextCurrent(main_window);
    _ = c.glfwSetFramebufferSizeCallback(main_window, framebufferSizeCallback);
    _ = c.glfwSetKeyCallback(main_window, keyCallback);
    if (config.resize_callback) |rc| resize_callback = rc;
    if (config.input_callback) |kc| input_callback = kc;
    if (c.gladLoadGLLoader(@ptrCast(&c.glfwGetProcAddress)) == 0) {
        return error.GLInitError;
    }

    c.glGenVertexArrays(1, @ptrCast(&VAO));

    c.glGenBuffers(1, @ptrCast(&VBO));
    c.glGenBuffers(1, @ptrCast(&EBO));

    projection = Matrix.ortho(0, config.size.x, config.size.y, 0, -1, 1);
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
    c.glEnable(c.GL_BLEND);
    c.glBlendFunc(c.GL_SRC_ALPHA, c.GL_ONE_MINUS_SRC_ALPHA);
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

pub fn deinit() void {
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
        size.x, 0.0, //
        size.x, size.y, //
        0.0, size.y, //
        0.0, 0.0, //
    };

    const indices = [_]u32{ // note that we start from 0!
        0, 1, 3, // first triangle
        1, 2, 3, // second triangle
    };

    shader.use();
    try shader.uniformMatrix("model", model);
    try shader.uniformMatrix("projection", projection);
    try shader.uniform4f("color", color.normalize());
    try shader.uniform1i("isTexture", 0);

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

    c.glVertexAttribPointer(0, 2, c.GL_FLOAT, c.GL_FALSE, 2 * @sizeOf(f32), @ptrFromInt(0));
    c.glEnableVertexAttribArray(0);

    c.glDrawElements(c.GL_TRIANGLES, 6, c.GL_UNSIGNED_INT, @ptrFromInt(0));
}

const StretchAspect = enum { ignore, keep };

pub fn drawTexture(
    texture: Texture,
    position: Vector2,
    size: Vector2,
    stretch_aspect: StretchAspect,
) !void {
    const new_size, const new_position = blk: switch (stretch_aspect) {
        .keep => {
            const texture_ratio = texture.size.x / texture.size.y;
            const current_ratio = size.x / size.y;

            if (current_ratio > texture_ratio) {
                const new_x = size.y * texture_ratio;
                break :blk .{
                    Vector2.init(new_x, size.y),
                    Vector2.init(position.x + (size.x - new_x) / 2, position.y),
                };
            } else {
                const new_y = size.x / texture_ratio;
                break :blk .{
                    Vector2.init(size.x, new_y),
                    Vector2.init(position.x, position.y + (size.y - new_y) / 2),
                };
            }
        },
        else => .{ size, position },
    };

    const model = Matrix.translate(2, new_position);

    const vertices = [_]f32{
        // position + texture cordinates
        new_size.x, 0.0, 1.0, 0.0, // top right
        new_size.x, new_size.y, 1.0, 1.0, // bottom right
        0.0, new_size.y, 0.0, 1.0, // bottom let
        0.0, 0.0, 0.0, 0.0, // top left
    };

    const indices = [_]u32{ // note that we start from 0!
        0, 1, 3, // first triangle
        1, 2, 3, // second triangle
    };

    texture.bind();

    shader.use();
    try shader.uniformMatrix("model", model);
    try shader.uniformMatrix("projection", projection);
    try shader.uniform1i("isTexture", 1);
    try shader.uniform4f("color", Color.white.normalize());
    try shader.uniform1i("texture0", 0);

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

    c.glVertexAttribPointer(0, 4, c.GL_FLOAT, c.GL_FALSE, 4 * @sizeOf(f32), @ptrFromInt(0));
    c.glEnableVertexAttribArray(0);

    c.glDrawElements(c.GL_TRIANGLES, 6, c.GL_UNSIGNED_INT, @ptrFromInt(0));
}

pub fn run(comptime update_callback: *const fn () anyerror!void) !void {
    while (c.glfwWindowShouldClose(main_window) == c.GL_FALSE) {
        try update_callback();
        c.glfwSwapBuffers(main_window);
        c.glfwPollEvents();
    }
}

pub fn getKey(key: Key) bool {
    return c.glfwGetKey(main_window, @intFromEnum(key)) == 1;
}

pub fn exit() void {
    c.glfwSetWindowShouldClose(main_window, 1);
}
