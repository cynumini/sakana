const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const sakana_mod = b.addModule(
        "sakana",
        .{
            .root_source_file = b.path("src/sakana.zig"),
            .optimize = optimize,
            .target = target,
        },
    );

    const test_step = b.step("test", "Run tests");
    const tests = b.addTest(.{ .root_module = sakana_mod });
    const run_tests = b.addRunArtifact(tests);
    test_step.dependOn(&run_tests.step);
}
