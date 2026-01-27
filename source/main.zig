const std = @import("std");

const allocator = @import("allocator.zig");
const path_manager = @import("path_manager.zig");
const folder_content = @import("folders/subs.zig");
const read_file = @import("files/read.zig");
const spliters = @import("utils/spliters.zig");

const ExecException = error {
    cannot_write_in_file
};

fn exec_first_arg(arg: []const u8) ![]const u8
{
    var results: path_manager.PathResults = .{
        .type = undefined,
        .elem = undefined};
    defer results.close();
    
    path_manager.get_results(arg, &results) catch |err| {
        if (err == path_manager.ResultsException.no_such_file_or_directory) {
            std.debug.print("Cannot access '{s}': No such file or directory\n", .{arg});
        }
        return err;
    };
    if (results.type == path_manager.PathType.FOLDER) {
        try folder_content.get_subs(arg, &results);
    }
    if (results.type == path_manager.PathType.FILE) {
        const content = try read_file.read_from_file(try results.get_file());
        defer allocator.gpa_allocator.free(content);
        var lines = try spliters.split_lines(content);
        defer spliters.deinit(&lines);
    }
    return "TEST\n";
}

fn exec_second_arg(arg: []const u8, report: []const u8) !void
{
    var results: path_manager.PathResults = .{
        .type = undefined,
        .elem = undefined};
    defer results.close();

    path_manager.get_results(arg, &results) catch |err| {
        if (err == path_manager.ResultsException.no_such_file_or_directory) {
            std.debug.print("Cannot access '{s}': No such file or directory\n", .{arg});
        }
        return path_manager.ResultsException.no_such_file_or_directory;
    };
    if (results.type == path_manager.PathType.FILE) {
        std.debug.print("Cannot create 'report.txt' cause the path is a file\n", .{});
        return ExecException.cannot_write_in_file;
    }
    std.debug.print("WriteAll : {s}", .{report});
}

pub fn main() !u8 {
    defer allocator.deinit_allocator();
    const nb_args = std.os.argv.len;

    if (nb_args < 2 or nb_args > 3) {
        std.debug.print("Bad number of args. Excepted at least 1, found {d}\n", .{nb_args - 1});
        return 1;
    }
    if (nb_args == 2) {
        const report = exec_first_arg(std.mem.span(std.os.argv[1])) catch {
            return 1;
        };
        std.debug.print("Coding styles errors founds : {d}\nReport :\n{s}", .{0, report});
        return 0;
    }
    const report = exec_first_arg(std.mem.span(std.os.argv[1])) catch {
        return 1;
    };
    exec_second_arg(std.mem.span(std.os.argv[2]), report) catch {
        return 1;
    };
    std.debug.print("Coding styles errors founds : {d}\nMore informations into folder '{s}'\n",
        .{0, std.os.argv[1]});
    return 0;
}