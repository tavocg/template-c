const std = @import("std");

/// Generate Clang's own compilation records from the executable's C module.
pub fn addStep(b: *std.Build, exe: *std.Build.Step.Compile) void {
    const module = exe.root_module;
    const compile = addCompile(b, exe);
    const merger = b.addExecutable(.{
        .name = "compdb",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/compdb.zig"),
            .target = b.graph.host,
        }),
    });
    const merge = b.addRunArtifact(merger);
    const database = merge.addOutputFileArg2("compile_commands.json", .{});
    for (module.link_objects.items, 0..) |object, group| switch (object) {
        .c_source_file => |source| merge.addFileArg2(addRecord(compile, source.*, b.fmt("{d}.json", .{group})), .{}),
        .c_source_files => |sources| for (sources.files, 0..) |file, index| {
            merge.addFileArg2(addRecord(compile, .{
                .file = sources.root.path(b, file),
                .flags = sources.flags,
                .language = sources.language,
            }, b.fmt("{d}-{d}.json", .{ group, index })), .{});
        },
        else => {},
    };
    const update = b.addUpdateSourceFiles();
    update.addCopyFileToSource(database, "compile_commands.json");
    b.step("compdb", "Generate compile_commands.json for the selected target").dependOn(&update.step);
}

fn addCompile(b: *std.Build, exe: *std.Build.Step.Compile) *std.Build.Step.Run {
    const module = exe.root_module;
    const query = module.resolved_target.?.query;
    const compile = b.addSystemCommand(&.{ b.graph.zig_exe, "build-exe" });
    // Re-emit records even when headers change or Zig already cached the binary.
    compile.has_side_effects = true;
    compile.setCwd(b.path(""));
    compile.addArgs(&.{
        b.fmt("-O{t}", .{module.optimize orelse .debug}),
        "-target",
        query.zigTriple(b.allocator) catch @panic("OOM"),
        b.fmt("-mcpu={s}", .{query.serializeCpuAlloc(b.allocator) catch @panic("OOM")}),
    });
    if (module.link_libc orelse false) compile.addArg("-lc");
    if (module.strip orelse false) compile.addArg("-fstrip");
    compile.addArgs(module.c_macros.items);
    for (module.include_dirs.items) |include| {
        const flag: []const u8 = switch (include) {
            .path, .config_header_step => "-I",
            .path_system => "-isystem",
            .path_after => "-idirafter",
            .framework_path => "-F",
            .framework_path_system => "-iframework",
            .embed_path => "--embed-dir",
            .other_step => @panic("compdb: use explicit include paths for linked libraries"),
        };
        const path = switch (include) {
            .config_header_step => |header| header.getOutputDir(),
            .other_step => unreachable,
            inline else => |path| path,
        };
        compile.addArg(flag);
        compile.addDirectoryArg2(path, .{ .make_absolute = true });
    }
    _ = compile.addOutputFileArg2(exe.out_filename, .{ .prefix = "-femit-bin=" });
    return compile;
}

fn addRecord(compile: *std.Build.Step.Run, source: std.Build.Module.CSourceFile, name: []const u8) std.Build.LazyPath {
    compile.addArg("-cflags");
    compile.addArgs(source.flags);
    if (source.language) |language| compile.addArgs(&.{ "-x", language.clangIdentifier() });
    compile.addArg("-MJ");
    const record = compile.addOutputFileArg2(name, .{});
    compile.addArg("--");
    compile.addFileArg2(source.file, .{ .make_absolute = true });
    return record;
}

pub fn main(init: std.process.Init) !void {
    const arena = init.arena.allocator();
    const args = try init.minimal.args.toSlice(arena);
    var entries: std.ArrayList(std.json.Value) = .empty;
    for (args[2..]) |path| {
        const fragment = try std.Io.Dir.cwd().readFileAlloc(init.io, path, arena, .limited(16 * 1024 * 1024));
        const json = std.mem.trim(u8, fragment, " \r\n\t,");
        const parsed = try std.json.parseFromSlice(std.json.Value, arena, json, .{});
        // -MJ records Clang driver arguments, not a replayable `zig cc` command.
        parsed.value.object.getPtr("arguments").?.array.items[0] = .{ .string = "clang" };
        try entries.append(arena, parsed.value);
    }
    const json = try std.json.Stringify.valueAlloc(arena, entries.items, .{ .whitespace = .indent_2 });
    try std.Io.Dir.cwd().writeFile(init.io, .{ .sub_path = args[1], .data = json });
}
