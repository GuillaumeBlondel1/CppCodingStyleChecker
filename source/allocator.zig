const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const gpa_allocator = gpa.allocator();

pub fn deinit_allocator() void
{
    _ = gpa.deinit();
}