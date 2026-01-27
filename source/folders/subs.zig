const std = @import("std");

const allocator = @import("../allocator.zig");
const path_manager = @import("../path_manager.zig");
const read_file = @import("../files/read.zig");
const spliters = @import("../utils/spliters.zig");

// ---- //

const simple_header_ext: []const u8 = ".h";
const cpp_header_ext: []const u8 = ".hpp";
const cpp_file_ext: []const u8 = ".cpp";

// ---- //

fn get_content(parent: []const u8, walker: *std.fs.Dir.Walker) !std.array_list.Aligned([]const u8, null)
{
    var sources_paths = try std.ArrayList([]const u8).initCapacity(allocator.gpa_allocator, 0);

    while (try walker.next()) |entry| {
        if (entry.kind != std.fs.File.Kind.file) {
            continue;
        }
        var path = try allocator.gpa_allocator.alloc(u8, parent.len + entry.path.len + 1);
        std.mem.copyForwards(u8, path[0..], parent);
        path[parent.len] = '/';
        std.mem.copyForwards(u8, path[(parent.len + 1)..], entry.path);
        try sources_paths.append(allocator.gpa_allocator, path);
    }
    return sources_paths;
}

fn check_ext(path: []const u8) bool
{
    const ext = std.fs.path.extension(path);

    if (std.mem.eql(u8, ext, simple_header_ext)) {
        return true;
    }
    if (std.mem.eql(u8, ext, cpp_header_ext)) {
        return true;
    }
    if (std.mem.eql(u8, ext, cpp_file_ext)) {
        return true;
    }
    return false;
}

pub fn get_subs(parent: []const u8, results: *const path_manager.PathResults) !void
{
    var dir = try results.get_dir();

    var walker = try dir.walk(allocator.gpa_allocator);
    defer walker.deinit();

    var sources_paths = try get_content(parent, &walker);
    defer {
        for (sources_paths.items) |item| {
            allocator.gpa_allocator.free(item);
        }
        sources_paths.deinit(allocator.gpa_allocator);
    }

    for (sources_paths.items) |path| {
        if (!check_ext(path)) {
            continue;
        }
        const content = try read_file.read_from_path(path);
        defer allocator.gpa_allocator.free(content);
        var lines = try spliters.split_lines(content);
        defer spliters.deinit(&lines);
    }
}
