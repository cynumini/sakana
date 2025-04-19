const std = @import("std");

pub const raylib = @import("raylib.zig");

pub fn cast(T: type, value: anytype) !T {
    const InT = @TypeOf(value);
    if (InT == T) return value;
    return switch (T) {
        i32 => switch (InT) {
            f32, comptime_float => @intFromFloat(value),
            else => {
                std.debug.print("from {} to {}\n", .{ T, InT });
                return error.NotDefinedInputType;
            },
        },
        f32 => switch (InT) {
            i32, comptime_int, c_int => @floatFromInt(value),
            else => {
                std.debug.print("from {} to {}\n", .{ InT, T });
                return error.NotDefinedInputType;
            },
        },
        else => return error.NotDefinedOutputType,
    };
}

pub const Vector2 = struct {
    const Self = @This();

    x: f32,
    y: f32,

    pub fn init(x: anytype, y: anytype) Self {
        return .{
            .x = cast(f32, x) catch unreachable,
            .y = cast(f32, y) catch unreachable,
        };
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

    pub fn scale(self: Self, value: f32) Self {
        return .init(self.x * value, self.y * value);
    }

    pub fn getX(self: Self, T: type) !T {
        return cast(T, self.x);
    }

    pub fn getY(self: Self, T: type) !T {
        return cast(T, self.y);
    }

    pub fn to_raylib(self: Self) raylib.Vector2 {
        return .{ .x = self.x, .y = self.y };
    }
};
