const std = @import("std");

const allocator = @import("../allocator.zig");
const printables = @import("printables.zig");

pub const SpliterException = error {
    empty_content,
    no_correct_content
};

fn compute_nb_delimiters(content: []const u8, delimiter: u8) u32
{
    var nb: u32 = 0;

    for (content) |c| {
        if (c == delimiter) {
            nb += 1;
        }
    }
    return nb;
}

pub fn split_lines(content: []const u8) !std.array_list.Aligned([]const u8, null)
{
    const delimiter = '\n';
    const nb_lines = compute_nb_delimiters(content, delimiter);

    if (nb_lines == 0) {
        if (content.len == 0) {
            return SpliterException.empty_content;
        }
        if (!printables.contains_printables(content)) {
            return SpliterException.no_correct_content;
        }
        var line = try std.ArrayList([]const u8).initCapacity(allocator.gpa_allocator, 1);
        try line.append(allocator.gpa_allocator, content);
        return line;
    }
    var lines = try std.ArrayList([]const u8).initCapacity(allocator.gpa_allocator, nb_lines + 1);
    var split_it = std.mem.splitScalar(u8, content, delimiter);

    while (split_it.next()) |next| {
        var global_line: []u8 = try allocator.gpa_allocator.alloc(u8, next.len + 1);
        std.mem.copyForwards(u8, global_line, next);
        global_line[next.len] = '\n';
        try lines.append(allocator.gpa_allocator, global_line);
    }
    return lines;
}

pub fn split_by_delimiter(content: []const u8, delimiter: u8) !std.array_list.Aligned([]const u8, null)
{
    const nb_delimiters = compute_nb_delimiters(content, delimiter);

    if (nb_delimiters == 0) {
        if (content.len == 0) {
            return SpliterException.empty_content;
        }
        if (!printables.contains_printables(content)) {
            return SpliterException.no_correct_content;
        }
        var splited = try std.ArrayList([]const u8).initCapacity(allocator.gpa_allocator, 1);
        try splited.append(allocator.gpa_allocator, content);
        return splited;
    }
    var splited = try std.ArrayList([]const u8).initCapacity(allocator.gpa_allocator,nb_delimiters + 1);
    var split_it = std.mem.splitScalar(u8, content, delimiter);

    while (split_it.next()) |next| {
        if (next.len == 0) {
            continue;
        }
        try splited.append(allocator.gpa_allocator, next);
    }
    return splited;
}

pub fn split_by_delimiters(content: []const u8, delimiters: []const u8) !std.array_list.Aligned([]const u8, null)
{
    var nb_delimiters: u32 = 0;
    for (delimiters) |c| {
        nb_delimiters += compute_nb_delimiters(content, c);
    }

    if (nb_delimiters == 0) {
        if (content == 0) {
            return SpliterException.empty_content;
        }
        if (!printables.contains_printables(content)) {
            return SpliterException.no_correct_content;
        }
        var splited = try std.ArrayList([]const u8).initCapacity(allocator.gpa_allocator, 1);
        try splited.append(allocator.gpa_allocator, content);
        return splited;
    }
    var splited = try std.ArrayList([]const u8).initCapacity(allocator.gpa_allocator, nb_delimiters);
    var split_it = std.mem.splitAny(u8, content, delimiters);

    while (split_it.next()) |next| {
        if (next.len == 0) {
            continue;
        }
        try splited.append(allocator.gpa_allocator, next);
    }
    return splited;
}

pub fn split_by_ref(content: []const u8, ref: []const u8) !std.array_list.Aligned([]const u8, null)
{
    var nb_refs: u32 = 0;
    var split_it = std.mem.splitSequence(u8, content, ref);

    while (split_it.next()) |_| {
        nb_refs += 1;
    }
    split_it.reset();

    if (nb_refs == 0) {
        if (content.len == 0) {
            return SpliterException.empty_content;
        }
        if (!printables.contains_printables(content)) {
            return SpliterException.no_correct_content;
        }
        var splited = try std.ArrayList([]const u8).initCapacity(allocator.gpa_allocator, 1);
        splited.append(allocator.gpa_allocator, content);
        return splited;
    }
    var splited = try std.ArrayList([]const u8).initCapacity(allocator.gpa_allocator, nb_refs + 1);

    while (split_it.next()) |next| {
        if (next.len == 0) {
            continue;
        }
        splited.append(allocator.gpa_allocator, next);
    }
    return splited;
}

pub fn deinit(splited: *std.array_list.Aligned([]const u8, null)) void
{
    for (splited.items) |elem| {
        allocator.gpa_allocator.free(elem);
    }
    splited.deinit(allocator.gpa_allocator);
}