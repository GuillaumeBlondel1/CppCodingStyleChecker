const std = @import("std");

pub const ResultsException = error {
    no_such_file_or_directory
};

pub const PathType = enum {
    FOLDER,
    FILE
};

pub const PathResults = struct {
    type: PathType,
};

pub fn get_results(path: []const u8, result_to_fill: *PathResults) ResultsException!void
{
    const dir_raw_result = std.fs.cwd().openDir(path, .{});
    if (dir_raw_result) |res| {
        var dir: std.fs.Dir = res;
        defer dir.close();
        result_to_fill.type = PathType.FOLDER;
        return;
    } else |_| {}
    const file_raw_result = std.fs.cwd().openFile(path, .{});
    if (file_raw_result) |res| {
        var file: std.fs.File = res;
        defer file.close();
        result_to_fill.type = PathType.FILE;
        return;
    } else |_| {}
    return ResultsException.no_such_file_or_directory;
}