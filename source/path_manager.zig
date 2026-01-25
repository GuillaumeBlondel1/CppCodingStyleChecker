const std = @import("std");

// ---- //

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// ---- //

pub const ResultsException = error {
    no_such_file_or_directory,
    bad_allocation,
    no_type
};

pub const PathType = enum {
    FOLDER,
    FILE
};

pub const PathResults = struct {
    type: PathType,
    elem: *void,

    pub fn set_dir(self: *PathResults, dir: *const std.fs.Dir) !void
    {
        const cpy_dir = try allocator.create(std.fs.Dir);

        std.mem.copyForwards(u8,std.mem.asBytes(cpy_dir),std.mem.asBytes(dir));
        self.elem = @ptrCast(cpy_dir);
    }

    pub fn set_file(self: *PathResults, file: *const std.fs.File) !void
    {
        const cpy_file = try allocator.create(std.fs.File);

        std.mem.copyForwards(u8,std.mem.asBytes(cpy_file),std.mem.asBytes(file));
        self.elem = @ptrCast(cpy_file);
    }

    pub fn get_dir(self: *const PathResults) !*std.fs.Dir
    {
        if (self.type != PathType.FOLDER) {
            return ResultsException.no_type;
        }
        const res: *std.fs.Dir = @ptrCast(@alignCast(self.elem));
        return res;
    }

    pub fn get_file(self: *const PathResults) !*std.fs.File
    {
        if (self.type != PathType.FILE) {
            return ResultsException.no_type;
        }
        const res: *std.fs.File = @ptrCast(@alignCast(self.elem));
        return res;
    }

    pub fn close(self: *PathResults) void
    {
        if (self.type == PathType.FOLDER) {
            var dir = self.get_dir() catch {
                return;
            };
            dir.close();
            allocator.destroy(dir);
        }
        if (self.type == PathType.FILE) {
            var file = self.get_file() catch {
                return;
            };
            file.close();
            allocator.destroy(file);
        }
    }
};

pub fn get_results(path: []const u8, result_to_fill: *PathResults) ResultsException!void
{
    const dir_raw_result = std.fs.cwd().openDir(path, .{.iterate = true});
    if (dir_raw_result) |res| {
        var dir: std.fs.Dir = res;
        result_to_fill.type = PathType.FOLDER;
        result_to_fill.set_dir(&dir) catch {
            return ResultsException.bad_allocation;
        };
        return;
    } else |_| {}
    const file_raw_result = std.fs.cwd().openFile(path, .{});
    if (file_raw_result) |res| {
        var file: std.fs.File = res;
        result_to_fill.type = PathType.FILE;
        result_to_fill.set_file(&file) catch {
            return ResultsException.bad_allocation;
        };
        return;
    } else |_| {}
    return ResultsException.no_such_file_or_directory;
}