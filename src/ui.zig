const std = @import("std");
const rl = @import("raylib");

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

    parent: ?*Element = null,
    children: std.ArrayList(*Element),

    rectangle: rl.Rectangle,
    padding: Padding,
    child_gap: f32,

    position: rl.Vector2,
    size: rl.Vector2,
    horizontal: SizeMode,
    vertical: SizeMode,
    direction: Direction,

    background_color: ?rl.Color,

    pub fn init(args: struct {
        allocator: std.mem.Allocator,
        position: rl.Vector2 = rl.Vector2.zero,
        size: rl.Vector2 = rl.Vector2.zero,
        padding: Padding = .all(8),
        child_gap: f32 = 8,
        horizontal: SizeMode = .fit,
        vertical: SizeMode = .fit,
        direction: Direction = .left_to_right,
        background_color: ?rl.Color = null,
    }) !Element {
        return .{
            .allocator = args.allocator,
            .children = .init(args.allocator),
            .rectangle = rl.Rectangle.zero,
            .position = args.position,
            .size = args.size,
            .horizontal = args.horizontal,
            .vertical = args.vertical,
            .direction = args.direction,
            .child_gap = args.child_gap,
            .background_color = args.background_color,
            .padding = args.padding,
        };
    }

    pub fn deinit(self: *Element) void {
        for (self.children.items) |child| {
            child.children.deinit();
        }
        self.children.deinit();
    }

    fn calculateFit(self: *Element, window: *const rl.Window) void {
        // Reset
        if (self.horizontal != .fixed) self.rectangle.width = 0;
        if (self.vertical != .fixed) self.rectangle.height = 0;
        self.rectangle.x = 0;
        self.rectangle.y = 0;

        // Calculate children first
        for (self.children.items) |child| {
            child.calculateFit(window);
        }

        if (self.parent) |parent| {
            self.rectangle.width += parent.padding.left + parent.padding.right;
            self.rectangle.height += parent.padding.top + parent.padding.bottom;
            const child_gap = @as(f32, @floatFromInt(parent.children.items.len - 1)) * parent.child_gap;
            switch (parent.direction) {
                .left_to_right => {
                    self.rectangle.width += child_gap;
                    parent.rectangle.width += self.rectangle.width;
                    parent.rectangle.height = @max(parent.rectangle.height, self.rectangle.height);
                },
                .top_to_bottom => {
                    self.rectangle.height += child_gap;
                    parent.rectangle.width = @max(parent.rectangle.width, self.rectangle.width);
                    parent.rectangle.height += self.rectangle.height;
                },
            }
        } else {
            self.rectangle.width = @floatFromInt(window.getWidth());
            self.rectangle.height = @floatFromInt(window.getHeight());
        }
    }

    fn calculateGrow(self: *Element) !void {
        var remaining_width = self.rectangle.width;
        remaining_width -= self.padding.left + self.padding.right;
        remaining_width -= @as(f32, @floatFromInt(self.children.items.len - 1)) * self.child_gap;

        var growable = std.ArrayList(*Element).init(self.allocator);
        defer growable.deinit();
        for (self.children.items) |child| {
            child.rectangle.height = 100;
            remaining_width -= child.rectangle.width;
            try growable.append(child);
        }

        if (growable.items.len == 0) return;


        while (remaining_width > 0) {
            var smallest = growable.items[0].*;
            var second_smallest: Element = undefined;

            var width_to_add = remaining_width;

            for (growable.items) |child| {
                if (child.rectangle.width < smallest.rectangle.width) {
                    second_smallest = smallest;
                    smallest = child.*;
                }
                if (child.rectangle.width > smallest.rectangle.width) {
                    second_smallest.rectangle.width = @min(second_smallest.rectangle.width, child.rectangle.width);
                    width_to_add = second_smallest.rectangle.width - smallest.rectangle.width;
                }
            }

            width_to_add = @min(width_to_add, remaining_width / @as(f32, @floatFromInt(growable.items.len)));

            for (growable.items) |child| {
                if (child.rectangle.width == smallest.rectangle.width) {
                    child.rectangle.width += width_to_add;
                    remaining_width -= width_to_add;
                }
            }
        }
    }

    fn calculatePosition(self: *Element) void {
        if (self.parent == null) {
            self.rectangle.x = self.padding.right;
            self.rectangle.y = self.padding.top;
        }

        if (self.direction == .left_to_right) {
            var x_offest = self.rectangle.x + self.padding.right;
            // if (self.children.getLastOrNull()) |child| x_offest += child.padding.right;
            for (self.children.items) |child| {
                const y_offset = self.rectangle.y + child.padding.top;
                child.rectangle.x = x_offest;
                child.rectangle.y = y_offset;
                x_offest += child.rectangle.width + self.child_gap;
            }
        } else if (self.direction == .top_to_bottom) {
            var y_offest = self.rectangle.y + self.padding.top;
            // if (self.children.getLastOrNull()) |child| y_offest += child.padding.top;
            for (self.children.items) |child| {
                const x_offset = self.rectangle.x + self.padding.right;
                child.rectangle.y = y_offest;
                child.rectangle.x = x_offset;
                y_offest += child.rectangle.height + self.child_gap;
            }
        }
    }

    pub fn addChild(self: *Element, child: *Element) !void {
        try self.children.append(child);
        self.children.items[self.children.items.len - 1].parent = self;
    }

    pub fn update(self: *Element, window: *const rl.Window) !void {
        if (window.isResized()) {
            self.calculateFit(window);
            try self.calculateGrow();
            self.calculatePosition();
        }
    }

    pub fn draw(self: Element) void {
        if (self.background_color) |color| {
            rl.drawRectangle(
                @intFromFloat(self.rectangle.x),
                @intFromFloat(self.rectangle.y),
                @intFromFloat(self.rectangle.width),
                @intFromFloat(self.rectangle.height),
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
