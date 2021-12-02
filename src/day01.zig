const std = @import("std");

const data = @embedFile("../data/day01.txt");

pub fn main() !void {
    var tokenIterator = std.mem.tokenize(u8, data, " \n");
    var window: [3]i32 = .{ 0, 0, 0 };
    var increaseCount: usize = 0;
    var windowIndex: usize = 0;
    while (tokenIterator.next()) |token| : (windowIndex += 1) {
        const radix = 10;
        var depth = try std.fmt.parseInt(i32, token, radix);

        // The current index is the same as the index we need to compare against
        const i = windowIndex % 3;

        // Only 'sum' index if we've seen at least 3 values
        if (windowIndex >= 3) {
            if (depth > window[i]) increaseCount += 1;
        }
        // Update the window
        window[i] = depth;
    }
    std.debug.print("Increases: {}\n", .{increaseCount});
}
