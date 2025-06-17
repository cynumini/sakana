const std = @import("std");

pub const LinuxDisplayBackend = enum {
    X11,
    Wayland,
    Both,
};

pub const Options = struct {
    raylib: struct {
        include: bool,
        linux_display_backend: LinuxDisplayBackend,
    },
    fontconfig: bool,
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const options: Options = .{
        .raylib = .{
            .include = b.option(bool, "raylib", "Compile with raylib support") orelse true,
            .linux_display_backend = b.option(LinuxDisplayBackend, "raylib_linux_display_backend", "Linux display backend to use") orelse .Both,
        },
        .fontconfig = b.option(bool, "fontconfig", "Compile with fontconfig support") orelse false,
    };

    const exposed_options = b.addOptions();
    exposed_options.addOption(bool, "raylib", options.raylib.include);
    exposed_options.addOption(bool, "fontconfig", options.fontconfig);

    const mod = b.addModule("sakana", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/root.zig"),
    });

    mod.addOptions("config", exposed_options);

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "sakana",
        .root_module = mod,
    });

    if (options.raylib.include) {
        const raylib_dep = b.dependency("raylib", .{
            .target = target,
            .optimize = optimize,
            .linux_display_backend = options.raylib.linux_display_backend,
        });

        lib.linkLibrary(raylib_dep.artifact("raylib"));

        const raylib_c_mod = b.addTranslateC(.{
            .root_source_file = raylib_dep.path("src/raylib.h"),
            .target = target,
            .optimize = optimize,
        }).createModule();

        const raylib_mod = b.addModule("raylib", .{
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path("src/raylib.zig"),
            .imports = &.{.{ .name = "raylib_c", .module = raylib_c_mod }},
        });

        _ = b.addModule("ui", .{
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path("src/ui.zig"),
            .imports = &.{.{ .name = "raylib", .module = raylib_mod }},
        });
    }

    if (options.fontconfig) {
        lib.linkSystemLibrary("fontconfig");

        const fontconfig_c = b.addTranslateC(.{
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path("src/fontconfig.c"),
        });

        lib.root_module.addImport("fontconfig", fontconfig_c.createModule());
    }

    if (options.fontconfig or options.raylib.include) {
        lib.linkLibC();
    }

    b.installArtifact(lib);

    const lib_unit_tests = b.addTest(.{
        .root_module = mod,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
