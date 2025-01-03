const std = @import("std");

const hashtable = @cImport({
    @cInclude("hashtable.c");
});

pub fn main() !void {
    std.debug.print("Testing hashmap!\n", .{});

    var ht = hashtable.hashtable_init();
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
    var ht = hashtable.hashtable_init();
    defer _ = hashtable.hashtable_deinit(&ht);
    const data: i32 = 4;
    _ = hashtable.hashtable_put(ht, @constCast("key"), @constCast(&data));
    const res: *align(1) i32 = @ptrCast(hashtable.hashtable_get(ht, @constCast("key")));
    try std.testing.expectEqual(@as(i32, 4), res.*);
}

test "removing element" {
    var ht = hashtable.hashtable_init();
    defer _ = hashtable.hashtable_deinit(&ht);
    const data: i32 = 4;
    _ = hashtable.hashtable_put(ht, @constCast("key"), @constCast(&data));
    _ = hashtable.hashtable_remove(ht, @constCast("key"));
    const res: ?*anyopaque = hashtable.hashtable_get(ht, @constCast("key"));
    try std.testing.expectEqual(null, res);
}
