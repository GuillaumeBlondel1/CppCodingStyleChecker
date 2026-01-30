const std = @import("std");

const simple_header_ext: []const u8 = ".h";
const cpp_header_ext: []const u8 = ".hpp";
const cpp_file_ext: []const u8 = ".cpp";

pub fn check_ext(path: []const u8) bool
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