pub const c = @cImport({
    @cInclude("glad/glad.h");
});

const std = @import("std");

const glfw = @import("glfw.zig");

pub const Matrix4f = @import("math.zig").Matrix4f;

const GLint = i32;
const GLsizei = i32;
const GLuint = u32;
const GLenum = u32;
const GLfloat = f32;
const GLbitfield = u32;

pub const ShaderType = enum(GLenum) {
    vertex_shader = c.GL_VERTEX_SHADER,
    geometry_shader = c.GL_GEOMETRY_SHADER,
    fragment_shader = c.GL_FRAGMENT_SHADER,
};

pub fn viewport(x: GLint, y: GLint, width: GLsizei, height: GLsizei) void {
    c.glViewport(x, y, width, height);
}

pub fn init() !void {
    if (c.gladLoadGLLoader(@ptrCast(&glfw.c.glfwGetProcAddress)) == 0) {
        return error.GLInitError;
    }
}

pub const Shader = struct {
    id: GLuint,
    shader_type: ShaderType,

    const Self = @This();

    pub fn init(shader_type: ShaderType) Self {
        return .{ .id = c.glCreateShader(@intFromEnum(shader_type)), .shader_type = shader_type };
    }

    pub fn deinit(self: Self) void {
        c.glDeleteShader(self.id);
    }

    pub fn source(self: Self, code: []const u8) void {
        c.glShaderSource(self.id, 1, @ptrCast(&code), &[1]i32{@intCast(code.len)});
    }

    pub fn compile(self: Self, writer: std.fs.File.Writer) !void {
        c.glCompileShader(self.id);
        var success: i32 = undefined;
        var infoLog: [512]u8 = undefined;
        c.glGetShaderiv(self.id, c.GL_COMPILE_STATUS, &success);
        if (success == 0) {
            c.glGetShaderInfoLog(self.id, 512, null, &infoLog);
            _ = try writer.print("{s}", .{infoLog});
            return switch (self.shader_type) {
                .vertex_shader => error.ShaderVertexCompilationFailed,
                .fragment_shader => error.ShaderFragmentCompilationFailed,
                .geometry_shader => error.ShaderGeometryCompilationFailed,
            };
        }
    }
};

pub const Uniform = struct {
    id: GLint,

    const Self = @This();

    pub fn set4f(self: Self, v0: GLfloat, v1: GLfloat, v2: GLfloat, v3: GLfloat) void {
        c.glUniform4f(self.id, v0, v1, v2, v3);
    }

    pub fn set1i(self: Self, v0: GLint) void {
        c.glUniform1i(self.id, v0);
    }

    pub fn set1f(self: Self, v0: GLfloat) void {
        c.glUniform1f(self.id, v0);
    }
    pub fn setMatrix4f(self: Self, matrix: []const [4]f32) void {
        c.glUniformMatrix4fv(self.id, 1, c.GL_FALSE, @ptrCast(matrix.ptr));
    }
};

pub const ShaderProgram = struct {
    id: GLuint,

    const Self = @This();

    pub fn init() Self {
        return .{ .id = c.glCreateProgram() };
    }

    pub fn deinit(self: Self) void {
        c.glDeleteProgram(self.id);
    }

    pub fn attachShader(self: Self, shader: Shader) void {
        c.glAttachShader(self.id, shader.id);
    }

    pub fn use(self: Self) void {
        c.glUseProgram(self.id);
    }

    pub fn link(self: Self, writer: std.fs.File.Writer) !void {
        c.glLinkProgram(self.id);
        var success: i32 = undefined;
        var infoLog: [512]u8 = undefined;
        c.glGetProgramiv(self.id, c.GL_LINK_STATUS, &success);
        if (success == 0) {
            c.glGetProgramInfoLog(self.id, 512, null, &infoLog);
            _ = try writer.print("{s}", .{infoLog});
            return error.ShaderProgramLinkError;
        }
    }

    pub fn getUniform(self: Self, name: []const u8) Uniform {
        return .{ .id = c.glGetUniformLocation(self.id, name.ptr) };
    }
};

pub const VertexArray = struct {
    id: GLuint,

    const Self = @This();

    pub fn init() Self {
        var id: GLuint = undefined;
        c.glGenVertexArrays(1, @ptrCast(&id));
        return .{ .id = id };
    }

    pub fn bind(self: Self) void {
        c.glBindVertexArray(self.id);
    }

    pub fn unbind(_: Self) void {
        c.glBindVertexArray(0);
    }

    pub fn deinit(self: Self) void {
        c.glDeleteVertexArrays(1, @ptrCast(&self.id));
    }
};

const BufferType = enum(GLenum) {
    array = c.GL_ARRAY_BUFFER,
    element_array = c.GL_ELEMENT_ARRAY_BUFFER,
};

const Type = enum(GLenum) {
    byte = c.GL_BYTE,
    unsigned_byte = c.GL_UNSIGNED_BYTE,
    short = c.GL_SHORT,
    unsigned_short = c.GL_UNSIGNED_SHORT,
    int = c.GL_INT,
    unsigned_int = c.GL_UNSIGNED_INT,
    half_float = c.GL_HALF_FLOAT,
    float = c.GL_FLOAT,
    double = c.GL_DOUBLE,
    int_2_10_10_10_rev = c.GL_INT_2_10_10_10_REV,
    unsigned_int_2_10_10_10_rev = c.GL_UNSIGNED_INT_2_10_10_10_REV,
    unsigned_int_10f_11f_11f_rev = c.GL_UNSIGNED_INT_10F_11F_11F_REV,
};

pub const Buffer = struct {
    id: GLuint,
    buffer_type: BufferType,

    const Self = @This();

    pub fn init(buffer_type: BufferType) Self {
        var id: GLuint = undefined;
        c.glGenBuffers(1, @ptrCast(&id));
        return .{ .id = id, .buffer_type = buffer_type };
    }

    pub fn bind(self: Self) void {
        c.glBindBuffer(@intFromEnum(self.buffer_type), self.id);
    }

    pub fn unbind(self: Self) void {
        c.glBindBuffer(@intFromEnum(self.buffer_type), 0);
    }

    pub fn data(self: Self, T: type, init_data: []const T) void {
        c.glBufferData(
            @intFromEnum(self.buffer_type),
            @intCast(@sizeOf(T) * init_data.len),
            @ptrCast(init_data),
            c.GL_STATIC_DRAW,
        );
    }

    pub fn vertexAttribPointer(_: Self, index: GLuint, size: GLint, @"type": Type, normalized: bool, stride: GLsizei, pointer: ?*const anyopaque) void {
        c.glVertexAttribPointer(index, size, @intFromEnum(@"type"), @intFromBool(normalized), stride, pointer);
    }

    pub fn enableVertexAttribArray(_: Self, index: GLuint) void {
        c.glEnableVertexAttribArray(index);
    }

    pub fn deinit(self: Self) void {
        c.glDeleteBuffers(1, @ptrCast(&self.id));
    }
};

const PolygonMode = enum(GLenum) {
    point = c.GL_POINT,
    line = c.GL_LINE,
    fill = c.GL_FILL,
};

pub fn polygonMode(mode: PolygonMode) void {
    c.glPolygonMode(c.GL_FRONT_AND_BACK, @intFromEnum(mode));
}

pub fn clearColor(red: GLfloat, green: GLfloat, blue: GLfloat, alpha: GLfloat) void {
    c.glClearColor(red, green, blue, alpha);
}

pub const depth_buffer_bit = c.GL_DEPTH_BUFFER_BIT;
pub const stencil_buffer_bit = c.GL_STENCIL_BUFFER_BIT;
pub const color_buffer_bit = c.GL_COLOR_BUFFER_BIT;

pub fn clear(mask: GLbitfield) void {
    c.glClear(mask);
}

const DrawMode = enum(GLenum) {
    points = c.GL_POINTS,
    line_strip = c.GL_LINE_STRIP,
    line_loop = c.GL_LINE_LOOP,
    lines = c.GL_LINES,
    line_strip_adjacency = c.GL_LINE_STRIP_ADJACENCY,
    lines_adjacency = c.GL_LINES_ADJACENCY,
    triangle_strip = c.GL_TRIANGLE_STRIP,
    triangle_fan = c.GL_TRIANGLE_FAN,
    triangles = c.GL_TRIANGLES,
    triangle_strip_adjacency = c.GL_TRIANGLE_STRIP_ADJACENCY,
    triangles_adjacency = c.GL_TRIANGLES_ADJACENCY,
};

pub fn drawElements(mode: DrawMode, count: GLsizei, @"type": Type) void {
    c.glDrawElements(@intFromEnum(mode), count, @intFromEnum(@"type"), @ptrFromInt(0));
}
