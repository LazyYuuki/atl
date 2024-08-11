const std = @import("std");

const Array = struct {};

const TensorShapeError = error{
    DimensionZero,
};

pub fn Tensor(comptime rank: usize, comptime element_type: type, comptime shape: [rank]usize) type {
    var temp: usize = 1;
    for (shape) |value| {
        if (value < 1) return TensorShapeError.DimensionZero;
        temp *= value;
    }
    const size = temp;

    return struct {
        size: usize,
        shape: [rank]usize,
        elements: std.ArrayList(element_type),

        const Self = @This();
        pub fn init(allocator: std.mem.Allocator, elements: [size]element_type) !Self {
            var array = try std.ArrayList(element_type).initCapacity(allocator, size);
            try array.appendSlice(elements[0..]);
            return Self{ .size = size, .shape = shape, .elements = array };
        }
    };
}

const test_allocator = std.testing.allocator;
test "tensor init" {
    const tensor = try Tensor(3, f32, .{ 1, 2, 3 }).init(test_allocator, .{ 1.1, 2, 3, 4, 5, 6 });
    defer tensor.elements.deinit();
    // defer tensor.allocator.deinit();
    std.debug.print("Tensor shape {!}\n", .{tensor});
}
