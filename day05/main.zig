const std = @import("std");

const example = @embedFile("example.txt");
const data = @embedFile("input.txt");

const Stack = std.ArrayList(u8);

const Operation = struct {
    from: u8,
    to: u8,
    number: u8,
};

fn createStacks(allocator: std.mem.Allocator, input: []const u8) ![]Stack {
    var stack_iterator = std.mem.splitBackwardsAny(u8, input, "\n");
    const num_input = stack_iterator.next().?;
    var num_it = std.mem.tokenizeScalar(u8, num_input, ' ');
    var stack_count: usize = 0;
    while (num_it.next()) |_| {
        stack_count += 1;
    }
    var stacks: []Stack = try allocator.alloc(Stack, stack_count);
    for (stacks, 0..) |_, i| {
        stacks[i] = Stack.init(allocator);
    }
    while (stack_iterator.next()) |line| {
        var i: usize = 0;
        while (i < stack_count) : (i += 1) {
            const index = 4 * i + 1;
            const item = line[index];
            if (item != ' ') {
                try stacks[i].append(item);
            }
        }
    }

    return stacks;
}

fn createOperations(allocator: std.mem.Allocator, input: []const u8) ![]Operation {
    var operations = std.ArrayList(Operation).init(allocator);
    var op_iteration = std.mem.tokenizeAny(u8, input, "\n");
    while (op_iteration.next()) |line| {
        var line_iteration = std.mem.splitAny(u8, line, " ");
        _ = line_iteration.next().?; // skip 'move'
        const nums = try std.fmt.parseInt(u8, line_iteration.next().?, 10);
        _ = line_iteration.next().?; // skip 'from'
        const from = try std.fmt.parseInt(u8, line_iteration.next().?, 10);
        _ = line_iteration.next().?; // skip 'to'
        const to = try std.fmt.parseInt(u8, line_iteration.next().?, 10);
        try operations.append(Operation{ .number = nums, .from = from, .to = to });
    }

    return operations.toOwnedSlice();
}

const Solver = struct {
    allocator: std.mem.Allocator,
    stacks: []Stack,
    operations: []Operation,
    middle: Stack,

    fn init(allocator: std.mem.Allocator, input: []const u8) !Solver {
        var split = std.mem.splitSequence(u8, input, "\n\n");
        const stack_input = split.next().?;
        const operation_input = split.next().?;

        const stacks = try createStacks(allocator, stack_input);
        const operations = try createOperations(allocator, operation_input);

        const middle = Stack.init(allocator);

        return Solver{ .allocator = allocator, .stacks = stacks, .operations = operations, .middle = middle };
    }

    fn deinit(self: *Solver) void {
        for (self.stacks) |*stack| {
            stack.deinit();
        }
        self.allocator.free(self.stacks);
        self.allocator.free(self.operations);
        self.middle.deinit();
    }

    fn print(self: *Solver, stack_only: bool) void {
        for (self.stacks, 0..) |stack, i| {
            std.debug.print("{d}: ", .{i + 1});
            for (stack.items) |item| {
                std.debug.print("{c}", .{item});
            }
            std.debug.print("\n", .{});
        }
        if (stack_only) {
            return;
        }
        for (self.operations) |op| {
            std.debug.print("{d}: {d} -> {d}\n", .{ op.number, op.from, op.to });
        }
    }

    fn solve(self: *Solver) !void {
        for (self.operations) |operation| {
            const stack_from = &self.stacks[operation.from - 1];
            const stack_to = &self.stacks[operation.to - 1];
            for (0..operation.number) |_| {
                const item = stack_from.pop();
                try stack_to.append(item);
            }
        }
    }

    fn solve2(self: *Solver) !void {
        for (self.operations) |operation| {
            const stack_from = &self.stacks[operation.from - 1];
            const stack_to = &self.stacks[operation.to - 1];

            // orderedRemove
            const at_index = stack_from.items.len - operation.number;
            for (0..operation.number) |_| {
                const item = stack_from.orderedRemove(at_index);
                try stack_to.append(item);
            }

            // appendSlice and swapRemove or pop
            //const at_index = stack_from.items.len - operation.number;
            //try stack_to.appendSlice(stack_from.items[at_index..]);
            //for (0..operation.number) |_| {
            //    _ = stack_from.swapRemove(at_index);
            //}

            // use tempary stack
            //for (0..operation.number) |_| {
            //    const item = stack_from.pop();
            //    try self.middle.append(item);
            //}
            //for (0..operation.number) |_| {
            //    const item = self.middle.pop();
            //    try stack_to.append(item);
            //}
        }
    }
};

pub fn main() !void {
    try part1(example);
    std.debug.print("\n", .{});
    try part1(data);
    std.debug.print("\n", .{});
    try part2(example);
    std.debug.print("\n", .{});
    try part2(data);
}

fn part1(input: []const u8) !void {
    const allocator = std.heap.page_allocator;
    var solver = try Solver.init(allocator, input);
    try solver.solve();
    solver.print(true);
    defer solver.deinit();
}

fn part2(input: []const u8) !void {
    const allocator = std.heap.page_allocator;
    var solver = try Solver.init(allocator, input);
    try solver.solve2();
    solver.print(true);
    defer solver.deinit();
}
