const std = @import("std");
// pub const Vector2 = struct {
//     x: f32,
//     y: f32,
// };

pub const Matrix4f = struct {
    const Self = @This();

    data: [4]@Vector(4, f32),

    pub fn intIdentity() Self {
        return .{ .data = .{
            .{ 1, 0, 0, 0 },
            .{ 0, 1, 0, 0 },
            .{ 0, 0, 1, 0 },
            .{ 0, 0, 0, 1 },
        } };
    }

    pub fn initScale(scale: @Vector(3, f32)) Self {
        return .{ .data = .{
            .{ scale[0], 0, 0, 0 },
            .{ 0, scale[1], 0, 0 },
            .{ 0, 0, scale[2], 0 },
            .{ 0, 0, 0, 1 },
        } };
    }

    pub fn initTranslation(len: comptime_int, translation: @Vector(len, f32)) Self {
        var self = Self.intIdentity();
        for (0..len) |i| {
            self.data[i][3] = translation[i];
        }
        return self;
    }

    pub fn getColumn(self: Self, column: usize) @Vector(4, f32) {
        return .{
            self.data[0][column],
            self.data[1][column],
            self.data[2][column],
            self.data[3][column],
        };
    }

    pub fn multiplicationMatrix(self: Self, other: Self) Self {
        var data: [4]@Vector(4, f32) = undefined;
        for (0..4) |y| {
            for (0..4) |x| {
                data[y][x] = @reduce(.Add, self.data[y] * other.getColumn(x));
            }
        }
        return .{ .data = data };
    }

    pub fn multiplicationVector(self: Self, vector: @Vector(3, f32)) @Vector(3, f32) {
        var vector4f: @Vector(4, f32) = @splat(1);
        for (@as([3]f32, vector), 0..) |value, i| {
            vector4f[i] = value;
        }
        return .{
            @reduce(.Add, self.data[0] * vector4f),
            @reduce(.Add, self.data[1] * vector4f),
            @reduce(.Add, self.data[2] * vector4f),
        };
    }

    pub fn ortho(left: f32, right: f32, bottom: f32, top: f32, near: f32, far: f32) Self {
        return Self.initScale(.{
            2.0 / (right - left),
            2.0 / (top - bottom),
            2.0 / (far - near),
        }).multiplicationMatrix(Self.initTranslation(3, .{
            -(left + right) / 2,
            -(top + bottom) / 2,
            -(far + near) / 2,
        }));
    }
};
