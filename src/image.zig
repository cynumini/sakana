const std = @import("std");

pub const raylib = @import("raylib.zig");
pub const math = @import("math.zig");

const Self = @This();

image: raylib.Image,
size: math.Vector2,

pub const DataType = enum { path, memory };

pub const Format = enum(u8) {
    jpeg = 1,
    png = 2,
    wemp = 33,
    apng = 23,
    animated_webp = 83,
};

pub fn init(input_data: []const u8, data_type: DataType, format: Format) !Self {
    const file_type = switch (format) {
        .jpeg => ".jpeg",
        .png => ".png",
        else => return error.UnsupportedImageFormat,
    };
    const image = switch (data_type) {
        .memory => raylib.loadImageFromMemory(file_type, input_data.ptr, @intCast(input_data.len)),
        .path => raylib.loadImage(input_data.ptr),
    };
    return .{
        .image = image,
        .size = math.Vector2.init(image.width, image.height),
    };
}

pub fn deinit(self: *Self) void {
    raylib.unloadImage(self.image);
}
