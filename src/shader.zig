const std = @import("std");
const gl = @import("gl.zig");

pub const Matrix = @import("math.zig").Matrix;

program: gl.ShaderProgram,
const Self = @This();

pub fn init(writer: std.fs.File.Writer, comptime path: []const u8) !Self {
    const program = gl.ShaderProgram.init();

    const shader_source = @embedFile(path);

    var iterator = std.mem.splitScalar(u8, shader_source, '\n');
    var index: usize = 0;
    var vs_indices = [2]usize{ 0, 0 };
    var fs_indices = [2]usize{ 0, 0 };

    while (iterator.next()) |line| {
        if (std.mem.eql(u8, line, "@end")) {
            if (vs_indices[0] > fs_indices[0]) {
                vs_indices[1] = index;
            } else if (vs_indices[0] < fs_indices[0]) {
                fs_indices[1] = index;
            }
        }
        index += line.len + 1;
        if (std.mem.eql(u8, line, "@vs vs")) {
            vs_indices[0] = index;
        } else if (std.mem.eql(u8, line, "@fs fs")) {
            fs_indices[0] = index;
        }
    }

    for (
        &[2]gl.ShaderType{ gl.ShaderType.vertex_shader, gl.ShaderType.fragment_shader },
        &[2][]const u8{
            shader_source[vs_indices[0]..vs_indices[1]],
            shader_source[fs_indices[0]..fs_indices[1]],
        },
    ) |shader_type, source| {
        const shader = gl.Shader.init(shader_type);
        defer shader.deinit();

        shader.source(source);
        try shader.compile(writer);

        program.attachShader(shader);
    }

    try program.link(writer);

    return .{ .program = program };
}

pub fn deinit(self: Self) void {
    self.program.deinit();
}

pub fn use(self: Self) void {
    self.program.use();
}

pub fn setUniform(self: Self, len: comptime_int, T: type, name: []const u8, value: T) void {
    if (len == 1) {
        switch (T) {
            bool => self.program.getUniform(name).set1i(@intFromBool(value)),
            i32 => self.program.getUniform(name).set1i(value),
            f32 => self.program.getUniform(name).set1f(value),
            else => unreachable,
        }
    }
    if (len == 4) {
        switch (T) {
            Matrix => {
                {
                    self.program.getUniform(name).setMatrix4f(value);
                }
            },
            else => unreachable,
        }
    }
}
