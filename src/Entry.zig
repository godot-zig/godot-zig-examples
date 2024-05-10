const std = @import("std");
const Godot = @import("godot");
const C = Godot.C;
const builtin = @import("builtin");
const GPA = std.heap.GeneralPurposeAllocator(.{});

var gpa = GPA{};

pub export fn my_extension_init(p_get_proc_address: C.GDExtensionInterfaceGetProcAddress, p_library: C.GDExtensionClassLibraryPtr, r_initialization: [*c]C.GDExtensionInitialization) C.GDExtensionBool {
    const allocator = gpa.allocator();
    return Godot.registerPlugin(p_get_proc_address, p_library, r_initialization, allocator, &init, &deinit);
}

fn init(_: ?*anyopaque, p_level: C.GDExtensionInitializationLevel) void {
    if (p_level != C.GDEXTENSION_INITIALIZATION_SCENE) {
        return;
    }

    const ExampleNode = @import("ExampleNode.zig");
    Godot.registerClass(ExampleNode);
}

fn deinit(_: ?*anyopaque, p_level: C.GDExtensionInitializationLevel) void {
    if (p_level == C.GDEXTENSION_INITIALIZATION_CORE) {
        _ = gpa.deinit();
    }
}
