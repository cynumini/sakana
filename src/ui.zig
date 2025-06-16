const std = @import("std");
const rl = @import("raylib");
const m = @import("math.zig");

pub const Element = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    id: ?[]const u8,
    rect: rl.Rectangle,
    padding: Padding,
    sizing: Sizing,
    color: ?rl.Color,
    background_color: ?rl.Color,
    border: ?Border,
    need_resize: bool = true,

    pub const VTable = struct {
        getBaseMinSize: ?*const fn (*anyopaque) rl.Vector2 = null,
        update: ?*const fn (*anyopaque) anyerror!void = null,
        draw: *const fn (*anyopaque) void,
    };

    pub const Padding = struct {
        left: f32 = 0,
        right: f32 = 0,
        top: f32 = 0,
        bottom: f32 = 0,

        const zero: Padding = .all(0);

        pub fn all(value: f32) Padding {
            return .{ .left = value, .right = value, .top = value, .bottom = value };
        }

        pub fn symmetric(vertical: f32, horizontal: f32) Padding {
            return .{ .top = vertical, .bottom = vertical, .left = horizontal, .right = horizontal };
        }
    };

    pub const SizeFlag = union(enum) {
        fit,
        fixed: f32,
        grow,
    };

    pub const Sizing = struct {
        horizontal: SizeFlag,
        vertical: SizeFlag,
    };

    pub const Border = struct {
        width: usize,
        color: rl.Color,
    };

    pub const Args = struct {
        id: ?[]const u8 = null,
        rect: rl.Rectangle = .zero,
        padding: Padding = .all(8),
        sizing: Sizing = .{ .horizontal = .fit, .vertical = .fit },
        color: ?rl.Color = null,
        background_color: ?rl.Color = null,
        border: ?Border = null,
        need_resize: bool = true,

        pub fn createElement(self: Args, ptr: *anyopaque, vtable: *const VTable) Element {
            return .{
                .ptr = ptr,
                .vtable = vtable,
                .id = self.id,
                .rect = self.rect,
                .padding = self.padding,
                .sizing = self.sizing,
                .color = self.color,
                .background_color = self.background_color,
                .border = self.border,
                .need_resize = self.need_resize,
            };
        }
    };

    pub fn getBaseMinSize(self: Element) rl.Vector2 {
        if (self.vtable.getBaseMinSize) |func| return func(self.ptr);
        return .zero;
    }

    pub fn getTotalMinSize(self: Element) rl.Vector2 {
        var size = self.getBaseMinSize();
        size.x += self.padding.left + self.padding.right;
        size.y += self.padding.top + self.padding.bottom;
        if (self.border) |border| {
            size.x += @floatFromInt(border.width * 2);
            size.y += @floatFromInt(border.width * 2);
        }
        return size;
    }

    pub fn update(self: *Element) !void {
        if (self.vtable.update) |func| return func(self.ptr) else self.need_resize = false;
    }

    pub fn draw(self: Element) void {
        if (self.background_color) |color| {
            rl.drawRectangle(
                @intFromFloat(self.rect.x),
                @intFromFloat(self.rect.y),
                @intFromFloat(self.rect.width),
                @intFromFloat(self.rect.height),
                color,
            );
            if (self.border) |border| {
                rl.drawRectangleLinesEx(self.rect, @floatFromInt(border.width), border.color);
            }
        }
        self.vtable.draw(self.ptr);
    }

    pub fn getOffset(self: Element) rl.Vector2 {
        var offset: rl.Vector2 = .{ .x = self.rect.x, .y = self.rect.y };
        offset.x += self.padding.left;
        offset.y += self.padding.top;
        if (self.border) |border| {
            offset.x += @floatFromInt(border.width);
            offset.y += @floatFromInt(border.width);
        }
        return offset;
    }

    pub fn getBaseActualSize(self: Element) rl.Vector2 {
        var size: rl.Vector2 = .{ .x = self.rect.width, .y = self.rect.height };
        size.x -= self.padding.left + self.padding.right;
        size.y -= self.padding.top + self.padding.bottom;
        if (self.border) |border| {
            size.x -= @floatFromInt(border.width * 2);
            size.y -= @floatFromInt(border.width * 2);
        }
        return size;
    }
};

pub const Container = struct {
    allocator: std.mem.Allocator,
    element: Element,

    children: std.ArrayList(*Element),
    direction: Direction,
    child_gap: f32,

    pub const Direction = enum {
        left_to_right,
        top_to_bottom,
    };

    pub const Args = struct {
        direction: Direction = .left_to_right,
        child_gap: f32 = 8,
    };

    pub fn init(allocator: std.mem.Allocator, base: Element.Args, args: Args) !*Container {
        const self = try allocator.create(Container);
        self.* = .{
            .allocator = allocator,
            .element = base.createElement(self, &.{
                .getBaseMinSize = &getBaseMinSize,
                .update = &update,
                .draw = &draw,
            }),
            .children = .init(allocator),
            .direction = args.direction,
            .child_gap = args.child_gap,
        };
        return self;
    }

    pub fn deinit(self: *Container) void {
        self.children.deinit();
        self.allocator.destroy(self);
    }

    fn getBaseMinSize(context: *anyopaque) rl.Vector2 {
        const self: *Container = @ptrCast(@alignCast(context));

        var result = rl.Vector2.zero;
        const sizing = self.element.sizing;

        if (self.children.items.len == 0) {
            if (sizing.horizontal == .fixed) result.x = sizing.horizontal.fixed;
            if (sizing.vertical == .fixed) result.y = sizing.vertical.fixed;
            return result;
        }

        const child_gap = m.as(f32, self.children.items.len - 1) * self.child_gap;

        switch (self.direction) {
            .left_to_right => result.x += child_gap,
            .top_to_bottom => result.y += child_gap,
        }

        for (self.children.items) |child| {
            const child_min_size = child.getTotalMinSize();
            switch (self.direction) {
                .left_to_right => {
                    result.x += child_min_size.x;
                    result.y = @max(result.y, child_min_size.y);
                },
                .top_to_bottom => {
                    result.x = @max(result.x, child_min_size.x);
                    result.y += child_min_size.y;
                },
            }
        }

        if (sizing.horizontal == .fixed) result.x = sizing.horizontal.fixed;
        if (sizing.vertical == .fixed) result.y = sizing.vertical.fixed;

        return result;
    }

    fn grow(self: *Container) !void {
        if (self.children.items.len == 0) return;

        const default_second_smallest: rl.Rectangle = .{
            .width = std.math.floatMax(f32),
            .height = std.math.floatMax(f32),
            .x = 0,
            .y = 0,
        };

        const GrowType = enum { horizontal, vertical };

        for (self.children.items) |child| {
            const size = child.getTotalMinSize();
            child.rect.width = size.x;
            child.rect.height = size.y;
        }

        inline for (&.{ GrowType.horizontal, GrowType.vertical }) |grow_type| {
            const dimension = if (grow_type == .horizontal) "width" else "height";
            const axis = if (grow_type == .horizontal) "horizontal" else "vertical";
            const sides = if (grow_type == .horizontal) &.{ "left", "right" } else &.{ "top", "bottom" };
            const direction = if (grow_type == .horizontal) Direction.top_to_bottom else Direction.left_to_right;
            blk: {
                var remaining = @field(self.element.rect, dimension);
                inline for (sides) |side| {
                    remaining -= @field(self.element.padding, side);
                }
                remaining -= m.as(f32, self.children.items.len - 1) * self.child_gap;
                if (self.element.border) |border| remaining -= @floatFromInt(border.width * 2);

                var growable = std.ArrayList(*Element).init(self.allocator);
                defer growable.deinit();

                for (self.children.items) |child| {
                    remaining -= @field(child.rect, dimension);
                    if (@field(child.sizing, axis) == .grow) {
                        try growable.append(child);
                    }
                }

                if (growable.items.len == 0) break :blk;

                if (self.direction == direction) {
                    for (growable.items) |child| {
                        @field(child.rect, dimension) = @field(self.element.rect, dimension);
                        inline for (sides) |side| {
                            @field(child.rect, dimension) -= @field(self.element.padding, side);
                        }
                        if (self.element.border) |border| {
                            @field(child.rect, dimension) -= @floatFromInt(border.width * 2);
                        }
                    }
                    break :blk;
                }

                while (remaining > 0.01) {
                    var smallest = growable.items[0].rect;
                    var second_smallest = default_second_smallest;

                    var width_to_add = remaining;

                    for (growable.items) |child| {
                        if (@field(child.rect, dimension) < @field(smallest, dimension)) {
                            second_smallest = smallest;
                            smallest = child.rect;
                        }
                        if (@field(child.rect, dimension) > @field(smallest, dimension)) {
                            @field(second_smallest, dimension) = @min(
                                @field(second_smallest, dimension),
                                @field(child.rect, dimension),
                            );
                            width_to_add = @field(second_smallest, dimension) - @field(smallest, dimension);
                        }
                    }

                    width_to_add = @min(width_to_add, remaining / m.as(f32, growable.items.len));

                    for (growable.items) |child| {
                        if (@field(child.rect, dimension) == @field(smallest, dimension)) {
                            @field(child.rect, dimension) += width_to_add;
                            remaining -= width_to_add;
                        }
                    }
                }
            }
        }
    }

    fn place(self: *Container) void {
        var offset = self.element.getOffset();
        if (self.direction == .left_to_right) {
            for (self.children.items) |child| {
                child.rect.x = offset.x;
                child.rect.y = offset.y;
                offset.x += child.rect.width + self.child_gap;
            }
        } else if (self.direction == .top_to_bottom) {
            for (self.children.items) |child| {
                child.rect.x = offset.x;
                child.rect.y = offset.y;
                offset.y += child.rect.height + self.child_gap;
            }
        }
    }

    fn update(context: *anyopaque) !void {
        const self: *Container = @ptrCast(@alignCast(context));
        if (self.element.need_resize) {
            try self.grow();
            self.place();
            for (self.children.items) |child| {
                child.need_resize = true;
            }
            self.element.need_resize = false;
        }
        for (self.children.items) |child| {
            try child.update();
        }
    }

    fn draw(context: *anyopaque) void {
        const self: *Container = @ptrCast(@alignCast(context));
        for (self.children.items) |child| child.draw();
    }

    pub fn addChild(self: *Container, child: *Element) !void {
        try self.children.append(child);
    }
};

pub const Text = struct {
    allocator: std.mem.Allocator,
    element: Element,

    text: []const u8,
    font_size: usize,
    text_align: TextAlign,

    pub const HorizontalAlign = enum {
        center,
        left,
        right,
    };

    pub const VerticalAlign = enum {
        center,
        top,
        bottom,
    };

    pub const TextAlign = struct {
        horizontal: HorizontalAlign,
        vertical: VerticalAlign,
    };

    pub const Args = struct {
        text: []const u8,
        font_size: usize = 20,
        text_align: TextAlign = .{
            .horizontal = .center,
            .vertical = .center,
        },
    };

    pub fn init(allocator: std.mem.Allocator, base: Element.Args, args: Args) !*Text {
        const self = try allocator.create(Text);
        self.* = .{
            .allocator = allocator,
            .element = base.createElement(self, &.{
                .getBaseMinSize = &getBaseMinSize,
                .draw = &draw,
            }),
            .text = args.text,
            .font_size = args.font_size,
            .text_align = args.text_align,
        };
        return self;
    }

    pub fn deinit(self: *Text) void {
        self.allocator.destroy(self);
    }

    fn getBaseMinSize(context: *anyopaque) rl.Vector2 {
        const self: *Text = @ptrCast(@alignCast(context));
        return .{
            .x = @floatFromInt(rl.measureText(self.text, self.font_size)),
            .y = @floatFromInt(self.font_size),
        };
    }

    fn draw(context: *anyopaque) void {
        const self: *Text = @ptrCast(@alignCast(context));
        var offset = self.element.getOffset();
        const min_size = self.element.getBaseMinSize();
        const size = self.element.getBaseActualSize();
        switch (self.text_align.horizontal) {
            .center => {
                offset.x += size.x / 2 - min_size.x / 2;
            },
            .right => {
                offset.x += size.x - min_size.x;
            },
            else => {},
        }
        switch (self.text_align.vertical) {
            .center => {
                offset.y += size.y / 2 - min_size.y / 2;
            },
            .bottom => {
                offset.y += size.y - min_size.y;
            },
            else => {},
        }

        rl.drawText(
            self.text,
            @intFromFloat(offset.x),
            @intFromFloat(offset.y),
            self.font_size,
            if (self.element.color) |color| color else .black,
        );
    }
};
