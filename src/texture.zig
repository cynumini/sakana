const std = @import("std");

const c = @import("c.zig").c;
const Shader = @import("shader.zig");
pub const math = @import("math.zig");

const Self = @This();

id: u32,
size: math.Vector2,

pub fn initFromPath(file_name: []const u8) !Self {
    var id: u32 = undefined;

    c.glGenTextures(1, @ptrCast(&id));
    c.glBindTexture(c.GL_TEXTURE_2D, id);

    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_REPEAT);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_REPEAT);

    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_LINEAR);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_LINEAR);

    var width: i32 = undefined;
    var height: i32 = undefined;
    var channels_in_file: i32 = undefined;
    const image = c.stbi_load(file_name.ptr, &width, &height, &channels_in_file, 4);
    defer c.stbi_image_free(image);

    if (image != 0) {
        c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGBA, width, height, 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, image);
        c.glGenerateMipmap(c.GL_TEXTURE_2D);
    } else {
        return error.TextureLoadingError;
    }

    return .{ .id = id, .size = .{ @floatFromInt(width), @floatFromInt(height) } };
}

pub fn initFromMemory(data: []const u8) !Self {
    var id: u32 = undefined;

    c.glGenTextures(1, @ptrCast(&id));
    c.glBindTexture(c.GL_TEXTURE_2D, id);

    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_REPEAT);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_REPEAT);

    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_LINEAR);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_LINEAR);

    var width: i32 = undefined;
    var height: i32 = undefined;
    var channels_in_file: i32 = undefined;
    const image = c.stbi_load_from_memory(
        data.ptr,
        @intCast(data.len),
        &width,
        &height,
        &channels_in_file,
        4,
    );
    defer c.stbi_image_free(image);

    if (image != 0) {
        c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGBA, width, height, 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, image);
        c.glGenerateMipmap(c.GL_TEXTURE_2D);
    } else {
        return error.TextureLoadingError;
    }

    return .{ .id = id, .size = .{ @floatFromInt(width), @floatFromInt(height) } };
}

pub fn bind(self: Self) void {
    c.glActiveTexture(c.GL_TEXTURE0);
    c.glBindTexture(c.GL_TEXTURE_2D, self.id);
}

pub fn deinit(self: *Self) void {
    c.glDeleteTextures(1, @ptrCast(&self.id));
}
