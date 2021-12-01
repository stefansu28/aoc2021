const std = @import("std");

const days =  [_]u8{
    1,
    2
};

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    // for (days) |day| {
    //     const buf: [20]u8 = undefined;
    //     const dayName: []u8 = try std.fmt.bufPrint(&buf, "day{}", .{day});
    //     const exe = b.addExecutable(dayName, "src/" + dayName + "/main.zig");
    //     exe.setTarget(target);
    //     exe.setBuildMode(mode);
    //     exe.install();

    //     const run_cmd = exe.run();
    //     run_cmd.addArgs("inputs/" + dayName);

    //     const step = b.step(dayName, "Build and run " + dayName);
    //     step.dependOn(&run_cmd.step);
    // }

    const exe = b.addExecutable("aoc1", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
