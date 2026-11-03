const std = @import("std");
const compdb = @import("tools/compdb.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const version = b.option([]const u8, "version", "Application version") orelse "0.1.0";
    const exe = addExecutable(b, target, optimize, version);

    b.installArtifact(exe);
    installManpage(b, version);
    addRunStep(b, exe);
    addTestStep(b, exe);
    addUninstallStep(b, exe);
    compdb.addStep(b, exe);
}

fn addExecutable(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    version: []const u8,
) *std.Build.Step.Compile {
    const module = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .strip = optimize != .debug,
    });
    module.addCSourceFiles(.{
        .files = &.{ "foobar/main.c", "foobar/alpha/alpha.c" },
        .flags = &.{ "-std=c89", "-pedantic-errors", "-Werror", "-Wall", "-Wextra" },
    });
    module.addIncludePath(b.path("."));
    module.addCMacro("VERSION", b.fmt("\"{s}\"", .{version}));
    return b.addExecutable(.{ .name = "foobar", .root_module = module });
}

fn installManpage(b: *std.Build, version: []const u8) void {
    const manpage = std.mem.replaceOwned(
        u8,
        b.allocator,
        @embedFile("man/man1/foobar.1"),
        "VERSION",
        version,
    ) catch @panic("OOM");
    const generated = b.addWriteFiles();
    const install = b.addInstallFile(generated.add("foobar.1", manpage), "share/man/man1/foobar.1");
    b.getInstallStep().dependOn(&install.step);
}

fn addRunStep(b: *std.Build, exe: *std.Build.Step.Compile) void {
    const run = b.addRunArtifact(exe);
    run.addPassthruArgs();
    b.step("run", "Run foobar").dependOn(&run.step);
}

fn addTestStep(b: *std.Build, exe: *std.Build.Step.Compile) void {
    const run = b.addRunArtifact(exe);
    run.expectStdOutEqual("Hello, world!\n");
    run.expectExitCode(0);
    b.step("test", "Check the executable's output and exit status").dependOn(&run.step);
}

fn addUninstallStep(b: *std.Build, exe: *std.Build.Step.Compile) void {
    // Zig exposes an uninstall step but does not populate it automatically.
    const remover = b.addExecutable(.{
        .name = "uninstall",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/uninstall.zig"),
            .target = b.graph.host,
        }),
    });
    const run = b.addRunArtifact(remover);
    run.has_side_effects = true;
    const bin: std.Build.LazyPath = .{ .relative = .{ .base = .install_bin } };
    const prefix: std.Build.LazyPath = .{ .relative = .{ .base = .install_prefix } };
    run.addDirectoryArg2(bin, .{ .suffix = b.fmt("/{s}", .{exe.out_filename}) });
    run.addDirectoryArg2(prefix, .{ .suffix = "/share/man/man1/foobar.1" });
    if (exe.root_module.resolved_target.?.result.os.tag == .windows)
        run.addDirectoryArg2(bin, .{ .suffix = "/foobar.pdb" });
    b.getUninstallStep().dependOn(&run.step);
}
