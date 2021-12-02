const std = @import("std");

const data = @embedFile("../data/day01.txt");

pub fn main() !void {
    var tokenIterator = std.mem.tokenize(u8, data, " \n");
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
            std.debug.print("{} + {} + {} = {}", .{ window[0], window[1], window[2], sum });
            if (previousSum) |lastSum| {
                if (sum > lastSum) {
                    increaseCount += 1;
                    std.debug.print(" (increase)", .{});
                }
            }
            previousSum = sum;
            std.debug.print("\n", .{});
        }
    }
    std.debug.print("Increases: {}, lastSum: {}, windowIndex: {}\n", .{ increaseCount, previousSum, windowIndex });
}
