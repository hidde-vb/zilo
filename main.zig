const std = @import("std");

fn enableRawMode() !void {
    const tty = try std.fs.openFileAbsolute("/dev/tty", .{ .mode = .read_write });
    defer tty.close();

    var term = try std.posix.tcgetattr(tty.handle);
    // const orig = term;

    term.lflag.ECHO = false;

    try std.posix.tcsetattr(tty.handle, std.posix.TCSA.NOW, term);
    // defer std.posix.tcsetattr(tty.handle, std.posix.TCSA.NOW, orig) catch {};
}

pub fn main() !void {
    try enableRawMode();

    var buf: [128]u8 = undefined;
    var reader = std.fs.File.stdin().reader(&buf);
    const stdin = &reader.interface;

    while (stdin.takeByte()) |char| {
        if (char == 'q') return;

        std.debug.print("{c}", .{char});
    } else |_| {}
}
