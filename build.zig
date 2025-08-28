const std = @import("std");

pub fn build(b: *std.Build) void {
    const t = b.standardTargetOptions(.{});
    const o = b.standardOptimizeOption(.{});

    const embed_resources = b.option(bool, "embed-resources", "Embed contents of `resources` folder into the executable?");
    const options = b.addOptions();
    options.addOption(bool, "embed_resources", embed_resources orelse false);

    b.modules.put(b.dupe("game_kit"), createModule(b, t, o, options, "src/root.zig")) catch @panic("OOM");

    createCheckCmd(b, t, o);

    const tests = b.addTest(.{ .root_module = createModule(b, t, o, options, "src/tests.zig") });
    const run_mod_tests = b.addRunArtifact(tests);
    b.step("test", "Run tests").dependOn(&run_mod_tests.step);
}

fn createCheckCmd(b: *std.Build, t: std.Build.ResolvedTarget, o: std.builtin.OptimizeMode) void {
    const options1 = b.addOptions();
    options1.addOption(bool, "embed_resources", true);
    const check_cmd1 = b.addExecutable(.{ .name = "check", .root_module = createModule(b, t, o, options1, "src/check.zig") });

    const options2 = b.addOptions();
    options2.addOption(bool, "embed_resources", false);
    const check_cmd2 = b.addExecutable(.{ .name = "check", .root_module = createModule(b, t, o, options2, "src/check.zig") });

    const check_step = b.step("check", "Check if the project compiles");
    check_step.dependOn(&check_cmd1.step);
    check_step.dependOn(&check_cmd2.step);
}

fn createModule(
    b: *std.Build,
    t: std.Build.ResolvedTarget,
    o: std.builtin.OptimizeMode,
    options: *std.Build.Step.Options,
    path: []const u8,
) *std.Build.Module {
    const mod = b.createModule(.{ .root_source_file = b.path(path), .target = t, .optimize = o });
    mod.linkLibrary(b.dependency("sdl", .{ .target = t, .optimize = o }).artifact("SDL3"));
    mod.linkLibrary(b.dependency("sdl_image", .{ .target = t, .optimize = o }).artifact("SDL3_image"));
    mod.linkLibrary(b.dependency("sdl_ttf", .{ .target = t, .optimize = .ReleaseFast }).artifact("SDL3_ttf"));
    mod.addOptions("config", options);
    return mod;
}
