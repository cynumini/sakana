pub const math = @import("math.zig");
pub const raylib = @import("raylib.zig");

pub const Image = @import("image.zig");

const Self = @This();

size: math.Vector2,
texture2D: raylib.Texture2D,

pub fn initFromImage(image: Image) !Self {
    return .{ .size = image.size, .texture2D = raylib.loadTextureFromImage(image.image) };
}

pub fn init(input_data: []const u8, data_type: Image.DataType) !Self {
    switch (data_type) {
        .memory => {
            const image = try Image.init(input_data, .memory);
            defer image.deinit();
            return Self.initFromImage(image);
        },
        .path => {
            const texture2D = raylib.loadTexture(input_data.ptr);
            return .{
                .size = math.Vector2.init(texture2D.width, texture2D.height),
                .texture2D = texture2D,
            };
        },
    }
}

pub fn deinit(self: *Self) void {
    raylib.unloadTexture(self.texture2D);
}
