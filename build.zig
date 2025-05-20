const std = @import("std");

pub const LinuxDisplayBackend = enum {
    X11,
    Wayland,
    Both,
};


pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("sakana", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/root.zig"),
    });

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "sakana",
        .root_module = mod,
    });

    const raylib = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
        .linux_display_backend = b.option(LinuxDisplayBackend, "linux_display_backend", "Linux display backend to use") orelse .Both,
    });

    lib.linkLibrary(raylib.artifact("raylib"));
    lib.linkSystemLibrary("fontconfig");
    lib.linkLibC();

    const c = b.addTranslateC(.{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/c.c"),
    });

    // Add raylib header files to the include paths
    c.addIncludePath(raylib.builder.path("src"));

    // Allow @import("c")
    lib.root_module.addImport("c", c.createModule());

    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
