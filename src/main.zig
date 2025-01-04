const std = @import("std");

const hashtable = @cImport({
    @cInclude("hashtable.c");
});

pub fn main() !void {
    std.debug.print("Testing hashmap!\n", .{});

    var ht = hashtable.hashtable_init(8);
    defer _ = hashtable.hashtable_deinit(&ht);

    const Example = struct {
        data: i32 align(1),
    };

    const data = Example{
        .data = 7,
    };

    _ = hashtable.hashtable_put(ht, @constCast("key"), @constCast(&data));
    const res: *Example = @ptrCast(hashtable.hashtable_get(ht, @constCast("key")));
    std.debug.print("Result: {d}\n", .{res.*.data});
}

test "simple test" {
    var ht = hashtable.hashtable_init(8);
    defer _ = hashtable.hashtable_deinit(&ht);
    const data: i32 = 4;
    _ = hashtable.hashtable_put(ht, @constCast("key"), @constCast(&data));
    const res: *align(1) i32 = @ptrCast(hashtable.hashtable_get(ht, @constCast("key")));
    try std.testing.expectEqual(@as(i32, 4), res.*);
}

test "removing element" {
    var ht = hashtable.hashtable_init(8);
    defer _ = hashtable.hashtable_deinit(&ht);
    const data: i32 = 4;
    _ = hashtable.hashtable_put(ht, @constCast("key"), @constCast(&data));
    _ = hashtable.hashtable_remove(ht, @constCast("key"));
    const res = hashtable.hashtable_get(ht, @constCast("key"));
    try std.testing.expectEqual(null, res);
}

test "fuzzing" {
    try std.testing.fuzz(struct {
        pub fn func(source: []const u8) !void {
            if (source.len == 0) return;
            std.debug.print("source: {s}", .{source});
            var ht = hashtable.hashtable_init(8);
            defer _ = hashtable.hashtable_deinit(&ht);
            var i: usize = 0;
            while (i + 2 < source.len) : (i += 2) {
                const data: i32 = 4;
                const operation: u8 = source[i];
                const key: [*c]u8 = @constCast(@as([2]u8, .{ source[i + 1], 0 })[0..]);
                const value: u8 = source[i + 2];

                switch (operation % 3) {
                    0 => {
                        _ = hashtable.hashtable_get(ht, key);
                    },
                    1 => {
                        _ = hashtable.hashtable_put(ht, key, @constCast(&value));
                    },
                    2 => {
                        _ = hashtable.hashtable_remove(ht, key);
                    },
                    else => unreachable,
                }

                _ = hashtable.hashtable_put(ht, @constCast("key"), @constCast(&data));
                const res: *align(1) i32 = @ptrCast(hashtable.hashtable_get(ht, @constCast("key")));
                try std.testing.expectEqual(4, res.*);
            }
        }
    }.func, .{});
}
