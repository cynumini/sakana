pub const Vector4 = @import("math.zig").Vector4;

const Self = @This();

r: u8,
g: u8,
b: u8,
a: u8,

pub fn normalize(color: Self) Vector4 {
    return .{
        @as(f32, @floatFromInt(color.r)) / 255.0,
        @as(f32, @floatFromInt(color.g)) / 255.0,
        @as(f32, @floatFromInt(color.b)) / 255.0,
        @as(f32, @floatFromInt(color.a)) / 255.0,
    };
}

pub const white: Self = .{ .r = 255, .g = 255, .b = 255, .a = 255 };
pub const black: Self = .{ .r = 0, .g = 0, .b = 0, .a = 255 };
