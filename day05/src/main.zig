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

const Range = [2]i64;

fn rangeFromStr(txt: Str) !Range {
    var num_iter = mem.splitScalar(u8, txt, '-');
    const a = try std.fmt.parseInt(i64, num_iter.next().?, 10);
    const b = try std.fmt.parseInt(i64, num_iter.next().?, 10);
    return Range{ a, b };
}

fn inRange(r: Range, p: i64) bool {
    return (p >= r[0] and p <= r[1]);
}

fn rangeOverlap(a: Range, b: Range) bool {
    return inRange(a, b[0]) or inRange(a, b[1]) or inRange(b, a[0]) or inRange(b, a[1]);
}

fn rangeMerge(a: Range, b: Range) Range {
    return Range{ @min(a[0], b[0]), @max(a[1], b[1]) };
}

fn p1(text: Str) !u32 {
    var parts_iter = mem.splitSequence(u8, text, "\n\n");

    var ranges = try ArrayList(Range).initCapacity(gpa, 10);
    defer ranges.deinit(gpa);

    var cnt: u32 = 0;

    const ranges_str = parts_iter.next() orelse unreachable;
    const ids_str = parts_iter.next() orelse unreachable;

    var ranges_iter = mem.splitScalar(u8, ranges_str, '\n');

    while (ranges_iter.next()) |range_str| {
        const r = try rangeFromStr(range_str);
        try ranges.append(gpa, r);
    }

    var ids_iter = mem.splitScalar(u8, ids_str, '\n');
    outer: while (ids_iter.next()) |id_str| {
        const id = try fmt.parseInt(i64, id_str, 10);

        for (ranges.items) |range| {
            if (inRange(range, id)) {
                cnt += 1;
                continue :outer;
            }
        }
    }

    return cnt;
}

fn p2(text: Str) !i64 {
    var parts_iter = mem.splitSequence(u8, text, "\n\n");

    var ranges = try ArrayList(Range).initCapacity(gpa, 10);
    defer ranges.deinit(gpa);

    var cnt: i64 = 0;

    const ranges_str = parts_iter.next() orelse unreachable;

    var ranges_iter = mem.splitScalar(u8, ranges_str, '\n');

    while (ranges_iter.next()) |range_str| {
        const r = try rangeFromStr(range_str);
        try ranges.append(gpa, r);
    }

    outer: while (true) {
        for (ranges.items, 0..) |a, i_a| {
            for (ranges.items[i_a + 1 ..], 0..) |b, i_b| {
                if (rangeOverlap(a, b)) {
                    const merged = rangeMerge(a, b);
                    // index juggling
                    _ = ranges.orderedRemove(i_a);
                    _ = ranges.swapRemove(i_a + i_b);
                    try ranges.append(gpa, merged);
                    continue :outer;
                }
            }
        }
        break;
    }

    for (ranges.items) |range| {
        cnt += range[1] - range[0] + 1;
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
    try expectEqual(try p2(trimmed), 14);
}
