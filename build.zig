const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const godot_path = b.option([]const u8, "godot", "Path to Godot engine binary [default: `godot`]") orelse "godot";

    const lib = b.addSharedLibrary(.{
        .name = "example",
        .root_source_file = b.path("src/Entry.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib_godot = b.dependency("godot", .{
        .godot_path = godot_path,
    });

    const godot = lib_godot.module("godot");
    lib.root_module.addImport("godot", godot);

    var bind_step = b.step("bind", "Generate Godot bindings");
    bind_step.dependOn(&lib_godot.builder.top_level_steps.get("bind").?.step);

    // use explicit imports to make jump work properly
    // todo: remove this once zls get improved
    var iter = godot.import_table.iterator();
    while (iter.next()) |it| {
        lib.root_module.addImport(it.key_ptr.*, it.value_ptr.*);
    }
    /////////////////////////////////////////////////

    b.lib_dir = "./project/lib";
    b.exe_dir = "./project/lib";
    b.installArtifact(lib);

    const run_cmd = b.addSystemCommand(&.{
        godot_path, "--path", "./project",
    });
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run with Godot");
    run_step.dependOn(&run_cmd.step);
}
