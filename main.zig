const std = @import("std");

var orig_term: std.posix.termios = undefined;

fn enableRawMode() !void {
    const tty = try std.fs.openFileAbsolute("/dev/tty", .{ .mode = .read_write });
    defer tty.close();

    var term = try std.posix.tcgetattr(tty.handle);
    orig_term = term;

    term.lflag.ICANON = false;
    term.lflag.ECHO = false;

    try std.posix.tcsetattr(tty.handle, std.posix.TCSA.NOW, term);
}

fn disableRawMode() !void {
    const tty = try std.fs.openFileAbsolute("/dev/tty", .{ .mode = .read_write });
    defer tty.close();

    try std.posix.tcsetattr(tty.handle, std.posix.TCSA.NOW, orig_term);
}

pub fn main() !void {
    try enableRawMode();

    var buf: [128]u8 = undefined;
    var reader = std.fs.File.stdin().reader(&buf);
    const stdin = &reader.interface;

    while (stdin.takeByte()) |char| {
        if (char == 'q') break;

        if (std.ascii.isControl(char)) {
            std.debug.print("{d}\n", .{char});
        } else {
            std.debug.print("{d} ('{c}')\n", .{ char, char });
        }
    } else |_| {}

    try disableRawMode();
}
