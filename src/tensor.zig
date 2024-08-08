const std = @import("std");

const Tensor = struct {
    m: u32, // height
    n: u32, // width
    elements: std.ArrayList(f32),
};

const test_allocator = std.testing.allocator;
test "tensor init" {
    const tensor = Tensor{ .m = 2, .n = 3, .elements = std.ArrayList(f32).init(test_allocator) };
    std.debug.print("{}\n", .{tensor});
}
