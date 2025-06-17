const std = @import("std");


pub const Element = struct {
    id: usize,
    parent_id: ?usize,
    child_ids: std.ArrayList(usize),
    name: []const u8,

    pub fn init(allocator: std.mem.Allocator, id: usize, parent: ?usize, name: []const u8) Element {
        return .{
            .id = id,
            .parent_id = parent,
            .child_ids = .init(allocator),
            .name = name,
        };
    }

    pub fn deinit(self: *Element) void {
        self.child_ids.deinit();
    }

    // pub fn draw(self: *const Element) void {
    //     std.debug.print("{s}\n", .{self.name});
    //     for (self.child_ids.items) |child| child.draw();
    // }
};

pub const UI = struct {
    allocator: std.mem.Allocator,
    root_id: ?usize,
    current_id: ?usize,
    elements: std.ArrayList(Element),

    pub fn init(allocator: std.mem.Allocator) UI {
        return .{
            .allocator = allocator,
            .root_id = null,
            .current_id = null,
            .elements = .init(allocator),
        };
    }

    pub fn deinit(self: *UI) void {
        for (self.elements.items) |*e| {
            e.deinit();
        }
        self.elements.deinit();
    }

    fn getElement(self: *const UI, id: usize) *Element {
        return &self.elements.items[id];
    }

    fn drawElement(self: *const UI, id: usize) void {
        const e = self.getElement(id);
        std.debug.print("{s}\n", .{e.name});
        for (e.child_ids.items) |child_id| self.drawElement(child_id);
    }

    pub fn open(self: *UI, name: []const u8) !void {
        std.debug.print("open {s}\n", .{name});
        if (self.current_id) |current_id| {
            const child_id = self.elements.items.len;
            try self.elements.append(.init(self.allocator, self.elements.items.len, current_id, name));
            try self.getElement(current_id).child_ids.append(child_id);
            self.current_id = child_id;
        } else if (self.current_id == null and self.root_id == null) {
            try self.elements.append(.init(self.allocator, 0, null, name));
            self.root_id = 0;
            self.current_id = 0;
        } else unreachable;
    }

    pub fn element(self: *UI, name: []const u8) *UI {
        self.open(name) catch {};
        return self;
    }

    pub fn close(self: *UI, _: void) void {
        if (self.current_id) |current| {
            const e = self.getElement(current);
            self.current_id = self.getElement(current).parent_id;
            std.debug.print("close {s}\n", .{e.name});
        }
    }

    pub fn draw(self: *const UI) !void {
        if (self.root_id) |root_id| {
            self.drawElement(root_id);
        } else {
            return error.NoRoot;
        }
    }
};
