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

    var sums = try sumbits(u12, readings);
    defer sums.deinit();

    try part1(readings.items.len, sums.items);
    // try part2(readings, sums.items);
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

fn part2(readings: ArrayList(u12), total1Bits: [12]u16) !void {
    var a: u4 = 0;
    var list = ArrayList(u12).init(gpa);
    try list.appendSlice(readings.items);
    defer list.deinit();

    while (a < 12) : (a += 1) {
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
    while (a < 12) : (a += 1) {
        var leastcommon: u1 = if (total1Bits[a] <= readings.items.len / 2) 1 else 0;
        print("{}", .{leastcommon});
        if (leastcommon == 1) {
            keepOnesAtPos(&list, a);
        } else if (leastcommon == 0) {
            keepZeroesAtPos(&list, a);
        }
        if (list.items.len == 1) break;
    }
    var co2: u32 = list.items[0];
    print("\nco2\t\t{b}\n", .{co2});

    var lifesupport = oxygen * co2;
    print("life support: {}\n", .{lifesupport});
}

fn isBitOne(num: u32, pos: u5) bool {
    const bitmask = @as(u32, 1) << pos;
    return num & bitmask != 0;
}

test "bit me" {
    assert(isBitOne(0b1000_0000_0001, 0) == true);
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
    print("\n", .{});
    for (readings.items) |number| {
        print("{b}\n", .{number});
    }
}

fn sumbits(T: anytype, items: []const T) !ArrayList(u32) {
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

    var sums = try sumbits(u5, readings.items);
    defer sums.deinit();
    print("{any}\n", .{sums.items});
    assert(sums.items[0] == 5);
    assert(sums.items[1] == 7);
    assert(sums.items[2] == 8);
    assert(sums.items[3] == 5);
    assert(sums.items[4] == 7);
}

test "part1" {
    var readings = try loadReadings(u5, @embedFile("../data/day03-example.txt"));
    defer readings.deinit();

    var sums = try sumbits(u5, readings.items);
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

test "filter" {
    var readings = try loadReadings(u5, @embedFile("../data/day03-example.txt"));
    defer readings.deinit();

    var sums = try sumbits(u5, readings.items);
    defer sums.deinit();

    assert(sums.items[4] == 7);

    var a: u5 = 4;
    {
        // Test running first iteration
        var i = readings.items.len;
        while (i > 0) {
            if (!isBitOne(readings.items[i - 1], a)) _ = readings.swapRemove(i - 1);
            // if (readings.items.len == 1) break;
            i = std.math.sub(usize, i, 1) catch break;
        }
        a -= 1;
    }
    assert(readings.items.len == 7);

    while (a >= 0) {
        // oxygen
        var i = readings.items.len;
        var mostcommon: u1 = if (sums.items[a] >= readings.items.len / 2) 1 else 0;
        print("\n", .{});
        while (i > 0) {
            print("{b} {}\n", .{ readings.items[i - 1], readings.items[i - 1] });
            if (mostcommon == 1) {
                if (!isBitOne(readings.items[i - 1], a)) _ = readings.swapRemove(i - 1);
            } else {
                if (isBitOne(readings.items[i - 1], a)) _ = readings.swapRemove(i - 1);
            }
            if (readings.items.len == 1) break;
            i = std.math.sub(usize, i, 1) catch break;
        }
        if (readings.items.len == 1) break;
        a = std.math.sub(u5, a, 1) catch break;
        print("\n", .{});
    }
    print("{any}, {b}\n", .{ readings.items, readings.items[0] });
    assert(readings.items.len == 1 and readings.items[0] == 22);
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
