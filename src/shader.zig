const std = @import("std");
const gl = @import("gl.zig");

pub const Matrix = @import("math.zig").Matrix;

program: gl.ShaderProgram,
const Self = @This();

pub fn init(allocator: std.mem.Allocator, writer: std.fs.File.Writer, vertex_path: []const u8, fragment_path: []const u8) !Self {
    const program = gl.ShaderProgram.init();

    for (
        &[2]gl.ShaderType{ gl.ShaderType.vertex_shader, gl.ShaderType.fragment_shader },
        &[2][]const u8{ vertex_path, fragment_path },
    ) |shader_type, path| {
        const file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
        defer file.close();

        const source = try file.readToEndAlloc(allocator, std.math.maxInt(usize));
        defer allocator.free(source);

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
