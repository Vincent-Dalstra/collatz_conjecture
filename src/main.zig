const std = @import("std");
const Io = std.Io;

const collatz = @import("collatz_conjecture");

const UP_TO_NUM = 1000;

var done_map: std.AutoHashMap(u64, void) = undefined;

var todo: std.AutoHashMap(u64, void) = undefined;

pub fn main(init: std.process.Init) !void {
    // Memory
    var aalloc = init.arena.allocator();

    //    const stdin_buf: []u8 = try aalloc.alloc(u8, (16 * 1024));
    //    var stdin_reader = std.fs.File.stdin().reader(stdin_buf);
    //    const stdin: *std.io.Reader = &stdin_reader.interface;

    // In order to do I/O operations need an `Io` instance.
    const io = init.io;

    const stdout_buffer: []u8 = try aalloc.alloc(u8, (16 * 1024));
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), io, stdout_buffer);
    const stdout_writer = &stdout_file_writer.interface;

    done_map = .init(aalloc);
    defer done_map.deinit();

    todo = .init(aalloc);
    defer todo.deinit();

    try stdout_writer.print(
        "{s}\"{s}\" {{\n", // escaped '{'
        .{
            "digraph",
            "collatz",
        },
    );

    try set_node_color("blue", stdout_writer);

    std.debug.print("All odd number from {} -> {}\n", .{ 1, UP_TO_NUM });

    var n_done: u64 = 0;
    for (2..(UP_TO_NUM + 1)) |i| {
        if (even(i)) continue;

        const next = collatz.next(i);
        try connect(i, next, stdout_writer);
        n_done += 1;

        try process(next);
    }

    std.debug.print("Created {} nodes\n", .{n_done});
    n_done = 0;

    try set_node_color("red", stdout_writer);

    var i: u64 = UP_TO_NUM + 1;
    var n_todo = todo.count();
    while (n_todo > 0) : (i += 1) {
        if (even(i)) continue;

        if (todo.contains(i)) {
            const next = collatz.next(i);
            try connect(i, next, stdout_writer);
            n_todo -= 1;
            n_done += 1;
        }
    }

    std.debug.print("Created {} more intermediate nodes\n", .{n_done});

    try stdout_writer.print("}}\n", .{}); // escaped '}'
    try stdout_writer.flush();
}

fn process(i: u64) !void {
    // Already done or on the todo list
    if (i <= UP_TO_NUM) return;
    if (todo.contains(i)) return;

    try todo.putNoClobber(i, {});

    // Recursive
    const next = collatz.next(i);
    return process(next);
}

fn set_node_color(color: []const u8, writer: *Io.Writer) !void {
    try writer.print(
        "{s} [color=\"{s}\"]\n",
        .{
            "node",
            color,
        },
    );
}

fn connect(i: u64, next: u64, writer: *Io.Writer) !void {
    try writer.print(
        "{} -> {}\n",
        .{ i, next },
    );
}

fn even(n: u64) bool {
    return (0 == (n % 2));
}
