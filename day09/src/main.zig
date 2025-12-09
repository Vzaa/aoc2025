const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.array_list.Managed;
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

const Point = [2]u64;
const Line = [2]Point;

fn area(a: Point, b: Point) u64 {
    const x_min = @min(a[0], b[0]);
    const x_max = @max(a[0], b[0]);
    const y_min = @min(a[1], b[1]);
    const y_max = @max(a[1], b[1]);

    return (x_max - x_min + 1) * (y_max - y_min + 1);
}
const T = enum { R, G };
const Map = AutoHashMap(Point, T);

fn parsePoint(line: Str) !Point {
    var p: Point = undefined;
    var iter = std.mem.splitScalar(u8, line, ',');
    p[0] = try std.fmt.parseInt(u64, iter.next().?, 10);
    p[1] = try std.fmt.parseInt(u64, iter.next().?, 10);
    return p;
}

fn p1(text: Str) !u64 {
    var line_iter = mem.splitScalar(u8, text, '\n');
    var tiles = ArrayList(Point).init(gpa);
    defer tiles.deinit();

    while (line_iter.next()) |line| {
        try tiles.append(try parsePoint(line));
    }

    var max: u64 = 0;
    for (tiles.items, 0..) |p_a, i| {
        for (tiles.items[i + 1 ..]) |p_b| {
            // const a = (p_a[0] - p_b[0] + 1) * (p_a[1] - p_b[1] + 1);
            const a = area(p_a, p_b);
            max = @max(max, a);
        }
    }

    return max;
}

fn isNumBetween(a: u64, b: u64, n: u64) bool {
    return n >= a and n <= b;
}

// dumb af
fn isLineInRect(l: Line, r_a: Point, r_b: Point) bool {
    if (l[0][0] == l[1][0]) {
        const x = l[0][0];
        if (x < r_a[0] or x > r_b[0]) return false;

        const y_min = @min(l[0][1], l[1][1]);
        const y_max = @max(l[0][1], l[1][1]);

        if (isNumBetween(r_a[1], r_b[1], y_min)) return true;
        if (isNumBetween(r_a[1], r_b[1], y_max)) return true;
        if (y_min < r_a[1] and y_max > r_b[1]) return true;
        if (y_min >= r_a[1] and y_max <= r_b[1]) return true;
        return false;
    } else if (l[0][1] == l[1][1]) {
        const y = l[0][1];
        if (y < r_a[1] or y > r_b[1]) return false;

        const x_min = @min(l[0][0], l[1][0]);
        const x_max = @max(l[0][0], l[1][0]);

        if (isNumBetween(r_a[0], r_b[0], x_min)) return true;
        if (isNumBetween(r_a[0], r_b[0], x_max)) return true;
        if (x_min < r_a[0] and x_max > r_b[0]) return true;
        if (x_min >= r_a[0] and x_max <= r_b[0]) return true;
        return false;
    } else {
        unreachable;
    }
}

fn p2(text: Str) !u64 {
    var line_iter = mem.splitScalar(u8, text, '\n');

    var tiles = ArrayList(Point).init(gpa);
    defer tiles.deinit();

    while (line_iter.next()) |line| {
        try tiles.append(try parsePoint(line));
    }

    var lines = ArrayList(Line).init(gpa);
    defer lines.deinit();

    const start = tiles.items[0];

    var pos = start;
    try tiles.append(start);
    for (tiles.items[1..]) |next| {
        try lines.append(.{ pos, next });
        pos = next;
    }

    var max: u64 = 0;
    for (tiles.items, 0..) |p_a, i| {
        outer: for (tiles.items[i + 1 ..]) |p_b| {
            const x_min = @min(p_a[0], p_b[0]) + 1;
            const x_max = @max(p_a[0], p_b[0]) - 1;
            const y_min = @min(p_a[1], p_b[1]) + 1;
            const y_max = @max(p_a[1], p_b[1]) - 1;

            for (lines.items) |l| {
                if (isLineInRect(l, .{ x_min, y_min }, .{ x_max, y_max })) {
                    continue :outer;
                }
            }
            const a = area(p_a, p_b);
            max = @max(max, a);
        }
    }

    return max;
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
    try expectEqual(try p1(trimmed), 50);
    try expectEqual(try p2(trimmed), 24);
}
