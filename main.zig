const std = @import("std");

pub fn main() !void {
    var buf: [256]u8 = undefined;
    var reader = std.fs.File.stdin().reader(&buf);
    const stdin = &reader.interface;

    while (stdin.takeByte()) |char| {
        if (char == 'q') return;

        std.debug.print("{c}", .{char});
    } else |_| {}
}
