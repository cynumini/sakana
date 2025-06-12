const std = @import("std");

pub const RunResult = struct {
    allocator: std.mem.Allocator,
    term: std.process.Child.Term,
    stdout: []u8,
    stderr: []u8,

    pub fn deinit(self: RunResult) void {
        self.allocator.free(self.stdout);
        self.allocator.free(self.stderr);
    }
};

pub fn run(args: struct {
    allocator: std.mem.Allocator,
    argv: []const []const u8,
    max_output_bytes: usize = 50 * 1024,
    expand_arg0: std.process.Child.Arg0Expand = .no_expand,
    progress_node: std.Progress.Node = std.Progress.Node.none,
    stdin: ?[]const u8 = null,
}) !RunResult {
    var child = std.process.Child.init(args.argv, args.allocator);
    child.stdin_behavior = .Pipe;
    child.stdout_behavior = .Pipe;
    child.stderr_behavior = .Pipe;
    child.expand_arg0 = args.expand_arg0;
    child.progress_node = args.progress_node;

    var stdout: std.ArrayListUnmanaged(u8) = .empty;
    errdefer stdout.deinit(args.allocator);
    var stderr: std.ArrayListUnmanaged(u8) = .empty;
    errdefer stderr.deinit(args.allocator);

    try child.spawn();
    errdefer {
        _ = child.kill() catch {};
    }

    if (args.stdin) |stdin| {
        try child.stdin.?.writeAll(stdin);
        child.stdin.?.close();
        child.stdin = null;
    }

    try child.collectOutput(args.allocator, &stdout, &stderr, args.max_output_bytes);

    return .{
        .allocator = args.allocator,
        .stdout = try stdout.toOwnedSlice(args.allocator),
        .stderr = try stderr.toOwnedSlice(args.allocator),
        .term = try child.wait(),
    };
}
