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

const Point = [2]i32;
const Map = AutoHashMap(Point, void);

fn parseMap(text: Str) !struct { Map, Point, i32 } {
    var map = Map.init(gpa);
    var start: Point = undefined;

    var line_iter = mem.splitScalar(u8, text, '\n');

    var y: i32 = 0;
    while (line_iter.next()) |line| : (y += 1) {
        var x: i32 = 0;
        for (line) |c| {
            if (c == '^') {
                try map.put(.{ x, y }, {});
            } else if (c == 'S') {
                start = .{ x, y };
            }
            x += 1;
        }
    }
    return .{ map, start, y };
}

fn p1(text: Str) !usize {
    var map, const start, const end_y = try parseMap(text);
    defer map.deinit();

    var biimus = AutoHashMap(Point, void).init(gpa);
    defer biimus.deinit();

    try biimus.put(start, {});

    var hit = AutoHashMap(Point, void).init(gpa);
    defer hit.deinit();

    while (true) {
        var biimus_next = try biimus.clone();
        var change = false;

        var iter = biimus.keyIterator();
        while (iter.next()) |biimu| {
            const next = Point{ biimu[0], biimu[1] + 1 };

            if (next[1] > end_y) continue;

            if (map.contains(next)) {
                try hit.put(next, {});
                const a = Point{ next[0] - 1, next[1] };
                const b = Point{ next[0] + 1, next[1] };
                if (!biimus_next.contains(a)) {
                    try biimus_next.put(a, {});
                    change = true;
                }
                if (!biimus_next.contains(b)) {
                    try biimus_next.put(b, {});
                    change = true;
                }
            } else {
                if (!biimus_next.contains(next)) {
                    try biimus_next.put(next, {});
                    change = true;
                }
            }
        }

        biimus.deinit();
        biimus = biimus_next;

        if (!change) break;
    }

    return hit.count();
}

fn recurse(map: *const Map, cache: *AutoHashMap(Point, usize), biimu: Point, end_y: i32) !usize {
    if (cache.get(biimu)) |v| {
        return v;
    }

    var next = biimu;
    while (true) : (next[1] += 1) {
        if (next[1] > end_y) {
            try cache.put(biimu, 1);
            return 1;
        } else if (map.contains(next)) {
            const a = Point{ next[0] - 1, next[1] };
            const b = Point{ next[0] + 1, next[1] };

            const sum = try recurse(map, cache, a, end_y) + try recurse(map, cache, b, end_y);
            try cache.put(biimu, sum);

            return sum;
        }
    }

    unreachable;
}

fn p2(text: Str) !usize {
    var map, const start, const end_y = try parseMap(text);
    defer map.deinit();

    var cache = AutoHashMap(Point, usize).init(gpa);
    defer cache.deinit();

    return try recurse(&map, &cache, start, end_y);
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
    try expectEqual(try p1(trimmed), 21);
    try expectEqual(try p2(trimmed), 40);
}
