const std = @import("std");

const c = @import("c.zig").c;
const Shader = @import("shader.zig");
pub const math = @import("math.zig");
pub const Vector2 = math.Vector2;

const Self = @This();

data: [*c]const u8,
size: math.Vector2,

pub const DataType = enum { path, memory };

pub fn init(input_data: []const u8, data_type: DataType) !Self {
    var width: i32 = undefined;
    var height: i32 = undefined;
    var channels_in_file: i32 = undefined;
    const data = switch (data_type) {
        .path => c.stbi_load(input_data.ptr, &width, &height, &channels_in_file, 4),
        .memory => c.stbi_load_from_memory(
            input_data.ptr,
            @intCast(input_data.len),
            &width,
            &height,
            &channels_in_file,
            4,
        ),
    };
    if (data == 0) {
        return error.ImageLoadingError;
    }
    return .{ .data = data, .size = Vector2.initInt(width, height) };
}

pub fn deinit(self: *Self) void {
    c.stbi_image_free(@ptrCast(@constCast(self.data)));
}
