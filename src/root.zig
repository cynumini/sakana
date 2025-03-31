const std = @import("std");

const gl = @import("gl.zig");
const cgl = gl.c;
const glfw = @import("glfw.zig");
const stb = @import("stb.zig");
const Shader = @import("shader.zig");
pub const Color = @import("color.zig");
pub const math = @import("math.zig");
pub const Matrix = math.Matrix;
pub const Vector2 = math.Vector2;
pub const Vector3 = math.Vector3;
pub const Vector4 = math.Vector4;

const Self = @This();

var VAO: gl.VertexArray = undefined;
var VBO: gl.Buffer = undefined;
var EBO: gl.Buffer = undefined;
var projection: Matrix = undefined;
var shader: Shader = undefined;

window: glfw.Window,

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

    try glfw.init();
    glfw.setupOpenGL(3, 3, .core_profile);
    const window = try glfw.Window.init(
        @intFromFloat(config.size[0]),
        @intFromFloat(config.size[1]),
        config.title,
    );
    window.makeContextCurrent();

    try gl.init();

    VAO = gl.VertexArray.init();
    VBO = gl.Buffer.init(.array);
    EBO = gl.Buffer.init(.element_array);

    projection = Matrix.ortho(0, config.size[0], config.size[1], 0, -1, 1);
    shader = try Shader.init(allocator, error_writer, "basic.vert", "basic.frag");
    shader.use();
    shader.setUniform(4, Matrix, "projection", projection);

    setClearColor(config.clear_color);

    return .{ .window = window };
}

pub fn deinit(self: *Self) void {
    _ = self;
    defer glfw.deinit();
    defer shader.deinit();
    defer VAO.deinit();
    defer VBO.deinit();
    defer EBO.deinit();
}

pub fn setClearColor(color: Color) void {
    const normalized = color.normalize();
    cgl.glClearColor(normalized[0], normalized[1], normalized[2], normalized[3]);
}

pub fn clear() void {
    cgl.glClear(cgl.GL_COLOR_BUFFER_BIT);
}

pub fn drawRectangle(position: Vector2, size: Vector2, color: Color) void {
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
    shader.setUniform(4, Matrix, "model", model);
    VAO.bind();
    defer VAO.unbind();

    VBO.bind();
    defer VBO.unbind();

    VBO.data(f32, &vertices);

    EBO.bind();
    defer EBO.unbind();

    EBO.data(u32, &indices);

    VBO.vertexAttribPointer(0, 3, .float, false, 3 * @sizeOf(f32), @ptrFromInt(0));
    VBO.enableVertexAttribArray(0);

    gl.drawElements(.triangles, 6, .unsigned_int);
}

pub fn run(self: *Self, comptime update_callback: *const fn () anyerror!void) !void {
    while (!self.window.shouldClose()) {
        try update_callback();
        self.window.swapBuffers();
        glfw.pollEvents();
    }
}
