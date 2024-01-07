const std = @import("std");

const input = @embedFile("input.txt");

const DecodeError = error{NoMarker};

pub fn main() !void {
    const part1 = try solve(input, 4);
    std.debug.print("part1 = {d}\n", .{part1});
    const part2 = try solve(input, 14);
    std.debug.print("part2 = {d}\n", .{part2});
}

fn solve(content: []const u8, pre_len: usize) !usize {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();
    var map = std.AutoHashMap(u8, bool).init(allocator);
    defer map.deinit();

    for (pre_len..content.len) |end| {
        const start = end - pre_len;
        for (content[start..end]) |ch| {
            try map.put(ch, true);
        }
        if (map.count() == pre_len) {
            return end;
        }
        map.clearAndFree();
    }
    return DecodeError.NoMarker;
}

test "example1" {
    try std.testing.expectEqual(solve("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 4), 7);
    try std.testing.expectEqual(solve("bvwbjplbgvbhsrlpgdmjqwftvncz", 4), 5);
    try std.testing.expectEqual(solve("nppdvjthqldpwncqszvftbrmjlhg", 4), 6);
    try std.testing.expectEqual(solve("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 4), 10);
    try std.testing.expectEqual(solve("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 4), 11);
}
