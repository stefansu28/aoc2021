const std = @import("std");
const print = std.debug.print;

fn getWord(str: []u8) []u8 {
    for (str) |c, n| {
        if (c == ' ') return str[0..n];
    }

    return str[0..];
}

fn part1(reader: std.fs.File.Reader) u32 {
    var gamma: u32 = 0;
    var epsilon: u32 = 0;
    var counts = [_]u16{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
    var lineCount: u16 = 0;

    var buffer: [100]u8 = undefined;
    while (reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |lineOption| {
        if (lineOption) |line| {
            lineCount += 1;
            for (line) |bit, index| {
                if (bit == '1') counts[index] += 1;
            }
        } else break;
    } else |err| {
        print("error: {}\n", .{err});
        unreachable;
    }

    // print("counts: ", .{});
    for (counts) |bitCount| {
        //print("{} ", .{bitCount});
        gamma *= 2;
        epsilon *= 2;
        if (bitCount > lineCount / 2) {
            gamma += 1;
        } else {
            epsilon += 1;
        }
    }

    return gamma * epsilon;
}

fn binarySearch(values: []u16, value: u16, offset: usize) usize {
    if (values.len == 1) return offset;
    const middle = values.len / 2;
    print("middle value: {}, search value: {}\n", .{values[middle], value});
    if (values[middle] > value) {
        return binarySearch(values[0..middle], value, offset);
    } else {
        return binarySearch(values[middle..], value, offset + middle);
    }
}

fn part2(reader: std.fs.File.Reader) anyerror!u32 {
    const allocator = std.heap.page_allocator;

    var values: []u16 = try allocator.alloc(u16, 1000);
    defer allocator.free(values);
    var lineCount: u16 = 0;

    var buffer: [100]u8 = undefined;
    while (reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |lineOption| {
        if (lineOption) |line| {
            const value = try std.fmt.parseInt(u16, line, 2);
            values[lineCount] = value;
            lineCount += 1;
        } else break;
    } else |err| {
        print("error: {}\n", .{err});
        unreachable;
    }

    // std.sort.sort(u16, values, {}, comptime std.sort.asc(u16));

    var current_values = values[0..lineCount];
    var current_bit: u16 = 1 << 12;

    while (current_values.len > 1) {
        // print("current len: {}\n", .{current_values.len});
        // const middle = current_values.len / 2;
        // const cutoff = binarySearch(current_values, current_bit, 0);
        // print("middle: {}, cutoff: {}\n", .{middle, cutoff});
        // if (cutoff > middle) {
        //     current_values = current_values[0..cutoff];
        // } else {
        //     current_values = current_values[cutoff..];
        // }
        current_bit >>= 1;
        // break;
    }
    print("oxygen: {}\n", .{current_values[0]});

    return 0;
}

pub fn main() anyerror!void {
    const flags = std.fs.File.OpenFlags {
        .read = true
    };
    const filename = std.mem.spanZ(std.os.argv[1]);
    const input = try std.fs.openFileAbsolute(filename, flags);
    defer input.close();
    const reader = input.reader();

    print("part 1: {}\n", .{part1(reader)});

    try input.seekTo(0);
    print("part 2: {}\n", .{part2(reader)});
}
