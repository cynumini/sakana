const std = @import("std");

pub const Vector2 = @Vector(2, f32);
pub const Vector3 = @Vector(3, f32);
pub const Vector4 = @Vector(4, f32);

pub const Matrix = struct {
    const Self = @This();

    items: [4]Vector4,

    pub fn identity() Self {
        return .{ .items = .{
            .{ 1, 0, 0, 0 },
            .{ 0, 1, 0, 0 },
            .{ 0, 0, 1, 0 },
            .{ 0, 0, 0, 1 },
        } };
    }

    pub fn scale(len: comptime_int, vector: @Vector(len, f32)) Self {
        var matrix = comptime Self.identity();

        for (0..len) |i| {
            matrix.items[i][i] = vector[i];
        }

        return matrix;
    }

    pub fn translate(len: comptime_int, vector: @Vector(len, f32)) Self {
        var matrix = comptime Self.identity();

        for (0..len) |i| {
            matrix.items[i][3] = vector[i];
        }

        return matrix;
    }

    pub fn ortho(left: f32, right: f32, bottom: f32, top: f32, near_plane: f32, far_plane: f32) Matrix {
        const rl = right - left;
        const tb = top - bottom;
        const @"fn" = far_plane - near_plane;

        return .{ .items = .{
            .{ 2.0 / rl, 0, 0, -(left + right) / rl },
            .{ 0, 2.0 / tb, 0, -(top + bottom) / tb },
            .{ 0, 0, -2.0 / @"fn", -(far_plane + near_plane) / @"fn" },
            .{ 0, 0, 0, 1 },
        } };
    }

    pub fn column(self: Self, j: usize) Vector4 {
        return .{
            self.items[0][j],
            self.items[1][j],
            self.items[2][j],
            self.items[3][j],
        };
    }

    pub fn row(self: Self, i: usize) Vector4 {
        return self.items[i];
    }

    pub fn multiply(left: Self, right: Self) Self {
        return .{ .items = .{
            .{
                @reduce(.Add, left.row(0) * right.column(0)),
                @reduce(.Add, left.row(0) * right.column(1)),
                @reduce(.Add, left.row(0) * right.column(2)),
                @reduce(.Add, left.row(0) * right.column(3)),
            },
            .{
                @reduce(.Add, left.row(1) * right.column(0)),
                @reduce(.Add, left.row(1) * right.column(1)),
                @reduce(.Add, left.row(1) * right.column(2)),
                @reduce(.Add, left.row(1) * right.column(3)),
            },
            .{
                @reduce(.Add, left.row(2) * right.column(0)),
                @reduce(.Add, left.row(2) * right.column(1)),
                @reduce(.Add, left.row(2) * right.column(2)),
                @reduce(.Add, left.row(2) * right.column(3)),
            },
            .{
                @reduce(.Add, left.row(3) * right.column(0)),
                @reduce(.Add, left.row(3) * right.column(1)),
                @reduce(.Add, left.row(3) * right.column(2)),
                @reduce(.Add, left.row(3) * right.column(3)),
            },
        } };
    }

    pub fn toFloat(self: Self) [16]f32 {
        var result: [16]f32 = undefined;
        for (0..4) |i| {
            for (0..4) |j| {
                result[i * 4 + j] = self.items[j][i];
            }
        }
        return result;
    }
};
