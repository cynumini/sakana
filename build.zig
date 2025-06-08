const std = @import("std");

pub const LinuxDisplayBackend = enum {
    X11,
    Wayland,
    Both,
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_linux_display_backend = b.option(LinuxDisplayBackend, "raylib_linux_display_backend", "Linux display backend to use") orelse .Both;
    const include_raylib = b.option(bool, "include_raylib", "Include raylib in build") orelse true;
    const include_fontconfig = b.option(bool, "include_fontconfig", "Include fontconfig in build") orelse true;

    const options = b.addOptions();
    options.addOption(bool, "raylib", include_raylib);
    options.addOption(bool, "fontconfig", include_fontconfig);

    const mod = b.addModule("sakana", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("src/root.zig"),
    });

    mod.addOptions("config", options);

    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "sakana",
        .root_module = mod,
    });


    if (include_raylib) {
        const raylib = b.dependency("raylib", .{
            .target = target,
            .optimize = optimize,
            .linux_display_backend = raylib_linux_display_backend,
        });

        lib.linkLibrary(raylib.artifact("raylib"));

        const raylib_c = b.addTranslateC(.{
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path("src/raylib.c"),
        });

        // Add raylib header files to the include paths
        raylib_c.addIncludePath(raylib.builder.path("src"));

        lib.root_module.addImport("raylib", raylib_c.createModule());
    }

    if (include_fontconfig) {
        lib.linkSystemLibrary("fontconfig");

        const fontconfig_c = b.addTranslateC(.{
            .target = target,
            .optimize = optimize,
            .root_source_file = b.path("src/raylib.c"),
        });

        lib.root_module.addImport("fontconfig", fontconfig_c.createModule());
    }

    if (include_fontconfig or include_raylib) {
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
