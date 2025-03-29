const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("sakana", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/root.zig"),
    });

    mod.addIncludePath(b.path("deps/glad/include/"));
    mod.addIncludePath(b.path("deps/stb/include/"));
    mod.addCSourceFile(.{ .file = b.path("deps/stb/stb_image.c") });
    mod.addCSourceFile(.{ .file = b.path("deps/glad/src/glad.c") });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "sakana",
        .root_module = mod,
    });

    lib.linkSystemLibrary("glfw");
    lib.linkLibC();

    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
