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

const Point = [3]i64;
const Circuit = AutoHashMap(Point, void);
const PairD = struct { struct { Point, Point }, i64 };

fn parsePoint(line: Str) !Point {
    var p: Point = undefined;
    var iter = std.mem.splitScalar(u8, line, ',');
    p[0] = try std.fmt.parseInt(i64, iter.next().?, 10);
    p[1] = try std.fmt.parseInt(i64, iter.next().?, 10);
    p[2] = try std.fmt.parseInt(i64, iter.next().?, 10);
    return p;
}

fn dist3(a: Point, b: Point) i64 {
    const x = (a[0] - b[0]) * (a[0] - b[0]);
    const y = (a[1] - b[1]) * (a[1] - b[1]);
    const z = (a[2] - b[2]) * (a[2] - b[2]);

    return x + y + z;
}

fn sortPairD(_: void, a: PairD, b: PairD) bool {
    return a.@"1" < b.@"1";
}

fn sortUsize(_: void, a: usize, b: usize) bool {
    return a > b;
}

fn p1(text: Str, limit: usize) !usize {
    var line_iter = mem.splitScalar(u8, text, '\n');

    var junctions = try ArrayList(Point).initCapacity(gpa, 1000);
    defer junctions.deinit(gpa);

    while (line_iter.next()) |line| {
        try junctions.append(gpa, try parsePoint(line));
    }

    var dists_list = try ArrayList(PairD).initCapacity(gpa, junctions.items.len * junctions.items.len);
    defer dists_list.deinit(gpa);

    var cir_lut = AutoHashMap(Point, usize).init(gpa);
    defer cir_lut.deinit();

    var circuits = try ArrayList(Circuit).initCapacity(gpa, 1000);
    defer circuits.deinit(gpa);
    defer {
        for (circuits.items) |*c| c.deinit();
    }

    for (junctions.items, 0..) |p_a, i| {
        for (junctions.items[i + 1 ..]) |p_b| {
            const d = dist3(p_a, p_b);
            try dists_list.append(gpa, .{ .{ p_a, p_b }, d });
        }
    }

    std.sort.pdq(PairD, dists_list.items, {}, sortPairD);

    for (dists_list.items, 0..) |d, i| {
        if (limit != 0 and i >= limit) break;

        const p_a = d.@"0".@"0";
        const p_b = d.@"0".@"1";

        if (!cir_lut.contains(p_a) and !cir_lut.contains(p_b)) {
            var new_c = Circuit.init(gpa);
            try new_c.put(p_a, {});
            try new_c.put(p_b, {});

            try circuits.append(gpa, new_c);

            try cir_lut.put(p_a, circuits.items.len - 1);
            try cir_lut.put(p_b, circuits.items.len - 1);
        } else if (!cir_lut.contains(p_a)) {
            const cir_b = cir_lut.get(p_b) orelse unreachable;
            try circuits.items[cir_b].put(p_a, {});
            try cir_lut.put(p_a, cir_b);
        } else if (!cir_lut.contains(p_b)) {
            const cir_a = cir_lut.get(p_a) orelse unreachable;
            try circuits.items[cir_a].put(p_b, {});
            try cir_lut.put(p_b, cir_a);
        } else {
            const cir_a = cir_lut.get(p_a) orelse unreachable;
            const cir_b = cir_lut.get(p_b) orelse unreachable;

            if (cir_a == cir_b) {
                continue;
            }

            var iter = circuits.items[cir_b].keyIterator();
            while (iter.next()) |j| {
                try circuits.items[cir_a].put(j.*, {});
                try cir_lut.put(j.*, cir_a);
            }
            circuits.items[cir_b].clearRetainingCapacity();
        }

        const cir_a = cir_lut.get(p_a) orelse unreachable;
        if (circuits.items[cir_a].count() == junctions.items.len) {
            return @intCast(p_a[0] * p_b[0]);
        }
    }

    var sizes = try ArrayList(usize).initCapacity(gpa, 10);
    defer sizes.deinit(gpa);

    for (circuits.items) |c| {
        try sizes.append(gpa, c.count());
    }

    std.sort.pdq(usize, sizes.items, {}, sortUsize);

    return sizes.items[0] * sizes.items[1] * sizes.items[2];
}

pub fn main() anyerror!void {
    defer _ = gpa_impl.deinit();
    const text = @embedFile("input");
    const trimmed = std.mem.trim(u8, text, "\n");

    print("Part 1: {}\n", .{try p1(trimmed, 1000)});
    print("Part 2: {}\n", .{try p1(trimmed, 0)});
}

test "test input" {
    const expectEqual = std.testing.expectEqual;
    const text = @embedFile("test");
    const trimmed = std.mem.trim(u8, text, "\n");
    try expectEqual(try p1(trimmed, 10), 40);
    try expectEqual(try p1(trimmed, 0), 25272);
}
