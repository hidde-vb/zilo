const std = @import("std");

var orig_term: std.posix.termios = undefined;

fn enableRawMode() !void {
    const tty = try std.fs.openFileAbsolute("/dev/tty", .{ .mode = .read_write });
    defer tty.close();

    var term = try std.posix.tcgetattr(tty.handle);
    orig_term = term;

    // Disable all flags for raw mode.
    term.iflag.BRKINT = false;
    term.iflag.IXON = false;
    term.iflag.ICRNL = false;
    term.iflag.INPCK = false;
    term.iflag.ISTRIP = false;

    term.oflag.OPOST = false;

    term.lflag.ECHO = false;
    term.lflag.ICANON = false;
    term.lflag.IEXTEN = false;
    term.lflag.ISIG = false;

    term.cc[@intFromEnum(std.posix.V.MIN)] = 0;
    term.cc[@intFromEnum(std.posix.V.TIME)] = 1;
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

    while (true) {
        const char: u8 = stdin.takeByte() catch 0;

        if (std.ascii.isControl(char)) {
            std.debug.print("{d}\r\n", .{char});
        } else {
            std.debug.print("{d} ('{c}')\r\n", .{ char, char });
        }

        if (char == 'q') break;
    }

    try disableRawMode();
}
