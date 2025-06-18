const std = @import("std");
const rl = @import("raylib");
pub const Backend = @import("ui/backend.zig");

const Direction = enum {
    left_to_right,
    top_to_bottom,
};

const SizingType = union(enum) {
    fit,
    grow,
    fixed: f32,
};

const Sizing = struct {
    width: SizingType,
    height: SizingType,
};

pub const Element = struct {
    child_ids: std.ArrayList(usize),
    background_color: ?rl.Color,
    direction: Direction,
    sizing: Sizing,

    pub const Args = struct {
        direction: Direction = .left_to_right,
        background_color: ?rl.Color = null,
        sizing: Sizing = .{ .width = .fit, .height = .fit },
    };

    pub fn init(allocator: std.mem.Allocator, args: Args) Element {
        return .{
            .child_ids = .init(allocator),
            .background_color = args.background_color,
            .direction = args.direction,
            .sizing = args.sizing,
        };
    }

    pub fn deinit(self: *Element) void {
        self.child_ids.deinit();
    }

    pub fn draw(self: Element, rect: rl.Rectangle) void {
        _ = self;
        std.debug.print("{any}\n", .{rect});
    }
};

pub const Text = struct {
    text: []const u8,

    pub const Args = struct {
        text: []const u8,
    };

    pub fn init(args: Args) Text {
        return .{ .text = args.text };
    }

    pub fn deinit(self: *Text) void {
        _ = self;
    }
    pub fn draw(self: Text, rect: rl.Rectangle) void {
        std.debug.print("{s} {any}\n", .{ self.text, rect });
    }
};

pub const Node = struct {
    id: usize,
    parent_id: ?usize,
    name: ?[]const u8,
    level: usize,
    rect: rl.Rectangle,
    content: union(enum) {
        element: Element,
        text: Text,
    },

    pub const Args = union(enum) {
        element: Element.Args,
        text: Text.Args,
    };

    pub fn deinit(self: *Node) void {
        switch (self.content) {
            inline else => |*c| c.deinit(),
        }
    }

    pub fn draw(self: Node) void {
        switch (self.content) {
            inline else => |*c| c.draw(self.rect),
        }
    }
};

pub const UI = struct {
    allocator: std.mem.Allocator,
    backend: Backend,
    root_id: ?usize,
    current_id: ?usize,
    nodes: std.ArrayList(Node),
    need_resize: bool = true,

    pub fn init(allocator: std.mem.Allocator, backend: Backend) UI {
        return .{
            .allocator = allocator,
            .backend = backend,
            .root_id = null,
            .current_id = null,
            .nodes = .init(allocator),
        };
    }

    pub fn deinit(self: *UI) void {
        for (self.nodes.items) |*node| {
            node.deinit();
        }
        self.nodes.deinit();
    }

    fn getNode(self: *const UI, id: usize) *Node {
        return &self.nodes.items[id];
    }

    fn drawNode(self: *const UI, id: usize) void {
        const node = self.getNode(id);
        if (node.name) |name| std.debug.print("{s} ", .{name});
        node.draw();
        if (node.content == .element) {
            for (node.content.element.child_ids.items) |child_id| self.drawNode(child_id);
        }
    }

    pub fn open(self: *UI, name: []const u8, args: Node.Args) !void {
        if (self.current_id) |current_id| {
            if (self.getNode(current_id).content != .element) {
                return error.ParentNotElement;
            }
            const child_id = self.nodes.items.len;
            switch (args) {
                .element => {
                    try self.nodes.append(.{
                        .id = child_id,
                        .parent_id = current_id,
                        .name = name,
                        .level = 0,
                        .rect = .zero,
                        .content = .{ .element = Element.init(self.allocator, args.element) },
                    });
                },
                .text => {
                    try self.nodes.append(.{
                        .id = child_id,
                        .parent_id = current_id,
                        .name = name,
                        .level = 0,
                        .rect = .zero,
                        .content = .{ .text = Text.init(args.text) },
                    });
                },
            }
            try self.getNode(current_id).content.element.child_ids.append(child_id);
            self.current_id = child_id;
        } else if (self.current_id == null and self.root_id == null) {
            switch (args) {
                .element => {
                    try self.nodes.append(.{
                        .id = 0,
                        .parent_id = null,
                        .name = name,
                        .level = 0,
                        .rect = .zero,
                        .content = .{ .element = Element.init(self.allocator, args.element) },
                    });
                },
                .text => {
                    try self.nodes.append(.{
                        .id = 0,
                        .parent_id = 0,
                        .name = name,
                        .level = 0,
                        .rect = .zero,
                        .content = .{ .text = Text.init(args.text) },
                    });
                },
            }
            self.root_id = 0;
            self.current_id = 0;
        } else unreachable;
    }

    pub fn close(self: *UI, _: void) void {
        if (self.current_id) |current| {
            // const e = self.getElement(current);
            self.current_id = self.getNode(current).parent_id;
            // std.debug.print("close {s}\n", .{e.name.?});
        }
    }

    pub fn element(self: *UI, name: []const u8, args: Element.Args) *UI {
        self.open(name, Node.Args{ .element = args }) catch {};
        return self;
    }

    pub fn text(self: *UI, name: []const u8, args: Text.Args) *UI {
        self.open(name, Node.Args{ .text = args }) catch {};
        return self;
    }

    pub fn draw(self: *const UI) !void {
        // draw
        if (self.root_id) |root_id| {
            self.drawNode(root_id);
        } else {
            return error.NoRoot;
        }
    }

    pub fn update(self: *UI) void {
        if (self.backend.isResized()) self.need_resize = true;
        if (self.need_resize) {
            if (self.root_id) |root_id| {
                const root = self.getNode(root_id);
                root.rect.width = self.backend.getWidth();
                root.rect.height = self.backend.getHeight();
            }
            // fit sizing widths
            // grow and shrink sizing widths
            // wrap text
            // fit sizing heights
            // grow and shrink sizing heights
            // positions
            self.need_resize = false;
            std.debug.print("Resized\n", .{});
        }
    }
};
