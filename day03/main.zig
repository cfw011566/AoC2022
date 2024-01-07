const std = @import("std");

pub fn main() !void {
    try std.testing.expectEqual(part1("example.txt"), 157);
    const answer1 = try part1("input.txt");
    std.debug.print("part1 = {d}\n", .{answer1});
    try std.testing.expectEqual(part2("example.txt"), 70);
    const answer2 = try part2("input.txt");
    std.debug.print("part2 = {d}\n", .{answer2});
}

fn part1(filename: []const u8) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    const stat = try file.stat();
    const file_size = stat.size;
    // std.debug.print("size = {d}\n", .{file_size});

    const buffer = try file.readToEndAlloc(allocator, file_size);
    defer allocator.free(buffer);

    var sum: usize = 0;
    var iterator = std.mem.tokenizeAny(u8, buffer, "\n");
    while (iterator.next()) |line| {
        const common_part = try commondPart(line, allocator);
        // std.debug.print("command part = {c}\n", .{common_part});
        sum += priority(common_part);
    }
    // std.debug.print("sum = {d}\n", .{sum});

    return sum;
}

fn part2(filename: []const u8) !usize {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    const stat = try file.stat();
    const file_size = stat.size;
    // std.debug.print("size = {d}\n", .{file_size});

    const buffer = try file.readToEndAlloc(allocator, file_size);
    defer allocator.free(buffer);

    var sum: usize = 0;
    var iterator = std.mem.tokenizeAny(u8, buffer, "\n");
    var lines: [3][]const u8 = undefined;
    var i: usize = 0;
    while (iterator.next()) |line| {
        lines[i] = line;
        i += 1;
        if (i == 3) {
            const common_part = try commondPart2(lines, allocator);
            // std.debug.print("command part = {c}\n", .{common_part});
            sum += priority(common_part);
            i = 0;
        }
    }
    // std.debug.print("sum = {d}\n", .{sum});

    return sum;
}

fn priority(ch: u8) usize {
    return switch (ch) {
        'a'...'z' => ch - 'a' + 1,
        'A'...'Z' => ch - 'A' + 27,
        else => 0,
    };
}

fn commondPart(items: []const u8, allocator: std.mem.Allocator) !u8 {
    const len = items.len;
    const first_component = items[0 .. len / 2];
    const second_component = items[len / 2 ..];
    // std.debug.print("first = {s}\n", .{first_component});
    // std.debug.print("second = {s}\n", .{second_component});
    var map = std.AutoHashMap(u8, void).init(allocator);
    for (first_component) |c| {
        try map.put(c, {});
    }
    for (second_component) |c| {
        if (map.contains(c)) {
            return c;
        }
    }
    return undefined;
}

fn commondPart2(lines: [3][]const u8, allocator: std.mem.Allocator) !u8 {
    var map = std.AutoHashMap(u8, usize).init(allocator);
    defer map.deinit();
    for (lines[0]) |c| {
        try map.put(c, 0);
    }
    for (lines[1]) |c| {
        if (map.contains(c)) {
            try map.put(c, 1);
        }
    }
    for (lines[2]) |c| {
        if (map.getEntry(c)) |entry| {
            if (entry.value_ptr.* == 1) {
                entry.value_ptr.* = 2;
                return entry.key_ptr.*;
            }
        }
    }
    //    var iterator = map.iterator();
    //    while (iterator.next()) |entry| {
    //        std.debug.print("{c} {d}\n", .{ entry.key_ptr.*, entry.value_ptr.* });
    //    }
    //    std.debug.print("\n", .{});
    return undefined;
}
