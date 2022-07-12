const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();
    const ccgeom = b.addSharedLibrary("ccgeom", "zig/ccgeom.zig", b.version(0, 0, 0));
    ccgeom.setBuildMode(mode);
    ccgeom.install();

    const main_tests = b.addTest("zig/ccgeom.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);
}

fn baseDir() []const u8 {
    comptime {
        return std.fs.path.dirname(@src().file) orelse ".";
    }
}

