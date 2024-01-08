const std = @import("std");

const example = @embedFile("example.txt");
const input = @embedFile("input.txt");

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const Node = struct {
    name: []const u8 = "",
    parent: usize = 0,
    total_size: usize = 0,
    children: std.ArrayList(usize),
};

pub fn main() !void {
    std.debug.print("day07\n", .{});
    const part1 = try solve(input);
    std.debug.print("part1 = {d}\n", .{part1});
}

test "example" {
    const answer = try solve(example);
    try std.testing.expectEqual(answer, 95437);
}

fn buildTree(content: []const u8) !std.ArrayList(Node) {
    var tree = std.ArrayList(Node).init(allocator);
    var iterator = std.mem.tokenizeAny(u8, content, "\n");
    var current_directory: usize = 0;
    while (iterator.next()) |line| {
        if (std.mem.indexOf(u8, line, "$ cd ")) |i| {
            const dir_name = line[i + 5 ..];
            if (std.mem.eql(u8, dir_name, "/")) {
                current_directory = 0;
                const name = "root";
                const children = std.ArrayList(usize).init(allocator);
                const node = Node{ .name = name, .children = children };
                try tree.append(node);
            } else if (std.mem.eql(u8, dir_name, "..")) {
                current_directory = tree.items[current_directory].parent;
            } else {
                for (tree.items, 0..) |node, index| {
                    if (std.mem.eql(u8, node.name, dir_name)) {
                        current_directory = index;
                        break;
                    }
                }
            }
        } else if (std.mem.eql(u8, line, "$ ls")) {} else if (std.mem.indexOf(u8, line, "dir ")) |i| {
            const name = line[i + 4 ..];
            const children = std.ArrayList(usize).init(allocator);
            const node = Node{ .name = name, .parent = current_directory, .children = children };
            try tree.items[current_directory].children.append(tree.items.len);
            try tree.append(node);
        } else {
            var iter = std.mem.tokenizeScalar(u8, line, ' ');
            const size = try std.fmt.parseInt(usize, iter.next().?, 10);
            tree.items[current_directory].total_size += size;
        }
    }
    return tree;
}

fn printTree(tree: std.ArrayList(Node)) void {
    for (tree.items, 0..) |node, i| {
        std.debug.print("{d} {s} {d} {any}\n", .{ i, node.name, node.total_size, node.children.items });
    }
}

fn computeTree(tree: std.ArrayList(Node), index: usize) usize {
    if (tree.items[index].children.items.len == 0) {
        const size = tree.items[index].total_size;
        return size;
    }
    for (tree.items[index].children.items) |i| {
        tree.items[index].total_size += computeTree(tree, i);
    }
    return tree.items[index].total_size;
}

fn solve(content: []const u8) !usize {
    const tree = try buildTree(content);
    _ = computeTree(tree, 0);
    printTree(tree);
    var sum: usize = 0;
    for (tree.items) |node| {
        if (node.total_size <= 100_000) {
            sum += node.total_size;
        }
    }
    return sum;
}
