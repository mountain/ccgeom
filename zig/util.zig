const std = @import("std");

const Allocator = std.mem.Allocator;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();
