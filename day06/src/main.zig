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

fn p1(text: Str) !u64 {
    var sum: u64 = 0;
    var line_iter = mem.splitScalar(u8, text, '\n');

    var lines = try ArrayList(Str).initCapacity(gpa, 10);
    defer lines.deinit(gpa);

    while (line_iter.next()) |line| {
        try lines.append(gpa, line);
    }
    const ops = lines.pop() orelse unreachable;
    var ops_iter = mem.tokenizeScalar(u8, ops, ' ');

    var num_iters = try ArrayList(mem.TokenIterator(u8, mem.DelimiterType.scalar)).initCapacity(gpa, 10);
    defer num_iters.deinit(gpa);

    for (lines.items) |l| {
        try num_iters.append(gpa, mem.tokenizeScalar(u8, l, ' '));
    }

    while (ops_iter.next()) |op_str| {
        const is_mul = op_str[0] == '*';

        var acc: u64 = if (is_mul) 1 else 0;
        for (num_iters.items) |*num_iter| {
            const num_str = num_iter.next() orelse unreachable;
            const num = try fmt.parseInt(u64, num_str, 10);
            if (is_mul) {
                acc *= num;
            } else {
                acc += num;
            }
        }
        sum += acc;
    }

    return sum;
}

fn p2(text: Str) !u64 {
    var sum: u64 = 0;
    var line_iter = mem.splitScalar(u8, text, '\n');

    var lines = try ArrayList(Str).initCapacity(gpa, 10);
    defer lines.deinit(gpa);

    while (line_iter.next()) |line| {
        try lines.append(gpa, line);
    }

    const ops = lines.pop() orelse unreachable;

    var num_slices = try ArrayList(Str).initCapacity(gpa, 10);
    defer num_slices.deinit(gpa);

    for (lines.items) |l| {
        try num_slices.append(gpa, l);
    }

    var op_sl = ops;
    while (true) {
        const pos = mem.indexOfNone(u8, op_sl[1..], " ") orelse op_sl.len;
        const is_mul = op_sl[0] == '*';

        var acc: u64 = if (is_mul) 1 else 0;
        for (0..pos) |idx| {
            var num: u64 = 0;
            for (num_slices.items) |num_str| {
                if (num_str[idx] != ' ') {
                    num = num * 10 + try fmt.charToDigit(num_str[idx], 10);
                }
            }
            if (is_mul) {
                acc *= num;
            } else {
                acc += num;
            }
        }
        sum += acc;

        if (op_sl.len == pos) break;
        op_sl = op_sl[pos + 1 ..];
        for (num_slices.items) |*num_slice| {
            num_slice.* = num_slice.*[pos + 1 ..];
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
    try expectEqual(try p1(trimmed), 4277556);
    try expectEqual(try p2(trimmed), 3263827);
}
