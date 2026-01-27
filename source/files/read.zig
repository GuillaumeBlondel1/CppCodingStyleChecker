const std = @import("std");

const allocator = @import("../allocator.zig");

pub fn read_from_path(path: []const u8) ![]const u8
{
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const file_stats = try file.stat();
    const file_size = file_stats.size;

    const file_content = try allocator.gpa_allocator.alloc(u8, file_size);
    _ = try file.readAll(file_content);
    return file_content;
}

pub fn read_from_file(file: *const std.fs.File) ![]const u8
{
    const file_stats = try file.stat();
    const file_size = file_stats.size;

    const file_content = try allocator.gpa_allocator.alloc(u8, file_size);
    _ = try file.readAll(file_content);
    return file_content;
}