const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

pub fn main() !void {
    const part1 = try solve(input);
    std.debug.print("part1 = {d}\n", .{part1});
}

test "exmaple" {
    const answer = try solve(example);
    try std.testing.expectEqual(answer, 21);
}

fn getInput(content: []const u8) !([][]usize) {
    var lines = std.ArrayList([]usize).init(allocator);
    defer lines.deinit();

    var iterator = std.mem.tokenizeSequence(u8, content, "\n");
    while (iterator.next()) |line| {
        // try lines.append(line);
        var l = std.ArrayList(usize).init(allocator);
        defer l.deinit();
        for (0..line.len) |i| {
            const v: usize = line[i] - '0';
            try l.append(v);
        }
        const ll = try l.toOwnedSlice();
        try lines.append(ll);
    }
    const puzzle = try lines.toOwnedSlice();
    return puzzle;
}

fn solve(data: []const u8) !usize {
    var puzzle = try getInput(data);
    defer allocator.free(puzzle);

    const rows = puzzle.len;
    const cols = puzzle[0].len;
    // first column and last column
    for (0..rows) |r| {
        puzzle[r][0] += 10;
        puzzle[r][cols - 1] += 10;
    }
    // first row and last row
    for (0..cols) |c| {
        puzzle[0][c] += 10;
        puzzle[rows - 1][c] += 10;
    }
    // from left to right
    for (1..rows - 1) |r| {
        var highest = puzzle[r][0] % 10;
        for (1..cols - 1) |c| {
            const h = puzzle[r][c] % 10;
            if (h > highest) {
                highest = h;
                puzzle[r][c] += 10;
            }
        }
    }
    // from right to left
    for (1..rows - 1) |r| {
        var highest = puzzle[r][cols - 1] % 10;
        var c = cols - 2;
        while (c > 0) : (c -= 1) {
            const h = puzzle[r][c] % 10;
            if (h > highest) {
                highest = h;
                puzzle[r][c] += 10;
            }
        }
    }
    // from top to bottom
    for (1..cols - 1) |c| {
        var highest = puzzle[0][c] % 10;
        for (1..rows - 1) |r| {
            const h = puzzle[r][c] % 10;
            if (h > highest) {
                highest = h;
                puzzle[r][c] += 10;
            }
        }
    }
    // from bottom to top
    for (1..cols - 1) |c| {
        var highest = puzzle[rows - 1][c] % 10;
        var r = rows - 2;
        while (r > 0) : (r -= 1) {
            const h = puzzle[r][c] % 10;
            if (h > highest) {
                highest = h;
                puzzle[r][c] += 10;
            }
        }
    }

    printPuzzle(puzzle);
    var sum: usize = 0;
    for (0..rows) |r| {
        for (0..cols) |c| {
            if (puzzle[r][c] >= 10) {
                sum += 1;
            }
        }
    }

    return sum;
}

fn printPuzzle(puzzle: [][]usize) void {
    const rows = puzzle.len;
    const cols = puzzle[0].len;
    for (0..rows) |r| {
        for (0..cols) |c| {
            if (puzzle[r][c] >= 10) {
                std.debug.print(".", .{});
            } else {
                std.debug.print("{d}", .{puzzle[r][c]});
            }
        }
        std.debug.print("\n", .{});
    }
}
