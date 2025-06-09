const std = @import("std");

pub const Float = struct {
    value: f64,

    pub fn format(self: Float, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        var buffer: [64]u8 = undefined;
        var string = try std.fmt.bufPrint(&buffer, "{d:.2}", .{self.value});

        const decimal_index = std.mem.indexOfScalar(u8, string, '.') orelse string.len;
        for (string[0..decimal_index], 0..) |char, i| {
            if (i > 0 and (decimal_index - i) % 3 == 0) try writer.writeAll(",");
            try writer.writeByte(char);
        }
        try writer.writeAll(string[decimal_index..]);
    }
};
