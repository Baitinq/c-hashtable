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

const allocator = std.heap.page_allocator;
test "fuzzing" {
    try std.testing.fuzz(struct {
        pub fn func(source: []const u8) !void {
            if (source.len == 0) return;
            const capacity: u8 = if (source[0] == 0) 1 else source[0];
            var ht = hashtable.hashtable_init(capacity);
            defer _ = hashtable.hashtable_deinit(&ht);

            std.debug.print("START!\n", .{});

            var reference_hashmap = std.AutoHashMap([*c]u8, *u8).init(allocator); //TODO: testing allocator

            var i: usize = 1;
            while (i + 2 < source.len) : (i += 2) {
                const operation: u8 = source[i];
                const key: [*c]u8 = @constCast(@as([2]u8, .{ source[i + 1], 0 })[0..]);
                const value: u8 = source[i + 2];

                // std.debug.print("Key: ptr {any} - value {d}\n", .{ key, key.* });

                switch (operation % 3) {
                    0 => {
                        std.debug.print("Getting key {any}\n", .{key});
                        const ret: ?*u8 = @ptrCast(hashtable.hashtable_get(ht, key));
                        const reference_ret: ?*u8 = reference_hashmap.get(key);
                        // std.debug.print("Reference get value: {any}\n", .{reference_ret});
                        try std.testing.expectEqual(reference_ret, ret);
                    },
                    1 => {
                        std.debug.print("Putting key {any} - {d}\n", .{ key, key.* });
                        _ = hashtable.hashtable_put(ht, key, @constCast(&value), @sizeOf(u8));
                        try reference_hashmap.put(key, @constCast(&value));
                    },
                    2 => {
                        std.debug.print("Removing key {any} - {d}\n", .{ key, key.* });
                        const ret = hashtable.hashtable_remove(ht, key);
                        const reference_ret = reference_hashmap.remove(key);
                        const a: i32 = if (reference_ret) 1 else 0;
                        try std.testing.expectEqual(a, ret);
                    },
                    else => unreachable,
                }
                //we cannot free or it will reuse the same memory and also doesnt make sense
                // allocator.free(rawkey);
            }
        }
    }.func, .{});
}
