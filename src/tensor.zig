const std = @import("std");

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
            try array.appendSlice(&elements);
            return Self{ .size = size, .shape = shape, .elements = array };
        }

        pub fn free_elements(self: *Self) void {
            self.elements.deinit();
        }

        pub fn get_element(self: *Self, pos: [rank]usize) element_type {
            var trans_pos: usize = 0;
            for (0.., pos) |i, p| {
                for (self.shape[i + 1 ..]) |s| {
                    trans_pos += p * s;
                }
            }
            trans_pos += pos[pos.len - 1];
            return self.elements.items[trans_pos];
        }
    };
}

const test_allocator = std.testing.allocator;
test "tensor init" {
    var tensor = try Tensor(3, f32, .{ 1, 2, 3 }).init(test_allocator, .{ 1.1, 2, 3, 4, 5, 6 });
    defer tensor.free_elements();
    std.debug.print("Tensor shape {!}\n", .{tensor});

    const el = tensor.get_element(.{ 0, 1, 1 });
    std.debug.print("Element {!}\n", .{el});
}
