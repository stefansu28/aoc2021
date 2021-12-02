const std = @import("std");
const print = std.debug.print;

pub fn main() anyerror!void {
    const allocator = std.heap.page_allocator;
    const flags = std.fs.File.OpenFlags {
        .read = true
    };
    const filename = std.mem.spanZ(std.os.argv[1]);// std.process.args().nextPosix() orelse "";
    print("filename: {s}\n", .{filename});
    const input = try std.fs.openFileAbsolute(filename, flags);
    defer input.close();
    const reader = input.reader();

    var buffer: [100]u8 = undefined;
    var n: u8 = 0;
    while (reader.readUntilDelimiterOrEof(buffer[0..], ' ')) |lineOption| {
        if (lineOption) |line| {
            // print("{s}\n", .{line});
            // var command: [10]u8 = undefined;
            switch (line) {
                "forward" => print("movin forward"),
                else => {}
            }
            
        } else break;
    } else |err| {
        print("error: {}\n", .{err});
        unreachable;
    }
    
    // var inc: u32 = 0;
    // var last: u32 = 9999*3;
    // var n: u32 = 1;
    // while (n < input.len - 1) {
    //     const sum = input[n - 1] + input[n] + input[n + 1];
    //     if (sum > last) inc += 1;
    //     last = sum;
    //     n += 1;
    // }
    // print("incs: {}", .{inc});
}
