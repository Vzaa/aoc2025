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

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gpa_impl.allocator();

fn digitsLen(nn: usize) usize {
    var cnt: usize = 0;
    var n = nn;

    while (n > 0) : (cnt += 1) {
        n /= 10;
    }

    return cnt;
}

fn p1(text: Str) !usize {
    var range_iter = mem.tokenizeScalar(u8, text, ',');
    var sum: usize = 0;

    while (range_iter.next()) |range_str| {
        var nums_iter = mem.tokenizeScalar(u8, range_str, '-');
        const a_str = nums_iter.next() orelse unreachable;
        const b_str = nums_iter.next() orelse unreachable;

        const a = try fmt.parseInt(usize, a_str, 10);
        const b = try fmt.parseInt(usize, b_str, 10);

        for (a..(b + 1)) |v| {
            const len = digitsLen(v);
            if (len % 2 != 0) continue;
            const pow = try math.powi(usize, 10, len / 2);

            const right = v % pow;
            const left = v / pow;

            if (left == right) sum += v;
        }
    }
    return sum;
}

fn p2(text: Str) !usize {
    var range_iter = mem.tokenizeScalar(u8, text, ',');
    var sum: usize = 0;

    while (range_iter.next()) |range_str| {
        var nums_iter = mem.tokenizeScalar(u8, range_str, '-');
        const a_str = nums_iter.next() orelse unreachable;
        const b_str = nums_iter.next() orelse unreachable;

        const a = try fmt.parseInt(usize, a_str, 10);
        const b = try fmt.parseInt(usize, b_str, 10);

        outer: for (a..(b + 1)) |v| {
            const len = digitsLen(v);

            inner: for (1..((len / 2) + 1)) |dlen| {
                if (len % dlen != 0) continue;

                const pow = try math.powi(usize, 10, dlen);

                var vv = v;
                const sub = vv % pow;

                while (vv > 0) {
                    if ((vv % pow) != sub) continue :inner;
                    vv /= pow;
                }

                sum += v;
                continue :outer;
            }
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
    try expectEqual(try p1(trimmed), 1227775554);
    try expectEqual(try p2(trimmed), 4174379265);
}
