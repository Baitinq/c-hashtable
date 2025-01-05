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

    _ = hashtable.hashtable_put(ht, @constCast("key"), @constCast(&data), @sizeOf(Example));
    const res: *Example = @ptrCast(hashtable.hashtable_get(ht, @constCast("key")));
    std.debug.print("Result: {d}\n", .{res.*.data});
}

test "simple test" {
    var ht = hashtable.hashtable_init(8);
    defer _ = hashtable.hashtable_deinit(&ht);
    const data: i32 = 4;
    _ = hashtable.hashtable_put(ht, @constCast("key"), @constCast(&data), @sizeOf(i32));
    const res: *align(1) i32 = @ptrCast(hashtable.hashtable_get(ht, @constCast("key")));
    try std.testing.expectEqual(@as(i32, 4), res.*);
}

test "removing element" {
    var ht = hashtable.hashtable_init(8);
    defer _ = hashtable.hashtable_deinit(&ht);
    const data: i32 = 4;
    _ = hashtable.hashtable_put(ht, @constCast("key"), @constCast(&data), @sizeOf(i32));
    _ = hashtable.hashtable_remove(ht, @constCast("key"));
    const res = hashtable.hashtable_get(ht, @constCast("key"));
    try std.testing.expectEqual(null, res);
}

test "fuzzing" {
    try std.testing.fuzz(struct {
        pub fn func(source: []const u8) !void {
            if (source.len == 0) return;
            const capacity: u8 = if (source[0] == 0) 1 else source[0];
            var ht = hashtable.hashtable_init(capacity);
            defer _ = hashtable.hashtable_deinit(&ht);

            // NOTE: BufMap doesnt require memory management
            var reference_hashmap = std.BufMap.init(std.testing.allocator);
            defer reference_hashmap.deinit();

            var i: usize = 1;
            while (i + 2 < source.len) : (i += 2) {
                const operation: u8 = source[i];
                const key: [*c]u8 = @constCast(@as([2]u8, .{ source[i + 1], 0 })[0..]);
                const value: [*c]u8 = @constCast(@as([2]u8, .{ source[i + 2], 0 })[0..]);

                switch (operation % 3) {
                    0 => {
                        const ret: ?[*]u8 = @ptrCast(hashtable.hashtable_get(ht, key));
                        const reference_ret: ?[]const u8 = reference_hashmap.get(key[0..2]);
                        if (ret == null or reference_ret == null) {
                            try std.testing.expectEqual(ret == null, reference_ret == null);
                        } else {
                            try std.testing.expectEqualStrings(reference_ret.?, @as([*]u8, ret.?)[0..2]);
                        }
                    },
                    1 => {
                        _ = hashtable.hashtable_put(ht, key, @constCast(value), @sizeOf(u8) * 2);
                        try reference_hashmap.put(key[0..2], @as([*]u8, value)[0..2]);
                    },
                    2 => {
                        _ = hashtable.hashtable_remove(ht, key);
                        reference_hashmap.remove(key[0..2]);
                    },
                    else => unreachable,
                }
            }
        }
    }.func, .{});
}
