const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const args = try init.minimal.args.toSlice(init.arena.allocator());
    for (args[1..]) |path| {
        std.Io.Dir.cwd().deleteFile(init.io, path) catch |err| switch (err) {
            error.FileNotFound => {},
            else => return err,
        };
    }
}
