const std = @import("std");

const days =  comptime ret: {
    const dayCount = 2;
    var vals: [dayCount]u8 = undefined;
    for (vals) |_, n| {
        vals[n] = n + 1;
    }
    break :ret vals;
};

fn intToString(comptime int: u32, comptime buf: []u8) ![]const u8 {
    return try std.fmt.bufPrint(buf, "{}", .{int});
}

pub fn build(b: *std.build.Builder) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    inline for (days) |day| {
        var buff: [128]u8 = undefined;

        const dayName = comptime blk: {
            var nameBuffer: [8]u8 = undefined;
            break :blk "day" ++ try intToString(day, &nameBuffer);
        };
        const src = try std.fmt.bufPrint(buff[0..], "src/day{}/main.zig", .{day});

        const exe = b.addExecutable(dayName, src);
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        var cwdBuff: [128]u8 = undefined;
        const cwd = try std.os.getcwd(cwdBuff[0..]);
        const arg = try std.fmt.bufPrint(&buff, "{s}/input/day{}", .{cwd, day});
        run_cmd.addArg(arg);

        const desc = try std.fmt.bufPrint(&buff, "Build and run day {}", .{day});
        const step = b.step(dayName, desc);
        step.dependOn(&run_cmd.step);
    }
}
