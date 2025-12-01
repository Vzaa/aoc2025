const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;
const StringHashMap = std.StringHashMap;
const print = std.debug.print;
const assert = std.debug.assert;
const mem = std.mem;
const math = std.math;
const fmt = std.fmt;
const Str = []const u8;

var gpa_impl = std.heap.DebugAllocator(.{}){};
const gpa = gpa_impl.allocator();

fn p1(text: Str) !u32 {
    var line_iter = mem.tokenizeAny(u8, text, "\n");

    var cnt: u32 = 0;
    var pos: i32 = 50;

    while (line_iter.next()) |line| {
        const num = try fmt.parseInt(i32, line[1..], 10);
        if (line[0] == 'L') {
            pos = pos - num;
        } else if (line[0] == 'R') {
            pos = pos + num;
        }
        pos = @mod(pos, 100);
        if (pos == 0) {
            cnt += 1;
        }
    }
    return cnt;
}

fn p2(text: Str) !u32 {
    var line_iter = mem.tokenizeAny(u8, text, "\n");

    var cnt: u32 = 0;
    var pos: i32 = 50;

    while (line_iter.next()) |line| {
        const num = try fmt.parseInt(i32, line[1..], 10);

        cnt += @intCast(@divTrunc(num, 100));
        const disp = @mod(num, 100);

        if (line[0] == 'L') {
            if (pos == 0) {
                cnt -= 1;
            }
            pos = pos - disp;
        } else if (line[0] == 'R') {
            pos = pos + disp;
        }
        if (pos <= 0 or pos >= 100) {
            cnt += 1;
        }
        pos = @mod(pos, 100);
    }
    return cnt;
}

pub fn main() anyerror!void {
    defer _ = gpa_impl.deinit();
    const text = @embedFile("input");
    const trimmed = std.mem.trim(u8, text, "\n");

    print("Part 1: {}\n", .{try p1(trimmed)});
    print("Part 2: {}\n", .{try p2(trimmed)});
}

test "test input" {
    const expectEqual = std.testing.expectEqual;
    const text = @embedFile("test");
    const trimmed = std.mem.trim(u8, text, "\n");
    try expectEqual(try p1(trimmed), 3);
    try expectEqual(try p2(trimmed), 6);
}
