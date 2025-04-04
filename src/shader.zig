const std = @import("std");
const c = @import("c.zig").c;

pub const math = @import("math.zig");

id: u32,
uniforms: std.StringArrayHashMap(i32),

const Self = @This();

pub fn init(allocator: std.mem.Allocator, writer: std.fs.File.Writer, comptime path: []const u8) !Self {
    const id = c.glCreateProgram();

    const shader_source = @embedFile(path);

    var iterator = std.mem.splitScalar(u8, shader_source, '\n');
    var index: usize = 0;

    const Shader = struct {
        type: u32,
        start: usize = 0,
        end: usize = 0,
    };

    var shaders: [2]Shader = .{
        .{ .type = c.GL_VERTEX_SHADER },
        .{ .type = c.GL_FRAGMENT_SHADER },
    };

    while (iterator.next()) |line| {
        if (std.mem.eql(u8, line, "@end")) {
            if (shaders[0].start > shaders[1].start) {
                shaders[0].end = index;
            } else if (shaders[0].start < shaders[1].start) {
                shaders[1].end = index;
            }
        }
        index += line.len + 1;
        if (std.mem.eql(u8, line, "@vs vs")) {
            shaders[0].start = index;
        } else if (std.mem.eql(u8, line, "@fs fs")) {
            shaders[1].start = index;
        }
    }

    var success: i32 = undefined;
    var info_log: [512]u8 = undefined;
    var info_log_len: i32 = 0;

    for (shaders) |shader| {
        const shader_id = c.glCreateShader(shader.type);
        defer c.glDeleteShader(shader_id);

        const source = shader_source[shader.start..shader.end];
        const source_len: i32 = @intCast(source.len);
        c.glShaderSource(shader_id, 1, @ptrCast(&source), &source_len);

        // Compile shader
        {
            c.glCompileShader(shader_id);
            c.glGetShaderiv(shader_id, c.GL_COMPILE_STATUS, &success);
            if (success == 0) {
                c.glGetShaderInfoLog(shader_id, info_log.len, @ptrCast(&info_log_len), &info_log);
                _ = try writer.print("{s}", .{info_log[0..@intCast(info_log_len)]});
                return switch (shader.type) {
                    c.GL_VERTEX_SHADER => error.ShaderVertexCompilationFailed,
                    c.GL_FRAGMENT_SHADER => error.ShaderFragmentCompilationFailed,
                    c.GL_GEOMETRY_SHADER => error.ShaderGeometryCompilationFailed,
                    else => unreachable,
                };
            }
        }

        c.glAttachShader(id, shader_id);
    }

    // Link shader
    {
        c.glLinkProgram(id);
        c.glGetProgramiv(id, c.GL_LINK_STATUS, &success);
        if (success == 0) {
            c.glGetProgramInfoLog(id, info_log.len, @ptrCast(&info_log_len), &info_log);
            _ = try writer.print("{s}", .{info_log[0..@intCast(info_log_len)]});
            return error.ShaderProgramLinkError;
        }
    }

    return .{ .id = id, .uniforms = std.StringArrayHashMap(i32).init(allocator) };
}

pub fn deinit(self: *Self) void {
    self.uniforms.deinit();
    c.glDeleteProgram(self.id);
}

pub fn use(self: Self) void {
    c.glUseProgram(self.id);
}

pub fn getUniformLocation(self: *Self, name: []const u8) !i32 {
    var id = self.uniforms.get(name);
    if (id == null) {
        id = c.glGetUniformLocation(self.id, name.ptr);
        if (id == -1) {
            return error.UniformGetLocationError;
        }
        try self.uniforms.put(name, id.?);
    }
    return id.?;
}

pub fn uniformMatrix(self: *Self, name: []const u8, value: math.Matrix) !void {
    const id = try self.getUniformLocation(name);
    c.glUniformMatrix4fv(id, 1, c.GL_FALSE, @ptrCast(&value.toFloat()));
}

pub fn uniform4f(self: *Self, name: []const u8, value: math.Vector4) !void {
    const id = try self.getUniformLocation(name);
    c.glUniform4fv(id, 1, @ptrCast(&value));
}
pub fn uniform1f(self: *Self, name: []const u8, value: f32) !void {
    const id = try self.getUniformLocation(name);
    c.glUniform1f(id, value);
}

pub fn uniform1i(self: *Self, name: []const u8, value: i32) !void {
    const id = try self.getUniformLocation(name);
    c.glUniform1i(id, value);
}
