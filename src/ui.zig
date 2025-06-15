const std = @import("std");
const rl = @import("raylib");
const m = @import("math.zig");

pub const SizeMode = enum {
    fixed,
    fit,
    grow,
};

pub const Direction = enum {
    left_to_right,
    top_to_bottom,
};

pub const Padding = struct {
    left: f32 = 0,
    right: f32 = 0,
    top: f32 = 0,
    bottom: f32 = 0,

    pub fn zero() Padding {
        return .{ .left = 0, .right = 0, .top = 0, .bottom = 0 };
    }

    pub fn all(value: f32) Padding {
        return .{
            .left = value,
            .right = value,
            .top = value,
            .bottom = value,
        };
    }

    pub fn symmetric(vertical: f32, horizontal: f32) Padding {
        return .{
            .top = vertical,
            .bottom = vertical,
            .left = horizontal,
            .right = horizontal,
        };
    }
};

pub const Element = struct {
    allocator: std.mem.Allocator,
    id: ?[]const u8,

    parent: ?*Element = null,
    children: std.ArrayList(*Element),
    rect: rl.Rectangle,

    padding: Padding,
    child_gap: f32,
    horizontal: SizeMode,
    vertical: SizeMode,
    min_size: rl.Vector2,
    direction: Direction,
    background_color: ?rl.Color,

    pub fn init(args: struct {
        allocator: std.mem.Allocator,
        id: ?[]const u8 = null,
        padding: Padding = .all(8),
        child_gap: f32 = 8,
        horizontal: SizeMode = .fit,
        vertical: SizeMode = .fit,
        min_size: rl.Vector2 = rl.Vector2.zero,
        direction: Direction = .left_to_right,
        background_color: ?rl.Color = null,
    }) !Element {
        return .{
            .allocator = args.allocator,
            .id = args.id,
            .children = .init(args.allocator),
            .rect = rl.Rectangle.zero,
            .padding = args.padding,
            .child_gap = args.child_gap,
            .horizontal = args.horizontal,
            .vertical = args.vertical,
            .min_size = args.min_size,
            .direction = args.direction,
            .background_color = args.background_color,
        };
    }

    pub fn deinit(self: *Element) void {
        self.children.deinit();
    }

    fn calcMinSize(self: *Element, window: *const rl.Window) void {
        self.rect.width = self.padding.left + self.padding.right + self.min_size.x;
        self.rect.height = self.padding.top + self.padding.bottom + self.min_size.y;

        for (self.children.items) |child| child.calcMinSize(window);

        if (self.children.items.len > 0) {
            const child_gap = m.as(f32, self.children.items.len - 1) * self.child_gap;
            switch (self.direction) {
                .left_to_right => if (self.horizontal != .fixed) {
                    self.rect.width += child_gap;
                },
                .top_to_bottom => if (self.vertical != .fixed) {
                    self.rect.height += child_gap;
                },
            }
        }

        if (self.parent) |p| {
            switch (p.direction) {
                .left_to_right => {
                    if (p.horizontal != .fixed) p.rect.width += self.rect.width;
                    if (p.vertical != .fixed) {
                        p.rect.height = @max(
                            p.rect.height,
                            self.rect.height + p.padding.top + p.padding.bottom,
                        );
                    }
                },
                .top_to_bottom => {
                    if (p.horizontal != .fixed) {
                        p.rect.width = @max(
                            p.rect.width,
                            self.rect.width + p.padding.left + p.padding.right,
                        );
                    }
                    if (p.vertical != .fixed) p.rect.height += self.rect.height;
                },
            }
        } else {
            window.setMinSize(
                @intFromFloat(self.rect.width),
                @intFromFloat(self.rect.height),
            );
            self.rect.width = @floatFromInt(window.getWidth());
            self.rect.height = @floatFromInt(window.getHeight());
        }
    }

    fn calculateGrow(self: *Element) !void {
        if (self.children.items.len == 0) return;

        const default_second_smallest: rl.Rectangle = .{
            .width = std.math.floatMax(f32),
            .height = std.math.floatMax(f32),
            .x = 0,
            .y = 0,
        };

        // horizontal
        blk: {
            var remaining_width = self.rect.width;
            remaining_width -= self.padding.left + self.padding.right;
            remaining_width -= m.as(f32, self.children.items.len - 1) * self.child_gap;

            var growable = std.ArrayList(*Element).init(self.allocator);
            defer growable.deinit();
            for (self.children.items) |child| {
                remaining_width -= child.rect.width;
                if (child.horizontal == .grow) {
                    try growable.append(child);
                }
            }

            if (growable.items.len == 0) return;

            if (self.direction == .top_to_bottom) {
                for (growable.items) |child| {
                    child.rect.width = self.rect.width - (self.padding.left + self.padding.right);
                }
                break :blk;
            }

            while (remaining_width > 0.01) {
                var smallest = growable.items[0].rect;
                var second_smallest = default_second_smallest;

                var width_to_add = remaining_width;

                for (growable.items) |child| {
                    if (child.rect.width < smallest.width) {
                        second_smallest = smallest;
                        smallest = child.rect;
                    }
                    if (child.rect.width > smallest.width) {
                        second_smallest.width = @min(second_smallest.width, child.rect.width);
                        width_to_add = second_smallest.width - smallest.width;
                    }
                }

                width_to_add = @min(width_to_add, remaining_width / m.as(f32, growable.items.len));

                for (growable.items) |child| {
                    if (child.rect.width == smallest.width) {
                        child.rect.width += width_to_add;
                        remaining_width -= width_to_add;
                    }
                }
            }
        }
        // vertical
        blk: {
            var remaining_height = self.rect.height;
            remaining_height -= self.padding.top + self.padding.bottom;
            remaining_height -= m.as(f32, self.children.items.len - 1) * self.child_gap;

            var growable = std.ArrayList(*Element).init(self.allocator);
            defer growable.deinit();
            for (self.children.items) |child| {
                remaining_height -= child.rect.height;
                if (child.vertical == .grow) {
                    try growable.append(child);
                }
            }

            if (growable.items.len == 0) return;

            if (self.direction == .left_to_right) {
                for (growable.items) |child| {
                    child.rect.height = self.rect.height - (self.padding.top + self.padding.bottom);
                }
                break :blk;
            }

            while (remaining_height > 0.01) {
                // std.debug.print("{d:.6}, child: {s}\n", .{ remaining_height, self.id.? });
                var smallest = growable.items[0].rect;
                var second_smallest = default_second_smallest;

                var width_to_add = remaining_height;

                for (growable.items) |child| {
                    if (child.rect.height < smallest.height) {
                        second_smallest = smallest;
                        smallest = child.rect;
                    }
                    if (child.rect.height > smallest.height) {
                        second_smallest.height = @min(second_smallest.height, child.rect.height);
                        width_to_add = second_smallest.height - smallest.height;
                    }
                }

                width_to_add = @min(width_to_add, remaining_height / m.as(f32, growable.items.len));

                for (growable.items) |child| {
                    if (child.rect.height == smallest.height) {
                        child.rect.height += width_to_add;
                        remaining_height -= width_to_add;
                    }
                }
            }
        }
        for (self.children.items) |child| {
            try child.calculateGrow();
        }
    }

    fn calculatePosition(self: *Element) void {
        if (self.direction == .left_to_right) {
            var x_offest = self.rect.x + self.padding.left;
            for (self.children.items) |child| {
                const y_offset = self.rect.y + child.padding.top;
                child.rect.x = x_offest;
                child.rect.y = y_offset;
                x_offest += child.rect.width + self.child_gap;
            }
        } else if (self.direction == .top_to_bottom) {
            var y_offest = self.rect.y + self.padding.top;
            for (self.children.items) |child| {
                const x_offset = self.rect.x + self.padding.left;
                child.rect.y = y_offest;
                child.rect.x = x_offset;
                y_offest += child.rect.height + self.child_gap;
            }
        }

        for (self.children.items) |child| {
            child.calculatePosition();
        }
    }

    pub fn addChild(self: *Element, child: *Element) !void {
        try self.children.append(child);
        self.children.items[self.children.items.len - 1].parent = self;
    }

    pub fn update(self: *Element, window: *const rl.Window) !void {
        if (window.isResized()) {
            self.calcMinSize(window);
            try self.calculateGrow();
            self.calculatePosition();
        }
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
        }
        for (self.children.items) |child| {
            child.draw();
        }
    }
};

// const fontconfig = @import("fontconfig.zig");
// const rl = @import("raylib.zig");
//
// const Self = @This();
//
// allocator: std.mem.Allocator,
// combo_boxes: std.ArrayList(*ComboBox),
// buttons: std.ArrayList(*Button),
//
// var font: rl.Font = undefined;
// const font_size = 64;
//
// pub const Colors = struct {
//     pub const background = rl.getColor(0xc9a2cdff);
//     pub const element_background = rl.getColor(0xd9bbdcff);
//     pub const border = rl.getColor(0xe6d0e8ff);
//     pub const border_hower = rl.getColor(0xae5b68ff);
// };
//
// // Must be initialized after raylib.initWindow()
// pub fn init(allocator: std.mem.Allocator) !Self {
//     const font_path = try fontconfig.getDefaultFontPath(allocator);
//     defer allocator.free(font_path);
//
//     font = rl.loadFontEx(font_path.ptr, font_size, 0, 250);
//
//     return .{
//         .allocator = allocator,
//         .combo_boxes = .init(allocator),
//         .buttons = .init(allocator),
//     };
// }
//
// pub fn deinit(self: *Self) void {
//     rl.unloadFont(font);
//     for (self.combo_boxes.items) |combo_box| {
//         self.allocator.destroy(combo_box);
//     }
//     self.combo_boxes.deinit();
//     for (self.buttons.items) |button| {
//         self.allocator.destroy(button);
//     }
//     self.buttons.deinit();
// }
//
// pub fn addComboBox(self: *Self, rect: rl.Rectangle, items: []const []const u8, index_changed_callback: ComboBox.Callback) !*ComboBox {
//     const combo_box = try self.allocator.create(ComboBox);
//     combo_box.* = ComboBox.init(rect, items, index_changed_callback);
//     try self.combo_boxes.append(combo_box);
//     return combo_box;
// }
//
// pub fn addButton(self: *Self, rect: rl.Rectangle, text: []const u8, callback: Button.Callback) !*Button {
//     const button = try self.allocator.create(Button);
//     button.* = Button.init(rect, text, callback);
//     try self.buttons.append(button);
//     return button;
// }
//
// pub fn update(self: Self) !void {
//     const mouse_position = rl.getMousePosition();
//     for (self.combo_boxes.items) |combo_box| try combo_box.update(mouse_position);
//     for (self.buttons.items) |button| try button.update(mouse_position);
// }
//
// pub fn draw(self: Self) void {
//     for (self.combo_boxes.items) |combo_box| combo_box.draw();
//     for (self.buttons.items) |button| button.draw();
// }
//
// pub const ComboBox = struct {
//     pub const Callback = *const fn (self: *ComboBox) anyerror!void;
//     rect: rl.Rectangle,
//     items: []const []const u8,
//     index: usize,
//     index_changed_callback: Callback,
//     state: enum { normal, hower } = .normal,
//
//     pub fn init(rect: rl.Rectangle, items: []const []const u8, index_changed_callback: ComboBox.Callback) ComboBox {
//         return .{
//             .rect = rect,
//             .items = items,
//             .index = 0,
//             .index_changed_callback = index_changed_callback,
//         };
//     }
//
//     pub fn update(self: *ComboBox, mouse_position: rl.Vector2) !void {
//         if (rl.checkCollisionPointRec(mouse_position, self.rect)) {
//             self.state = .hower;
//             var index: i32 = @intCast(self.index);
//             index += @intFromFloat(rl.getMouseWheelMove());
//             if (index == self.items.len) {
//                 index = 0;
//             } else if (index < 0) {
//                 index = @as(i32, @intCast(self.items.len)) - 1;
//             }
//             if (index != self.index) {
//                 try self.index_changed_callback(self);
//             }
//             self.index = @intCast(index);
//         } else {
//             self.state = .normal;
//         }
//     }
//
//     pub fn draw(self: ComboBox) void {
//         rl.drawRectangleRec(self.rect, Colors.element_background);
//         const border_color = if (self.state == .normal) Colors.border else Colors.border_hower;
//         rl.drawRectangleLinesEx(self.rect, 1, border_color);
//
//         const text = self.items[self.index].ptr;
//         const text_size = rl.measureTextEx(font, text, font_size, 0);
//
//         rl.drawTextEx(
//             font,
//             text,
//             .{
//                 .x = (self.rect.width - text_size.x) / 2 + self.rect.x,
//                 .y = (self.rect.height - text_size.y) / 2 + self.rect.y,
//             },
//             font_size,
//             0,
//             rl.white,
//         );
//     }
// };
//
// pub const Button = struct {
//     pub const Callback = *const fn (self: *Button) anyerror!void;
//
//     rect: rl.Rectangle,
//     text: []const u8,
//     callback: Callback,
//     background: rl.Color = Colors.element_background,
//     state: enum { normal, hower, pressed } = .normal,
//
//     pub fn init(rect: rl.Rectangle, text: []const u8, callback: Callback) Button {
//         return .{
//             .rect = rect,
//             .text = text,
//             .callback = callback,
//         };
//     }
//
//     pub fn update(self: *Button, mouse_position: rl.Vector2) !void {
//         if (rl.checkCollisionPointRec(mouse_position, self.rect)) {
//             self.state = .hower;
//             if (rl.isMouseButtonReleased(0)) {
//                 try self.callback(self);
//             }
//             // var index: i32 = @intCast(self.index);
//             // index += @intFromFloat(rl.getMouseWheelMove());
//             // if (index == self.items.len) {
//             //     index = 0;
//             // } else if (index < 0) {
//             //     index = @as(i32, @intCast(self.items.len)) - 1;
//             // }
//             // self.index = @intCast(index);
//         } else {
//             self.state = .normal;
//         }
//     }
//
//     pub fn draw(self: Button) void {
//         rl.drawRectangleRec(self.rect, self.background);
//         const border_color = if (self.state == .normal) Colors.border else Colors.border_hower;
//         rl.drawRectangleLinesEx(self.rect, 1, border_color);
//
//         const text = self.text.ptr;
//         const text_size = rl.measureTextEx(font, text, font_size, 0);
//
//         rl.drawTextEx(
//             font,
//             text,
//             .{
//                 .x = (self.rect.width - text_size.x) / 2 + self.rect.x,
//                 .y = (self.rect.height - text_size.y) / 2 + self.rect.y,
//             },
//             font_size,
//             0,
//             rl.white,
//         );
//     }
// };
