const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("../data/day02.txt");

pub fn main() !void {
    var tokenIter = tokenize(u8, data, "\n\r ");
    var x: i64 = 0;
    var y: i64 = 0;
    var aim: i64 = 0;
    const radix = 10;
    var command: ?enum { Forward, Up, Down } = null;
    while (tokenIter.next()) |token| {
        if (command) |cmd| {
            var amount = try parseInt(i32, token, radix);
            switch (cmd) {
                .Forward => {
                    x += amount;
                    y += aim * amount;
                },
                .Up => {
                    // y -= amount;
                    aim -= amount;
                },
                .Down => {
                    // y += amount;
                    aim += amount;
                },
            }
            command = null;
        } else {
            if (std.mem.eql(u8, token, "forward")) command = .Forward;
            if (std.mem.eql(u8, token, "up")) command = .Up;
            if (std.mem.eql(u8, token, "down")) command = .Down;
        }
    }
    print("x: {}, y: {}, aim: {}, x*y={} \n", .{ x, y, aim, x * y });
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
