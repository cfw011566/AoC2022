const std = @import("std");

const Move = enum(u8) { Rock = 1, Paper = 2, Scissors = 3 };
const Result = enum(u8) { Loss = 0, Draw = 3, Win = 6 };
const EncryptionError = error{UnrecognizedInput};

pub fn main() !void {
    const filename = "input.txt";
    try part1(filename);
    try part2(filename);
}

fn part1(filename: []const u8) !void {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    const stat = try file.stat();
    const file_size = stat.size;
    std.debug.print("size = {d}\n", .{file_size});

    const buffer = try file.readToEndAlloc(allocator, file_size);
    defer allocator.free(buffer);

    var sum: usize = 0;
    var iterator = std.mem.tokenizeAny(u8, buffer, "\n");
    while (iterator.next()) |line| {
        const opponent_move = try decryptMove(line[0]);
        const my_move = try decryptMove(line[2]);
        const hand_result = getHandResult(my_move, opponent_move);
        const score = @intFromEnum(my_move) + @intFromEnum(hand_result);
        // std.debug.print("{any} {any} {any}\n", .{ opponent_move, my_move, score });
        sum += score;
    }
    std.debug.print("part1 total score = {d}\n", .{sum});
}

fn part2(filename: []const u8) !void {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    const stat = try file.stat();
    const file_size = stat.size;
    std.debug.print("size = {d}\n", .{file_size});

    const buffer = try file.readToEndAlloc(allocator, file_size);
    defer allocator.free(buffer);

    var sum: usize = 0;
    var iterator = std.mem.tokenizeAny(u8, buffer, "\n");
    while (iterator.next()) |line| {
        const opponent_move = try decryptMove(line[0]);
        const hand_result = try decryptResult(line[2]);
        const my_move = getMyMove(hand_result, opponent_move);
        const score = @intFromEnum(my_move) + @intFromEnum(hand_result);
        // std.debug.print("{any} {any} {any}\n", .{ opponent_move, my_move, score });
        sum += score;
    }
    std.debug.print("part2 total score = {d}\n", .{sum});
}

fn decryptResult(ch: u8) EncryptionError!Result {
    return switch (ch) {
        'X' => .Loss,
        'Y' => .Draw,
        'Z' => .Win,
        else => EncryptionError.UnrecognizedInput,
    };
}

fn getMyMove(result: Result, opponent: Move) Move {
    return switch (result) {
        .Loss => switch (opponent) {
            .Rock => .Scissors,
            .Paper => .Rock,
            .Scissors => .Paper,
        },
        .Draw => switch (opponent) {
            .Rock => .Rock,
            .Paper => .Paper,
            .Scissors => .Scissors,
        },
        .Win => switch (opponent) {
            .Rock => .Paper,
            .Paper => .Scissors,
            .Scissors => .Rock,
        },
    };
}

fn decryptMove(ch: u8) EncryptionError!Move {
    return switch (ch) {
        'A' => .Rock,
        'B' => .Paper,
        'C' => .Scissors,
        'X' => .Rock,
        'Y' => .Paper,
        'Z' => .Scissors,
        else => EncryptionError.UnrecognizedInput,
    };
}

fn getHandResult(my: Move, opponent: Move) Result {
    return switch (my) {
        .Rock => switch (opponent) {
            .Rock => .Draw,
            .Paper => .Loss,
            .Scissors => .Win,
        },
        .Paper => switch (opponent) {
            .Rock => .Win,
            .Paper => .Draw,
            .Scissors => .Loss,
        },
        .Scissors => switch (opponent) {
            .Rock => .Loss,
            .Paper => .Win,
            .Scissors => .Draw,
        },
    };
}
