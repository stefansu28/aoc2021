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

const lexCmp16 = comptime lexCmp(u16);

fn binarySearch(values: []u16, value: u16, offset: usize) usize {
    if (values.len == 1 or values[0] == value) return offset;
    const middle = values.len / 2;
    print("middle: {}\n", .{middle});
    print("middle value: {b:0>12}, search value: {b:0>12}, lessThan: {}\n", .{values[middle], value, lexCmp16({}, values[middle], value)});
    if (lexCmp16({}, values[middle], value) and (middle + 1 == values.len or lexCmp16({}, value, values[middle + 1]))) {
        return offset + middle;
    }
    if (lexCmp16({}, value, values[middle])) {
        return binarySearch(values[0..middle], value, offset);
    } else {
        return binarySearch(values[middle..], value, offset + middle);
    }
}

fn lexCmp(comptime T: type) fn (void, T, T) bool {
    const impl = struct {
        fn inner(context: void, a: T, b: T) bool {
            var current_bit: u16 = 1 << 11;
            while (current_bit > 0) {
                const aBit: u8 = if (current_bit & a != 0) 1 else 0;
                const bBit: u8 = if (current_bit & b != 0) 1 else 0;
                if (aBit != bBit) {
                    return aBit < bBit;
                }
                current_bit >>= 1;
            }

            return false;
        }
    };

    return impl.inner;
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

    std.sort.sort(u16, values, {}, comptime lexCmp(u16));

    var current_values = values[0..lineCount];
    var current_bit: u16 = blk: {
        const value = values[lineCount-1];
        var bit: u16 = 1 << 15;
        while (value & bit == 0) {
            bit >>= 1;
        }
        break :blk bit;
    };
    print("current bit: {b}\n", .{current_bit});
    var mask: u16 = 0;

    for (current_values) |value, index| {
        print("index: {: >4}, val: {b:0>12}\n", .{index, value});
    }

    var it: u8 = 0;

    while (current_values.len > 1) {
        print("current len: {}\n", .{current_values.len});
        const middle = current_values.len / 2;
        const cutoff = binarySearch(current_values, mask | current_bit - 1, 0);
        print("middle: {}, cutoff: {}\n", .{middle, cutoff});
        if (cutoff > middle) {
            current_values = current_values[0..cutoff];
        } else {
            current_values = current_values[cutoff+1..];
        }
        mask |= current_values[0] & current_bit;
        current_bit >>= 1;
    }

    const oxygen: u32 = current_values[0];

    current_values = values[0..lineCount];
    current_bit = 1 << 11;
    mask = 0;

    while (current_values.len > 1) {
        print("current len: {}\n", .{current_values.len});
        const middle = current_values.len / 2;
        const cutoff = binarySearch(current_values, mask | current_bit - 1, 0);
        print("middle: {}, cutoff: {}\n", .{middle, cutoff});
        if (cutoff < middle) {
            current_values = current_values[0..cutoff];
        } else {
            current_values = current_values[cutoff..];
        }
        mask |= current_values[0] & current_bit;
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
    const input = try std.fs.openFileAbsolute(filename, flags);
    defer input.close();
    const reader = input.reader();

    print("part 1: {}\n", .{part1(reader)});

    try input.seekTo(0);
    print("part 2: {}\n", .{part2(reader)});
}
