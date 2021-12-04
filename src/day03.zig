const std = @import("std");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day03.txt");

const bitCount = 12;
const BinNum = [bitCount]u8;
pub fn main() !void {
    var binaryNumbers = ArrayList(BinNum).init(gpa);
    var readings = ArrayList(u12).init(gpa);
    defer binaryNumbers.deinit();

    var tokenIter = tokenize(u8, data, " \r\n ");
    while (tokenIter.next()) |token| {
        var store = try binaryNumbers.addOne();
        std.mem.copy(u8, store, token);
        try readings.append(try parseInt(u12, token, 2));
    }

    var total1Bits = try part1(readings);
    try part2(readings, total1Bits);
}

fn part1(readings: ArrayList(u12)) ![bitCount]u16 {
    var total1Bits = [_]u16{0} ** bitCount;
    for (readings.items) |number| {
        var i: u4 = 0;
        while (i < bitCount) : (i += 1) {
            const bitmask = @as(u12, 1) << i;
            if (number & bitmask == 0) total1Bits[i] += 1;
        }
    }
    var gamma: u32 = 0;
    var epsilon: u32 = 0;
    for (total1Bits) |bits, i| {
        if (bits >= readings.items.len / 2) gamma |= @as(u32, 1) << @intCast(u5, bitCount - i - 1);
        if (bits <= readings.items.len / 2) epsilon |= @as(u32, 1) << @intCast(u5, bitCount - i - 1);
    }
    print("gamma: {}, epsilon: {}, power: {}, bitnum: {any}\n", .{ gamma, epsilon, gamma * epsilon, total1Bits });
    return total1Bits;
}

fn part2(readings: ArrayList(u12), total1Bits: [bitCount]u16) !void {
    var a: u4 = 0;
    var list = ArrayList(u12).init(gpa);
    try list.appendSlice(readings.items);
    defer list.deinit();

    while (a < bitCount) : (a += 1) {
        var mostcommon: u1 = if (total1Bits[a] >= readings.items.len / 2) 1 else 0;
        print("{}", .{mostcommon});
        if (mostcommon == 1) {
            keepOnesAtPos(&list, a);
        } else if (mostcommon == 0) {
            keepZeroesAtPos(&list, a);
        }
        if (list.items.len == 1) break;
    }
    var oxygen: u32 = list.items[0];
    print("\noxygen\t\t{b}\n", .{oxygen});

    a = 0;
    try list.resize(0);
    try list.appendSlice(readings.items);
    while (a < bitCount) : (a += 1) {
        print("{}: {}\t", .{ a, list.items.len });
        if (list.items.len == 2) print("{b}, {b}", .{ list.items[0], list.items[1] });
        print("\n", .{});
        // var mostcommon: u1 = if (total1Bits[a] >= readings.items.len / 2) 1 else 0;
        var leastcommon: u1 = if (total1Bits[a] <= readings.items.len / 2) 1 else 0;
        if (leastcommon == 1) {
            keepOnesAtPos(&list, a);
        } else if (leastcommon == 0) {
            keepZeroesAtPos(&list, a);
        }
        if (list.items.len == 1) break;
    }
    var co2: u32 = list.items[0];
    print("co2\t\t\t{b}\n", .{co2});

    var lifesupport = oxygen * co2;
    print("life support: {}", .{lifesupport});
}

fn keepOnesAtPos(list: *ArrayList(u12), pos: u4) void {
    const bitmask = @as(u12, 1) << pos;
    var i = list.items.len;
    while (i > 0) : (i -= 1) {
        if (list.items[i - 1] & bitmask == 0) _ = list.swapRemove(i - 1);
        if (list.items.len == 1) return;
    }
}

fn keepZeroesAtPos(list: *ArrayList(u12), pos: u4) void {
    const bitmask = @as(u12, 1) << pos;
    var i = list.items.len;
    while (i > 0) : (i -= 1) {
        if (list.items[i - 1] & bitmask != 0) _ = list.swapRemove(i - 1);
        if (list.items.len == 1) return;
    }
}

fn isBitOne(num: u12, pos: u4) bool {
    const bitmask = @as(u12, 1) << pos;
    return num & bitmask == 0;
}

test "bit me" {
    assert(isBitOne(0b1000_0000_0000, 0) == true);
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
