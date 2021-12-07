const std = @import("std");
const util = @import("util");
const print = std.debug.print;

fn part1(reader: std.fs.File.Reader) u32 {
    return 0;
}

fn part2(reader: std.fs.File.Reader) anyerror!u32 {
    return 0;
}

pub fn main() anyerror!void {
    const filename = std.mem.spanZ(std.os.argv[1]);
    const input = try util.openFile(filename);
    defer input.close();
    const reader = input.reader();

    print("part 1: {}\n", .{part1(reader)});

    try input.seekTo(0);
    print("part 2: {}\n", .{part2(reader)});
}
