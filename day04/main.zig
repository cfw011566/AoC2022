const std = @import("std");

// Tuple or Anonymous struct
const ElfRange = std.meta.Tuple(&.{ usize, usize });

pub fn main() !void {
    try std.testing.expectEqual(part1("example.txt"), 2);
    const answer1 = try part1("input.txt");
    std.debug.print("part1 = {d}\n", .{answer1});
    try std.testing.expectEqual(part2("example.txt"), 4);
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
    var lines = std.mem.tokenizeAny(u8, buffer, "\n");
    while (lines.next()) |line| {
        const sep = std.mem.indexOfScalar(u8, line, ',').?;
        const first_range = line[0..sep];
        const second_range = line[sep + 1 ..];
        // std.debug.print("{s} {s}\n", .{ first_range, second_range });
        const elf1 = try parseRange(first_range);
        const elf2 = try parseRange(second_range);
        // std.debug.print("{any} {any}\n", .{ first, second });
        if (isContained(elf1, elf2)) {
            sum += 1;
        }
    }
    // std.debug.print("sum = {d}\n", .{sum});

    return sum;
}

fn parseRange(range: []const u8) !ElfRange {
    const sep = std.mem.indexOfScalar(u8, range, '-').?;
    const low = try std.fmt.parseInt(usize, range[0..sep], 10);
    const high = try std.fmt.parseInt(usize, range[sep + 1 ..], 10);
    return ElfRange{ low, high };
}

fn isContained(first: ElfRange, second: ElfRange) bool {
    const check1 = first[0] <= second[0] and first[1] >= second[1];
    const check2 = first[0] >= second[0] and first[1] <= second[1];
    return check1 or check2;
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
    var lines = std.mem.tokenizeAny(u8, buffer, "\n");
    while (lines.next()) |line| {
        const sep = std.mem.indexOfScalar(u8, line, ',').?;
        const first_range = line[0..sep];
        const second_range = line[sep + 1 ..];
        // std.debug.print("{s} {s}\n", .{ first_range, second_range });
        const elf1 = try parseRange(first_range);
        const elf2 = try parseRange(second_range);
        // std.debug.print("{any} {any}\n", .{ first, second });
        if (isOverlapped(elf1, elf2)) {
            sum += 1;
        }
    }
    // std.debug.print("sum = {d}\n", .{sum});

    return sum;
}

fn isOverlapped(first: ElfRange, second: ElfRange) bool {
    const check1 = first[1] < second[1] and first[1] < second[0];
    const check2 = second[1] < first[1] and second[1] < first[0];
    return !(check1 or check2);
    //    if (first[0] <= second[0]) {
    //        return first[1] >= second[0];
    //    }
    //    if (second[0] <= first[0]) {
    //        return second[1] >= first[0];
    //    }
    //    return false;
}
