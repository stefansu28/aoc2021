const std = @import("std");
const util = @import("util");
const print = std.debug.print;

const BingoBoard = struct {
    data: [5][5]u8 = undefined,
    columnCounts: [5]u8 = []u8{0, 0, 0, 0, 0},
    rowCounts: [5]u8 = []u8{0, 0, 0, 0, 0},

    fn parseBoard(reader: std.fs.File.Reader) anyerror!BingoBoard {
        var board = BingoBoard{};
        var row: usize = 0;
        var buffer: [100]u8 = undefined;
        while (row < 5): (row += 1) {
            var line = (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) orelse unreachable;
            var col: usize = 0;
            while (col < 5): (col += 1) {
                line = util.eatWhitespace(line);
                const intString = util.getWord(line);
                board.data[row][col] = try std.fmt.parseInt(u8, intString, 10);
                line = line[intString.len..];
            }
        }

        return board;
    }

    fn findNumer(self: *BingoBoard, num: u8) ?struct{row: u8, col: u8} {
        for (self.data) |row, m| {
            for (row) |value, n| {
                if (value == num) {
                    return .{.row = m, .col = n};
                }
            }
        }

        return null;
    }

    fn updateCounts(self: *BingoBoard, row: u8, col: u8) bool {
        columnCounts[col] += 1;
        rowCounts[row] += 1;
        return columnCounts[col] == 5 or rowCounts[row] == 5;
    }

    fn printBoard(self: *BingoBoard) void {
        for (self.data) |row| {
            for (row) |val| {
                print("{} ", .{val});
            }
            print("\n", .{});
        }
    }
};

fn part1(reader: std.fs.File.Reader) anyerror!u32 {
    var buff: [1<<10]u8 = undefined;
    var allocator = std.heap.FixedBufferAllocator.init(buff[0..]);

    var buffer: [512]u8 = undefined;
    const line = (try reader.readUntilDelimiterOrEof(buffer[0..], '\n')) orelse unreachable;
    var bingoVals = std.mem.split(line, ",");

    var boardList = std.ArrayList(BingoBoard).init(&allocator.allocator);
    // defer boardList.deinit();

    while (reader.readUntilDelimiterOrEof(buffer[0..], '\n')) |lineOption| {
        if (lineOption) |_| {
            var board = try BingoBoard.parseBoard(reader);
            try boardList.append(board);
            // board.printBoard();
            // print("\n", .{});
        } else break;
    } else |err| {
        unreachable;
    }

    var boardSlice = boardList.toOwnedSlice();

    while (bingoVals.next()) |bingoStr| {
        const bingoVal = std.fmt.parseInt(u8, bingoStr, 10);
        // print("val: {}\n", .{bingoVal});

        for (boardSlice) |board| {
            board.printBoard();
        }
    }
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
