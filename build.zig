const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const godot_path = b.option([]const u8, "godot", "Path to Godot engine binary [default: `godot`]") orelse "godot";

    const lib = b.addSharedLibrary(.{
        .name = "example",
        .root_source_file = .{ .path = "src/Entry.zig" },
        .target = target,
        .optimize = optimize,
    });

    const godot_zig_build = @import("./godot-zig/build.zig");
    const godot = godot_zig_build.createModule(b, target, optimize, godot_path);
    lib.root_module.addImport("godot", godot);

    // use explicit imports to make jump work properly
    // todo: remove this once zls get improved
    var iter = godot.import_table.iterator();
    while (iter.next()) |it| {
        lib.root_module.addImport(it.key_ptr.*, it.value_ptr.*);
    }
    /////////////////////////////////////////////////

    b.lib_dir = "./project/lib";
    b.installArtifact(lib);

    const project_path = .{ .path = "./project" };
    const load_cmd = b.addSystemCommand(&.{
        godot_path, "--headless", "--quit", "--editor", "--path",
    });
    load_cmd.addDirectoryArg(project_path);
    load_cmd.expectExitCode(1);
    load_cmd.step.dependOn(b.getInstallStep());
    const load_step = b.step("load", "Load project");
    load_step.dependOn(&load_cmd.step);

    const run_cmd = b.addSystemCommand(&.{
        godot_path, "--path",
    });
    run_cmd.addDirectoryArg(project_path);
    run_cmd.step.dependOn(load_step);
    const run_step = b.step("run", "Run with Godot");
    run_step.dependOn(&run_cmd.step);
}
