const std = @import("std");

pub fn main() !void {
    const filename = "input.txt";
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    const stat = try file.stat();
    const file_size = stat.size;
    std.debug.print("size = {d}\n", .{file_size});

    const buffer = try file.readToEndAlloc(allocator, file_size);
    defer allocator.free(buffer);

    var elf_array = std.ArrayList(usize).init(allocator);
    defer elf_array.deinit();

    var sum: usize = 0;
    var iterator = std.mem.splitAny(u8, buffer, "\n");
    while (iterator.next()) |line| {
        if (line.len == 0) {
            try elf_array.append(sum);
            sum = 0;
            continue;
        }
        // std.debug.print("{s}\n", .{line});
        const amount = try std.fmt.parseInt(usize, line, 10);
        sum += amount;
    }

    std.debug.print("{any}\n", .{elf_array});
    const elf_slice = try elf_array.toOwnedSlice();
    std.debug.print("slice = {any}\n", .{elf_slice});

    const elf_max = std.mem.max(usize, elf_slice);
    std.debug.print("part1: {d}\n", .{elf_max});

    std.mem.sort(usize, elf_slice, {}, comptime std.sort.desc(usize));
    std.debug.print("sorted: {any}\n", .{elf_slice});

    var top_three: usize = 0;
    top_three += elf_slice[0];
    top_three += elf_slice[1];
    top_three += elf_slice[2];
    std.debug.print("part2: {d}\n", .{top_three});
}
