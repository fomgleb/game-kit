const std = @import("std");
const FpsLimiter = @This();

timer: std.time.Timer,
max_ns_per_frame: u64,

pub fn init(max_fps: u64) !FpsLimiter {
    return @This(){
        .timer = try .start(),
        .max_ns_per_frame = std.time.ns_per_s / max_fps,
    };
}

pub fn waitFrameEnd(self: *FpsLimiter) void {
    std.Thread.sleep(self.max_ns_per_frame -| self.timer.lap());
}
