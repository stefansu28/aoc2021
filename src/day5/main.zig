const std = @import("std");
const util = @import("util");
const print = std.debug.print;

const Point = struct {
    x: u16,
    y: u16
};

const Segment = struct {
    p1: Point,
    p2: Point
};

fn parseSegment(input: []u8) Segment {
    
}

fn part1(reader: std.fs.File.Reader) anyerror!u32 {
    var map: [1000][1000]u8 = undefined;

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
