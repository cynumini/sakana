const std = @import("std");
const rl = @import("raylib");
pub const Backend = @import("user_interface/backend.zig");

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

const Padding = struct {
    top: f32,
    right: f32,
    bottom: f32,
    left: f32,

    const zero = all(0);

    pub fn all(value: f32) Padding {
        return .{ .top = value, .right = value, .bottom = value, .left = value };
    }
};

pub const Element = struct {
    child_ids: std.ArrayList(usize),
    background_color: ?rl.Color,
    direction: Direction,
    sizing: Sizing,
    padding: Padding,
    child_gap: f32,

    pub const Args = struct {
        direction: Direction = .left_to_right,
        background_color: ?rl.Color = null,
        sizing: Sizing = .{ .width = .fit, .height = .fit },
        padding: Padding = .zero,
        child_gap: f32 = 0,
    };

    pub fn init(allocator: std.mem.Allocator, args: Args) Element {
        return .{
            .child_ids = .init(allocator),
            .background_color = args.background_color,
            .direction = args.direction,
            .sizing = args.sizing,
            .padding = args.padding,
            .child_gap = args.child_gap,
        };
    }

    pub fn deinit(self: *Element) void {
        self.child_ids.deinit();
    }

    pub fn draw(self: Element, backend: *const Backend, rect: rl.Rectangle) void {
        if (self.background_color) |color| {
            backend.drawRectangle(rect, color);
        }
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
    pub fn draw(self: Text, backend: *const Backend, rect: rl.Rectangle) void {
        // actual draw
        _ = self;
        _ = rect;
        _ = backend;
    }
};

const NodeContent = union(enum) {
    element: Element,
    text: Text,
};

pub const Node = struct {
    // UserInterface-defined variables
    id: usize,
    parent_id: ?usize,
    level: usize,
    rect: rl.Rectangle,
    position: rl.Vector2,
    content: NodeContent,
    // User-defined variables
    name: ?[]const u8,

    pub const Args = struct {
        name: ?[]const u8 = null,
        position: rl.Vector2 = .zero,
    };

    pub const ContentArgs = union(enum) {
        element: Element.Args,
        text: Text.Args,
    };

    pub fn init(
        id: usize,
        parent_id: ?usize,
        level: usize,
        rect: rl.Rectangle,
        content: NodeContent,
        args: Args,
    ) Node {
        return .{
            .id = id,
            .parent_id = parent_id,
            .level = level,
            .rect = rect,
            .content = content,
            .name = args.name,
            .position = args.position,
        };
    }

    pub fn deinit(self: *Node) void {
        switch (self.content) {
            inline else => |*c| c.deinit(),
        }
    }

    pub fn draw(self: Node, backend: *const Backend) void {
        switch (self.content) {
            inline else => |*c| c.draw(backend, self.rect),
        }
    }
};

pub const UserInterface = struct {
    allocator: std.mem.Allocator,
    backend: Backend,
    root_id: ?usize,
    current_id: ?usize,
    nodes: std.ArrayList(Node),
    need_resize: bool = true,
    current_level: usize = 0,

    pub fn init(allocator: std.mem.Allocator, backend: Backend) UserInterface {
        return .{
            .allocator = allocator,
            .backend = backend,
            .root_id = null,
            .current_id = null,
            .nodes = .init(allocator),
        };
    }

    pub fn deinit(self: *UserInterface) void {
        for (self.nodes.items) |*node| {
            node.deinit();
        }
        self.nodes.deinit();
    }

    fn getNode(self: *const UserInterface, id: usize) !*Node {
        if (id < 0 or id >= self.nodes.items.len) return error.InvalidId;
        return &self.nodes.items[id];
    }

    fn drawNode(self: *const UserInterface, id: usize) !void {
        const node = try self.getNode(id);
        // actual draw here
        node.draw(&self.backend);
        if (node.content == .element) {
            for (node.content.element.child_ids.items) |child_id| try self.drawNode(child_id);
        }
    }

    pub fn open(self: *UserInterface, args: Node.Args, content_args: Node.ContentArgs) !void {
        const id: usize, const parent_id: ?usize = blk: {
            if (self.current_id) |parent_id| {
                var parent = try self.getNode(parent_id);
                if (parent.content != .element) return error.ParentNotElement;
                const child_id = self.nodes.items.len;
                try parent.content.element.child_ids.append(child_id);
                break :blk .{ self.nodes.items.len, parent_id };
            } else if (self.root_id == null) {
                self.root_id = self.nodes.items.len; // 0
                break :blk .{ self.root_id.?, null };
            } else return error.RootAlreadyExists;
        };
        try self.nodes.append(.init(
            id,
            parent_id,
            self.current_level,
            .zero,
            switch (content_args) {
                .element => .{ .element = .init(self.allocator, content_args.element) },
                .text => .{ .text = .init(content_args.text) },
            },
            args,
        ));
        self.current_id = id;
        self.current_level += 1;
    }

    pub fn panicOnError(err: anyerror) void {
        var buffer: [256]u8 = undefined;
        const message = std.fmt.bufPrint(&buffer, "{}\n", .{err}) catch @panic("Error message too long for buffer");
        @panic(message);
    }

    pub fn close(self: *UserInterface, _: void) void {
        if (self.current_id) |current_id| {
            const current = self.getNode(current_id) catch unreachable;
            self.current_id = current.parent_id;
            self.current_level -= 1;
            if (current.content == .element) {
                if (current.content.element.sizing.width == .fixed) {
                    current.rect.width = current.content.element.sizing.width.fixed;
                }
                if (current.content.element.sizing.height == .fixed) {
                    current.rect.height = current.content.element.sizing.height.fixed;
                }
            }
        } else panicOnError(error.NothingToClose);
    }

    pub fn element(self: *UserInterface, args: Node.Args, element_args: Element.Args) *UserInterface {
        self.open(args, Node.ContentArgs{ .element = element_args }) catch |err| panicOnError(err);
        return self;
    }

    pub fn text(self: *UserInterface, args: Node.Args, text_args: Text.Args) *UserInterface {
        self.open(args, Node.ContentArgs{ .text = text_args }) catch |err| panicOnError(err);
        return self;
    }

    pub fn draw(self: *const UserInterface) !void {
        if (self.root_id) |root_id| {
            try self.drawNode(root_id);
        } else {
            return error.NoRoot;
        }
    }

    pub fn position(self: *UserInterface, id: usize) !void {
        const node = try self.getNode(id);
        if (node.content == .element) {
            const parent = &node.content.element;
            if (parent.direction == .left_to_right) {
                var left_offset = parent.padding.left;
                for (parent.child_ids.items) |child_id| {
                    const child = try self.getNode(child_id);
                    child.rect.x = node.rect.x + child.position.x + left_offset;
                    child.rect.y = node.rect.y + child.position.y + parent.padding.top;
                    left_offset += child.rect.width + parent.child_gap;
                }
            } else {
                var top_offset = parent.padding.top;
                for (parent.child_ids.items) |child_id| {
                    const child = try self.getNode(child_id);
                    child.rect.x = node.rect.x + child.position.x + parent.padding.left;
                    child.rect.y = node.rect.y + child.position.y + top_offset;
                    top_offset += child.rect.height + parent.child_gap;
                }
            }
        }
    }

    pub fn update(self: *UserInterface) !void {
        if (self.backend.isResized()) self.need_resize = true;
        if (self.need_resize) {
            if (self.root_id) |root_id| {
                const root = try self.getNode(root_id);
                root.rect.width = self.backend.getWidth();
                root.rect.height = self.backend.getHeight();
                root.rect.x += root.position.x;
                root.rect.x += root.position.y;
                // fit sizing widths
                // grow and shrink sizing widths
                // wrap text
                // fit sizing heights
                // grow and shrink sizing heights
                try self.position(root_id);
            }

            self.need_resize = false;
        }
    }
};
