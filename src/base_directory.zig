const std = @import("std");

/// The caller owns the returned memory
pub fn getHome(allocator: std.mem.Allocator) ![]const u8 {
    return std.process.getEnvVarOwned(allocator, "HOME");
}

/// The caller owns the returned memory
pub fn getDataHome(allocator: std.mem.Allocator) ![]const u8 {
    return std.process.getEnvVarOwned(allocator, "XDG_DATE_HOME") catch blk: {
        const home = try getHome(allocator);
        defer allocator.free(home);
        break :blk std.fs.path.join(allocator, &.{ home, ".local/share" });
    };
}

/// The caller owns the returned memory
pub fn getDataHomeApp(allocator: std.mem.Allocator, app: []const u8) ![]const u8 {
    const data_home = try getDataHome(allocator);
    defer allocator.free(data_home);
    return std.fs.path.join(allocator, &.{ data_home, app });
}
