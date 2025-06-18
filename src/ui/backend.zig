pub const Self = @This();

ptr: *anyopaque,
vtable: *const VTable,

pub const VTable = struct {
    isResized: *const fn (*anyopaque) bool,
    getWidth: *const fn (*anyopaque) f32,
    getHeight: *const fn (*anyopaque) f32,
};

pub fn isResized(self: Self) bool {
    return self.vtable.isResized(self.ptr);
}

pub fn getWidth(self: Self) f32 {
    return self.vtable.getWidth(self.ptr);
}

pub fn getHeight(self: Self) f32 {
    return self.vtable.getHeight(self.ptr);
}
