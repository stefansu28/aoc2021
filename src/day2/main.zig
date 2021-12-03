const std = @import("std");
const print = std.debug.print;

fn getWord(str: []u8) []u8 {
    for (str) |c, n| {
        if (c == ' ') return str[0..n];
    }

    return str[0..];
}

pub fn main() anyerror!void {
    const flags = std.fs.File.OpenFlags {
        .read = true
    };
    const filename = std.mem.spanZ(std.os.argv[1]);
    const input = try std.fs.openFileAbsolute(filename, flags);
    defer input.close();
    const reader = input.reader();

    var horizontal: u64 = 0;
    var depth: u64 = 0;
    var aim: u64 = 0;

    var buffer: [100]u8 = undefined;
    while (reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |lineOption| {
        if (lineOption) |line| {
            const dir = getWord(line);
            const amount = try std.fmt.parseInt(u8, getWord(line[dir.len+1..]), 10);
            // print("dir: {s}, amount: {}\n", .{dir, amount});
            if (std.mem.eql(u8, dir, "forward")) {
                horizontal += amount;
                depth += aim*amount;
            } else if (std.mem.eql(u8, dir, "up")) {
                aim -= amount;
            } else if (std.mem.eql(u8, dir, "down")) {
                aim += amount;
            } else {
                unreachable;
            }
        } else break;
    } else |err| {
        print("error: {}\n", .{err});
        unreachable;
    }

    print("{}\n", .{horizontal * depth});
}
