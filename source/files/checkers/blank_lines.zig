const std = @import("std");

const printables = @import("../../utils/printables.zig");

const LineStatus = enum {
    valid_blank,
    invalid_blank,
    not_blank
};

fn contains_code(line: []const u8) bool
{
    if (printables.contains_printables(line)) {
        return true;
    }
    return false;
}

pub fn analyse_line(line: []const u8) LineStatus
{
    if (contains_code(line)) {
        return LineStatus.not_blank;
    }
    if (line.len > 1) {
        return LineStatus.invalid_blank;
    }
    return LineStatus.valid_blank;
}