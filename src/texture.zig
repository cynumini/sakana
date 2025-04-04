const std = @import("std");

const c = @import("c.zig").c;
const Shader = @import("shader.zig");
pub const math = @import("math.zig");
pub const Vector2 = math.Vector2;
pub const Image = @import("image.zig");

const Self = @This();

id: u32,
size: math.Vector2,

pub fn initFromImage(image: Image) !Self {
    var id: u32 = undefined;

    c.glGenTextures(1, @ptrCast(&id));
    c.glBindTexture(c.GL_TEXTURE_2D, id);

    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_REPEAT);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_REPEAT);

    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_LINEAR);
    c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_LINEAR);

    c.glTexImage2D(c.GL_TEXTURE_2D, 0, c.GL_RGBA, image.size.intX(), image.size.intY(), 0, c.GL_RGBA, c.GL_UNSIGNED_BYTE, image.data);
    c.glGenerateMipmap(c.GL_TEXTURE_2D);

    std.debug.print("texture id: {}\n", .{id});
    return .{ .id = id, .size = image.size };
}

pub fn init(input_data: []const u8, data_type: Image.DataType) !Self {
    var image = try Image.init(input_data, data_type);
    defer image.deinit();
    return initFromImage(image);
}

pub fn bind(self: Self) void {
    c.glActiveTexture(c.GL_TEXTURE0);
    c.glBindTexture(c.GL_TEXTURE_2D, self.id);
}

pub fn deinit(self: Self) void {
    c.glDeleteTextures(1, @ptrCast(&self.id));
}
