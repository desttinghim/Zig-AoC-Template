const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day03.txt");

const bitCount = 12;
pub fn main() !void {
    var binaryNumbers = ArrayList([bitCount]u1).init();
    var total1Bits = try part1();
    try part2(total1Bits);
}

fn part1() ![bitCount]u16 {
    var tokenIter = tokenize(u8, data, " \r\n ");
    var total: u16 = 0;
    var total1Bits = [_]u16{0} ** bitCount;
    while (tokenIter.next()) |token| : (total += 1) {
        for (token) |bit, i| {
            if (bit == '1') total1Bits[i] += 1;
        }
    }
    var gamma: u32 = 0;
    var epsilon: u32 = 0;
    for (total1Bits) |bits, i| {
        if (bits >= total / 2) gamma |= @as(u32, 1) << @intCast(u5, bitCount - i - 1);
        if (bits <= total / 2) epsilon |= @as(u32, 1) << @intCast(u5, bitCount - i - 1);
    }
    print("gamma: {}, epsilon: {}, power: {}, total: {}, bitAvg: {any}\n", .{ gamma, epsilon, gamma * epsilon, total, total1Bits });
    return total1Bits;
}

fn part2(total1Bits: [bitCount]u16) !void {
    print("total1Bits: {any}", .{total1Bits});
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
