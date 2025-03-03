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

pub fn main() !void {
    var readings = try loadReadings(u12, data);
    defer readings.deinit();

    var sums = try sumallbits(u12, readings.items);
    defer sums.deinit();

    var power = part1(readings.items.len, sums.items);
    print("gamma {}, epsilon {}, power {}\n", .{ power.gamma, power.epsilon, power.power });

    try part2(readings.items);
}

const Power = struct { gamma: u32, epsilon: u32, power: u32 };

fn part1(total: usize, sums: []const u32) Power {
    var power = Power{ .gamma = 0, .epsilon = 0, .power = 0 };
    for (sums) |count, i| {
        if (count >= total / 2) power.gamma |= @as(u32, 1) << @intCast(u5, i);
        if (count <= total / 2) power.epsilon |= @as(u32, 1) << @intCast(u5, i);
    }
    power.power = power.gamma * power.epsilon;
    return power;
}

fn part2(readings: []u12) !void {
    var oxylist = ArrayList(u12).init(gpa);
    try oxylist.appendSlice(readings);
    defer oxylist.deinit();
    var removeList = ArrayList(u16).init(gpa);
    defer removeList.deinit();
    var biterator: u5 = std.meta.bitCount(u12);
    filter: while (biterator > 0) : (biterator -= 1) {
        const bit = biterator - 1;
        const sum = sumbit(u12, oxylist.items, bit);

        const common: u1 = if (sum >= oxylist.items.len - sum) 1 else 0;
        for (oxylist.items) |item, i| {
            if ((isBitOne(item, bit) and common == 0) or (!isBitOne(item, bit) and common == 1)) try removeList.append(@intCast(u16, i));
        }
        // Since indexes were added in order, reverse so we go backwards
        std.mem.reverse(u16, removeList.items);
        for (removeList.items) |remove| {
            _ = oxylist.orderedRemove(remove);
            if (oxylist.items.len == 1) break :filter;
        }
        try removeList.resize(0);
    }
    const oxygen = oxylist.items[0];

    var co2list = ArrayList(u12).init(gpa);
    try co2list.appendSlice(readings);
    defer co2list.deinit();
    try removeList.resize(0);
    biterator = std.meta.bitCount(u12);
    filter: while (biterator > 0) : (biterator -= 1) {
        const bit = biterator - 1;
        const sum = sumbit(u12, co2list.items, bit);

        const uncommon: u1 = if (sum >= co2list.items.len - sum) 0 else 1;
        for (co2list.items) |item, i| {
            if ((isBitOne(item, bit) and uncommon == 0) or (!isBitOne(item, bit) and uncommon == 1)) try removeList.append(@intCast(u16, i));
        }
        // Since indexes were added in order, reverse so we go backwards
        std.mem.reverse(u16, removeList.items);
        for (removeList.items) |remove| {
            _ = co2list.orderedRemove(remove);
            if (co2list.items.len == 1) break :filter;
        }
        try removeList.resize(0);
    }
    const co2 = co2list.items[0];
    const lifesupport = @intCast(u32, oxygen) * @intCast(u32, co2);
    print("oxygen {}, co2 {}, life support {}\n", .{ oxygen, co2, lifesupport });
}

fn isBitOne(num: u32, pos: u5) bool {
    const bitmask = @as(u32, 1) << pos;
    return num & bitmask != 0;
}

test "bit me" {
    assert(isBitOne(0b1000_0000_0001, 0) == true);
    assert(isBitOne(0b1000_0000_0001, 1) == false);
}

fn loadReadings(T: anytype, buf: []const u8) !ArrayList(T) {
    var list = ArrayList(T).init(gpa);
    var tokenIter = tokenize(u8, buf, " \r\n ");
    while (tokenIter.next()) |token| {
        try list.append(try parseInt(T, token, 2));
    }
    return list;
}

test "loadReadings" {
    var readings = try loadReadings(u7, @embedFile("../data/day03-example.txt"));
    defer readings.deinit();

    assert(readings.items[0] == 0b00100);
}

fn sumbit(T: anytype, items: []const T, bit: u5) u32 {
    var sum: u32 = 0;
    for (items) |number| {
        if (isBitOne(@intCast(u32, number), bit)) sum += 1;
    }
    return sum;
}

fn sumallbits(T: anytype, items: []const T) !ArrayList(u32) {
    const bitCount = std.meta.bitCount(T);
    var sums = try ArrayList(u32).initCapacity(gpa, bitCount);
    try sums.resize(bitCount);
    std.mem.set(u32, sums.items, 0);

    for (items) |number| {
        var i: u5 = 0;
        while (i < bitCount) : (i += 1) {
            if (isBitOne(@intCast(u32, number), i)) sums.items[i] += 1;
        }
    }
    return sums;
}

test "sums" {
    var readings = try loadReadings(u5, @embedFile("../data/day03-example.txt"));
    defer readings.deinit();

    var sums = try sumallbits(u5, readings.items);
    defer sums.deinit();
    assert(sums.items[0] == 5);
    assert(sums.items[1] == 7);
    assert(sums.items[2] == 8);
    assert(sums.items[3] == 5);
    assert(sums.items[4] == 7);

    var sum = sumbit(u5, readings.items, 0);
    assert(sum == 5);
}

test "part1" {
    var readings = try loadReadings(u5, @embedFile("../data/day03-example.txt"));
    defer readings.deinit();

    var sums = try sumallbits(u5, readings.items);
    defer sums.deinit();

    var power = part1(readings.items.len, sums.items);
    assert(power.gamma == 22);
    assert(power.epsilon == 9);
    assert(power.power == 198);
}

fn keepOnesAtPos(list: *ArrayList(u12), pos: u4) void {
    var i = list.items.len;
    while (i > 0) : (i -= 1) {
        if (!isBitOne(list.items[i - 1], pos)) _ = list.swapRemove(i - 1);
        if (list.items.len == 1) return;
    }
}

fn keepZeroesAtPos(list: *ArrayList(u12), pos: u4) void {
    var i = list.items.len;
    while (i > 0) : (i -= 1) {
        if (isBitOne(list.items[i - 1], pos)) _ = list.swapRemove(i - 1);
        if (list.items.len == 1) return;
    }
}

test "oxygen" {
    var readings = try loadReadings(u5, @embedFile("../data/day03-example.txt"));
    defer readings.deinit();

    var removeList = ArrayList(u5).init(gpa);
    defer removeList.deinit();

    var bitpath = ArrayList(u1).init(gpa);
    defer bitpath.deinit();
    var biterator: u5 = std.meta.bitCount(u5);
    filter: while (biterator > 0) : (biterator -= 1) {
        const bit = biterator - 1;
        const sum = sumbit(u5, readings.items, bit);
        // print("sum0 {} sum1 {}\n", .{ readings.items.len - sum, sum });
        const common: u1 = if (sum >= readings.items.len - sum) 1 else 0;
        try bitpath.append(common);
        for (readings.items) |item, i| {
            if ((isBitOne(item, bit) and common == 0) or (!isBitOne(item, bit) and common == 1)) try removeList.append(@intCast(u5, i));
        }
        // Since indexes were added in order, reverse so we go backwards
        std.mem.reverse(u5, removeList.items);
        for (removeList.items) |remove| {
            _ = readings.orderedRemove(remove);
            if (readings.items.len == 1) break :filter;
        }
        try removeList.resize(0);
    }
    print("path {any}, {any}, 0b{b}", .{ bitpath.items, readings.items, readings.items[0] });
    assert(readings.items.len == 1 and readings.items[0] == 23);
}

test "co2" {
    var readings = try loadReadings(u5, @embedFile("../data/day03-example.txt"));
    defer readings.deinit();

    var removeList = ArrayList(u5).init(gpa);
    defer removeList.deinit();

    var bitpath = ArrayList(u1).init(gpa);
    defer bitpath.deinit();
    var biterator: u5 = std.meta.bitCount(u5);
    filter: while (biterator > 0) : (biterator -= 1) {
        const bit = biterator - 1;
        const sum = sumbit(u5, readings.items, bit);
        // print("sum0 {} sum1 {}\n", .{ readings.items.len - sum, sum });
        const uncommon: u1 = if (sum >= readings.items.len - sum) 0 else 1;
        try bitpath.append(uncommon);
        for (readings.items) |item, i| {
            if ((isBitOne(item, bit) and uncommon == 0) or (!isBitOne(item, bit) and uncommon == 1)) try removeList.append(@intCast(u5, i));
        }
        // Since indexes were added in order, reverse so we go backwards
        std.mem.reverse(u5, removeList.items);
        for (removeList.items) |remove| {
            _ = readings.orderedRemove(remove);
            if (readings.items.len == 1) break :filter;
        }
        try removeList.resize(0);
    }
    print("path {any}, {any}, 0b{b}", .{ bitpath.items, readings.items, readings.items[0] });
    assert(readings.items.len == 1 and readings.items[0] == 10);
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
