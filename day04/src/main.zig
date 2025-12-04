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

fn getNeighbors(p: Point) [8]Point {
    const x = p[0];
    const y = p[1];

    const neighbors = [8]Point{
        .{ x - 1, y - 1 },
        .{ x, y - 1 },
        .{ x + 1, y - 1 },

        .{ x - 1, y },
        .{ x + 1, y },

        .{ x - 1, y + 1 },
        .{ x, y + 1 },
        .{ x + 1, y + 1 },
    };

    return neighbors;
}

fn parseMap(text: Str) !Map {
    var map = Map.init(gpa);

    var line_iter = mem.splitScalar(u8, text, '\n');

    var y: i32 = 0;
    while (line_iter.next()) |line| : (y += 1) {
        var x: i32 = 0;
        for (line) |c| {
            if (c == '@') {
                try map.put(.{ x, y }, {});
            }
            x += 1;
        }
    }
    return map;
}

fn p1(text: Str) !u32 {
    var map = try parseMap(text);
    defer map.deinit();

    var iter_map = map.keyIterator();

    var all: u32 = 0;

    while (iter_map.next()) |p| {
        const ns = getNeighbors(p.*);

        var cnt: usize = 0;
        for (ns) |n| {
            if (map.contains(n)) {
                cnt += 1;
            }
        }

        if (cnt < 4) {
            all += 1;
        }
    }

    return all;
}

fn p2(text: Str) !u32 {
    var map = try parseMap(text);
    defer map.deinit();

    var total: u32 = 0;

    while (true) {
        var map2 = try map.clone();
        var iter_map = map2.keyIterator();

        var this_map: usize = 0;
        while (iter_map.next()) |p| {
            const ns = getNeighbors(p.*);

            var cnt: usize = 0;
            for (ns) |n| {
                if (map.contains(n)) {
                    cnt += 1;
                }
            }

            if (cnt < 4) {
                _ = map2.remove(p.*);
                this_map += 1;
                total += 1;
            }
        }
        map.deinit();
        map = map2;

        if (this_map == 0) {
            break;
        }
    }

    return total;
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
    try expectEqual(try p1(trimmed), 13);
    try expectEqual(try p2(trimmed), 43);
}
