const std = @import("std");

pub fn cast(T: type, value: anytype) !T {
    const InT = @TypeOf(value);
    return switch (T) {
        i32 => switch (InT) {
            f32 => @intFromFloat(value),
            else => return error.NotDefinedInputType,
        },
        else => return error.NotDefinedOutputType,
    };
}

pub const Vector2 = struct {
    const Self = @This();

    x: f32,
    y: f32,

    pub fn init(x: f32, y: f32) Self {
        return .{ .x = x, .y = y };
    }

    pub fn scaleTo(self: Self, max: Self) Self {
        const aspect = self.x / self.y;

        if (max.x / max.y > aspect) {
            return .{
                .x = max.y * aspect,
                .y = max.y,
            };
        } else {
            return .{
                .x = max.x,
                .y = max.x / aspect,
            };
        }
    }

    pub fn getX(self: Self, T: type) !T {
        return cast(T, self.x);
    }

    pub fn getY(self: Self, T: type) !T {
        return cast(T, self.y);
    }
};
