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
    var line_iter = mem.tokenizeScalar(u8, text, '\n');

    var sum: u32 = 0;

    while (line_iter.next()) |line| {
        const lmax = mem.indexOfMax(u8, line[0..(line.len - 1)]);
        const rmax = mem.indexOfMax(u8, line[lmax + 1 ..]);
        const l = try fmt.charToDigit(line[lmax], 10);
        const r = try fmt.charToDigit(line[lmax + 1 + rmax], 10);
        sum += l * 10 + r;
    }
    return sum;
}

fn p2(text: Str) !u64 {
    var line_iter = mem.tokenizeScalar(u8, text, '\n');

    var sum: u64 = 0;

    while (line_iter.next()) |line| {
        var digits: u64 = 12;

        var rem = line;

        while (digits > 0) : (digits -= 1) {
            const subslice = rem[0..(rem.len + 1 - digits)];
            const max_idx = mem.indexOfMax(u8, subslice);
            const max = try fmt.charToDigit(rem[max_idx], 10);
            sum += try math.powi(u64, 10, digits - 1) * max;
            rem = rem[max_idx + 1 ..];
        }
    }
    return sum;
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
    try expectEqual(try p1(trimmed), 357);
    try expectEqual(try p2(trimmed), 3121910778619);
}
