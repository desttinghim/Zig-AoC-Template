const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day01.txt");

pub fn main() !void {
    var tokenIterator = tokenize(u8, data, " \n");
    var window: [3]i32 = .{ 0, 0, 0 };
    var previousSum: ?i32 = null;
    var increaseCount: usize = 0;
    var windowIndex: usize = 0;
    while (tokenIterator.next()) |token| : (windowIndex += 1) {
        const radix = 10;
        var depth = try std.fmt.parseInt(i32, token, radix);

        const i = windowIndex % 3;
        window[i] = depth;

        // Only sum index if we've seen at least 3 values
        if (windowIndex >= 2) {
            var sum = window[0] + window[1] + window[2];
            print("{} + {} + {} = {}", .{ window[0], window[1], window[2], sum });
            if (previousSum) |lastSum| {
                if (sum > lastSum) {
                    increaseCount += 1;
                    print(" (increase)", .{});
                }
            }
            previousSum = sum;
            print("\n", .{});
        }
    }
    print("Increases: {}, lastSum: {}, windowIndex: {}\n", .{ increaseCount, previousSum, windowIndex });
}

// Useful stdlib functions
const tokenize = std.mem.tokenize;
const split = std.mem.split;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const min = std.math.min;
const min3 = std.math.min3;
const max = std.math.max;
const max3 = std.math.max3;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.sort;
const asc = std.sort.asc;
const desc = std.sort.desc;
