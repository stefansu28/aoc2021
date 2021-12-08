const std = @import("std");
const util = @import("util");
const print = std.debug.print;

const Pair = struct {
    row: u8,
    col: u8
};

const BoardEntry = struct {
    value: u8,
    marked: bool = false
};

const BingoBoard = struct {
    data: [5][5]BoardEntry = undefined,

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
                const num = try std.fmt.parseInt(u8, intString, 10);
                board.data[row][col] = BoardEntry{.value = num};
                line = line[intString.len..];
            }
        }

        return board;
    }

    fn findNumber(self: *const BingoBoard, num: u8) ?Pair {
        for (self.data) |row, m| {
            for (row) |entry, n| {
                if (entry.value == num) {
                    // print("found value at {}, {}\n", .{m, n});
                    return Pair{.row = @intCast(u8, m), .col = @intCast(u8, n)};
                }
            }
        }

        return null;
    }

    fn mark(self: *BingoBoard, row: u8, col: u8) bool {
        self.data[row][col].marked = true;
        var n: u4 = 0;
        var rowBingo = true;
        var colBingo = true;
        while (n < 5) : (n += 1) {
            if (!self.data[row][n].marked) {
                rowBingo = false;
            }
            if (!self.data[n][col].marked) {
                colBingo = false;
            }
        }
        return rowBingo or colBingo;
    }

    fn unmarkedSum(self: *const BingoBoard) u32 {
        var sum: u32 = 0;
        for (self.data) |row| {
            for (row) |entry| {
                if (!entry.marked) sum += entry.value;
            }
        }
        return sum;
    }

    fn makeDummy(self: *BingoBoard) void {
        for (self.data) |row, m| {
            for (row) |_, n| {
                self.data[m][n] = BoardEntry{.value = 0};
            }
        }
    }

    fn printBoard(self: *const BingoBoard) void {
        for (self.data) |row| {
            for (row) |val| {
                const marked = if (val.marked) "x" else " ";
                print("{}{s} ", .{val.value, marked});
                // print("{} ", .{val});
            }
            print("\n", .{});
        }
    }
};

fn part1(reader: std.fs.File.Reader) anyerror!u32 {
    var buff: [1<<20]u8 = undefined;
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
    var lastNum: u8 = 0;

    const winningBoard: BingoBoard = outer: while (bingoVals.next()) |bingoStr| {
        const bingoVal = try std.fmt.parseInt(u8, bingoStr, 10);
        lastNum = bingoVal;
        // print("val: {}\n", .{bingoVal});

        for (boardSlice) |board, index| {
            // board.printBoard();
            // print("\n", .{});

            if (board.findNumber(bingoVal)) |coords| {
                const bingo = boardSlice[index].mark(coords.row, coords.col);
                if (bingo) break :outer boardSlice[index];
            }
        }
    } else unreachable;

    winningBoard.printBoard();

    return winningBoard.unmarkedSum() * lastNum;
}

fn part2(reader: std.fs.File.Reader) anyerror!u32 {
        var buff: [1<<20]u8 = undefined;
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
    var lastNum: u8 = 0;

    var winningBoard: BingoBoard = undefined;
    while (bingoVals.next()) |bingoStr| {
        const bingoVal = try std.fmt.parseInt(u8, bingoStr, 10);
        // print("val: {}\n", .{bingoVal});

        for (boardSlice) |board, index| {
            // board.printBoard();
            // print("\n", .{});

            if (board.findNumber(bingoVal)) |coords| {
                const bingo = boardSlice[index].mark(coords.row, coords.col);
                if (bingo) {
                    winningBoard = boardSlice[index];
                    lastNum = bingoVal;
                    boardSlice[index].makeDummy();
                }
            }
        }
    }

    winningBoard.printBoard();

    return winningBoard.unmarkedSum() * lastNum;
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
