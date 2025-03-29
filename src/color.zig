const Self = @This();

r: f32,
g: f32,
b: f32,
a: f32,

pub fn init(r: u8, g: u8, b: u8, a: u8) Self {
    return .{
        .r = @as(f32, @floatFromInt(r)) / 255,
        .g = @as(f32, @floatFromInt(g)) / 255,
        .b = @as(f32, @floatFromInt(b)) / 255,
        .a = @as(f32, @floatFromInt(a)) / 255,
    };
}

pub const white = Self.init(255, 255, 255, 255);
pub const black = Self.init(0, 0, 0, 255);
