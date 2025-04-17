const std = @import("std");

pub const raylib = @import("raylib.zig");
pub const math = @import("math.zig");

const Self = @This();

image: raylib.Image,
size: math.Vector2,

pub const DataType = enum { path, memory };

pub const FileType = enum { png, jpeg };

pub fn init(input_data: []const u8, data_type: DataType, fileType: FileType) !Self {
    const file_type = switch (fileType) {
        .jpeg => ".jpeg",
        .png => ".png",
    };
    const image = switch (data_type) {
        .memory => raylib.loadImageFromMemory(file_type, input_data.ptr, @intCast(input_data.len)),
        .path => raylib.loadImage(input_data.ptr),
    };
    return .{
        .image = image,
        .size = math.Vector2.init(
            @floatFromInt(image.width),
            @floatFromInt(image.height),
        ),
    };
}

pub fn deinit(self: *Self) void {
    raylib.unloadImage(self.image);
}
