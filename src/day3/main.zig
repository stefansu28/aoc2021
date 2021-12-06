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

    var current_values = values[0..lineCount];
    const max_bit: u16 = blk: {
        var max: u16 = 0;
        for (current_values) |value| {
            if (max < value) {
                max = value;
            }
        }
        var bit: u16 = 1 << 15;
        while (max & bit == 0) {
            bit >>= 1;
        }
        break :blk bit;
    };
    var current_bit: u16 = max_bit;

    while (current_values.len > 1) {
        // print("current bit: {b}\n", .{current_bit});
        // print("current len: {}\n", .{current_values.len});
        // for (current_values) |v, n| {
        //     print("index: {: >4}, val: {b:0>12}\n", .{n, v});
        // }

        var split: usize = 0;
        var count: u16 = 0;
        for (current_values) |value, index| {
            if (value & current_bit == 0) {
                const temp = current_values[split];
                current_values[split] = value;
                current_values[index] = temp;
                split += 1;
            } else {
                count += 1;
            }
        }

        // print("\ncount: {}\n", .{count});

        // for (current_values) |v, n| {
        //     print("index: {: >4}, val: {b:0>12}\n", .{n, v});
        // }

        if (count * 2 >= current_values.len) {
            current_values = current_values[split..];
        } else {
            current_values = current_values[0..split];
        }

        current_bit >>= 1;
    }

    const oxygen: u32 = current_values[0];

    current_values = values[0..lineCount];
    current_bit = max_bit;

    while (current_values.len > 1) {
        // print("current bit: {b}\n", .{current_bit});
        // print("current len: {}\n", .{current_values.len});
        // for (current_values) |v, n| {
        //     print("index: {: >4}, val: {b:0>12}\n", .{n, v});
        // }
        
        var split: usize = 0;
        var count: u16 = 0;
        for (current_values) |value, index| {
            if (value & current_bit == 0) {
                const temp = current_values[split];
                current_values[split] = value;
                current_values[index] = temp;
                split += 1;
            } else {
                count += 1;
            }
        }

        // print("\ncount: {}\n", .{count});

        // for (current_values) |v, n| {
        //     print("index: {: >4}, val: {b:0>12}\n", .{n, v});
        // }

        if (count * 2 >= current_values.len) {
            current_values = current_values[0..split];
        } else {
            current_values = current_values[split..];
        }

        current_bit >>= 1;
    }

    const co2: u32 = current_values[0];
    print("oxygen: {}, CO2 {}\n", .{oxygen, co2});

    return oxygen * co2;
}

pub fn main() anyerror!void {
    const flags = std.fs.File.OpenFlags {
        .read = true
    };
    const filename = std.mem.spanZ(std.os.argv[1]);
    var buff: [128]u8 = undefined;
    const fullFilename = blk: {
        if (filename[0] == '/') {
            break :blk filename;
        }
        var cwdBuff: [128]u8 = undefined;
        const cwd = try std.os.getcwd(cwdBuff[0..]);
        break :blk try std.fmt.bufPrint(&buff, "{s}/{s}", .{cwd, filename});
    };
    print("filename: {s}\n", .{fullFilename});
    const input = try std.fs.openFileAbsolute(fullFilename, flags);
    defer input.close();
    const reader = input.reader();

    print("part 1: {}\n", .{part1(reader)});

    try input.seekTo(0);
    print("part 2: {}\n", .{part2(reader)});
}
