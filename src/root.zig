//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;

// pub fn reduce(targ

pub fn next(n: u64) u64 {
    const ret: u64 = single_pass(n);
    if (odd(ret)) return ret;

    return next(ret);
}

fn single_pass(n: u64) u64 {
    if (n == 1) return 1;
    return if (even(n)) (n / 2) else (3 * n + 1);
}

fn even(n: u64) bool {
    return (0 == (n % 2));
}

fn odd(n: u64) bool {
    return !even(n);
}

test "find the next odd number" {
    try testing.expectEqual(1, next(1));
    try testing.expectEqual(1, next(2));
    try testing.expectEqual(5, next(3));
    try testing.expectEqual(1, next(4));
    try testing.expectEqual(1, next(5));

    try testing.expectEqual(11, next(7));
    try testing.expectEqual(7, next(9));
    try testing.expectEqual(17, next(11));
    try testing.expectEqual(5, next(13));
    try testing.expectEqual(23, next(15));
}
