const std = @import("std");

fn printErrorMessage() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();
    try stdout.print("\n", .{});
    try stdout.print("Number must NOT contain spaces.\n", .{});
    try stdout.print("Number must NOT contain letters.\n", .{});
    try stdout.print("Number must NOT contain symbols.\n", .{});
    try stdout.print("Number must NOT be a decimal number.\n", .{});
    try stdout.print("Number must NOT be a negative integer.\n", .{});
    try stdout.print("Number must NOT be an even integer.\n", .{});
    try stdout.print("Number must NOT be blank.\n", .{});
    try stdout.print("\n", .{});

    try bw.flush();
}

pub fn validateUserInput(input: []const u8, user_input: *usize) !bool {
    var num_digits: usize = 0;

    if (input[0] == '-') {
        try printErrorMessage();
    } else {
        var i: usize = 0;
        while (i < input.len) {
            if (std.ascii.isDigit(input[i])) {
                num_digits += 1;
            } else {
                try printErrorMessage();
                return false;
            }
            i += 1;
        }
    }

    if ((input[input.len - 1] == '1') or (input[input.len - 1] == '3') or (input[input.len - 1] == '5') or (input[input.len - 1] == '7') or (input[input.len - 1] == '9')) {
        const trimmed_string = try std.fmt.parseInt(usize, input, 10);
        user_input.* = trimmed_string;
        return true;
    } else {
        try printErrorMessage();
        return false;
    }
}

fn getUserInput() !usize {
    while (true) {
        const stdout = std.io.getStdOut().writer();
        const stdin = std.io.getStdIn().reader();
        var input: usize = 0;
        try stdout.print("Enter an odd integer: ", .{});

        var buf: [10]u8 = undefined;
        if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
            if (try validateUserInput(user_input, &input)) {
                return input;
            }
        } else {
            return @as(usize, 0);
        }
    }
}

fn initialSquareArray(square_array: [][]u8, odd_int: usize, input: u8) void {
    for (0..odd_int) |i| {
        for (0..odd_int) |j| {
            square_array[i][j] = input;
        }
    }
}

fn fillSquareArray(square_array: [][]u8, odd_int: usize, index: usize, input: u8) void {
    for (index..(odd_int / 2) + 1, 0..) |i, i_index| {
        if (i_index % 2 == 0) {
            for (i..odd_int - i) |j| {
                square_array[i][j] = input;
                square_array[(odd_int - 1) - i][j] = input;
                square_array[j][i] = input;
                square_array[j][(odd_int - 1) - i] = input;
            }
        }
    }
}

fn printSquareArray(square_array: [][]u8, odd_int: usize) !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    for (0..odd_int) |i| {
        for (0..odd_int) |j| {
            try stdout.print("{s}", .{square_array[i][j .. j + 1]});
            try stdout.print(" ", .{});
        }
        try stdout.print("\n", .{});
        try bw.flush();
    }
}

fn printPattern(square_array: [][]u8, odd_int: usize) !void {
    const x: u8 = 'X';
    const space: u8 = ' ';

    if (odd_int % 4 == 1) {
        initialSquareArray(square_array, odd_int, space);
        fillSquareArray(square_array, odd_int, 0, x);
    } else {
        initialSquareArray(square_array, odd_int, x);
        fillSquareArray(square_array, odd_int, 1, space);
    }

    try printSquareArray(square_array, odd_int);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var user_input: usize = try getUserInput();
    var square_array: [][]u8 = try allocator.alloc([]u8, user_input);

    for (square_array, 0..) |_, index| {
        square_array[index] = try allocator.alloc(u8, user_input);
    }

    defer allocator.free(square_array);
    try printPattern(square_array, user_input);
}
