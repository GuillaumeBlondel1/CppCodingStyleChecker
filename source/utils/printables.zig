const std = @import("std");

pub fn contains_printables(content: []const u8) bool
{
    var state: bool = false;

    for (content) |c| {
        if (c < 32 or c > 126) {
            if (c == '\n') {
                continue;
            }
            break;
        }
        state = true;
    }
    return state;
}