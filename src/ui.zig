const std = @import("std");

const fontconfig = @import("fontconfig.zig");
const rl = @import("raylib.zig");

const Self = @This();

allocator: std.mem.Allocator,
combo_boxes: std.ArrayList(*ComboBox),
buttons: std.ArrayList(*Button),

var font: rl.Font = undefined;
const font_size = 64;

pub const Colors = struct {
    pub const background = rl.getColor(0xc9a2cdff);
    pub const element_background = rl.getColor(0xd9bbdcff);
    pub const border = rl.getColor(0xe6d0e8ff);
    pub const border_hower = rl.getColor(0xae5b68ff);
};

// Must be initialized after raylib.initWindow()
pub fn init(allocator: std.mem.Allocator) !Self {
    const font_path = try fontconfig.getDefaultFontPath(allocator);
    defer allocator.free(font_path);

    font = rl.loadFontEx(font_path.ptr, font_size, 0, 250);

    return .{
        .allocator = allocator,
        .combo_boxes = .init(allocator),
        .buttons = .init(allocator),
    };
}

pub fn deinit(self: *Self) void {
    rl.unloadFont(font);
    for (self.combo_boxes.items) |combo_box| {
        self.allocator.destroy(combo_box);
    }
    self.combo_boxes.deinit();
    for (self.buttons.items) |button| {
        self.allocator.destroy(button);
    }
    self.buttons.deinit();
}

pub fn addComboBox(self: *Self, rect: rl.Rectangle, items: []const []const u8, index_changed_callback: ComboBox.Callback) !*ComboBox {
    const combo_box = try self.allocator.create(ComboBox);
    combo_box.* = ComboBox.init(rect, items, index_changed_callback);
    try self.combo_boxes.append(combo_box);
    return combo_box;
}

pub fn addButton(self: *Self, rect: rl.Rectangle, text: []const u8, callback: Button.Callback) !*Button {
    const button = try self.allocator.create(Button);
    button.* = Button.init(rect, text, callback);
    try self.buttons.append(button);
    return button;
}

pub fn update(self: Self) !void {
    const mouse_position = rl.getMousePosition();
    for (self.combo_boxes.items) |combo_box| try combo_box.update(mouse_position);
    for (self.buttons.items) |button| try button.update(mouse_position);
}

pub fn draw(self: Self) void {
    for (self.combo_boxes.items) |combo_box| combo_box.draw();
    for (self.buttons.items) |button| button.draw();
}

pub const ComboBox = struct {
    pub const Callback = *const fn (self: *ComboBox) anyerror!void;
    rect: rl.Rectangle,
    items: []const []const u8,
    index: usize,
    index_changed_callback: Callback,
    state: enum { normal, hower } = .normal,

    pub fn init(rect: rl.Rectangle, items: []const []const u8, index_changed_callback: ComboBox.Callback) ComboBox {
        return .{
            .rect = rect,
            .items = items,
            .index = 0,
            .index_changed_callback = index_changed_callback,
        };
    }

    pub fn update(self: *ComboBox, mouse_position: rl.Vector2) !void {
        if (rl.checkCollisionPointRec(mouse_position, self.rect)) {
            self.state = .hower;
            var index: i32 = @intCast(self.index);
            index += @intFromFloat(rl.getMouseWheelMove());
            if (index == self.items.len) {
                index = 0;
            } else if (index < 0) {
                index = @as(i32, @intCast(self.items.len)) - 1;
            }
            if (index != self.index) {
                try self.index_changed_callback(self);
            }
            self.index = @intCast(index);
        } else {
            self.state = .normal;
        }
    }

    pub fn draw(self: ComboBox) void {
        rl.drawRectangleRec(self.rect, Colors.element_background);
        const border_color = if (self.state == .normal) Colors.border else Colors.border_hower;
        rl.drawRectangleLinesEx(self.rect, 1, border_color);

        const text = self.items[self.index].ptr;
        const text_size = rl.measureTextEx(font, text, font_size, 0);

        rl.drawTextEx(
            font,
            text,
            .{
                .x = (self.rect.width - text_size.x) / 2 + self.rect.x,
                .y = (self.rect.height - text_size.y) / 2 + self.rect.y,
            },
            font_size,
            0,
            rl.white,
        );
    }
};

pub const Button = struct {
    pub const Callback = *const fn (self: *Button) anyerror!void;

    rect: rl.Rectangle,
    text: []const u8,
    callback: Callback,
    background: rl.Color = Colors.element_background,
    state: enum { normal, hower, pressed } = .normal,

    pub fn init(rect: rl.Rectangle, text: []const u8, callback: Callback) Button {
        return .{
            .rect = rect,
            .text = text,
            .callback = callback,
        };
    }

    pub fn update(self: *Button, mouse_position: rl.Vector2) !void {
        if (rl.checkCollisionPointRec(mouse_position, self.rect)) {
            self.state = .hower;
            if (rl.isMouseButtonReleased(0)) {
                try self.callback(self);
            }
            // var index: i32 = @intCast(self.index);
            // index += @intFromFloat(rl.getMouseWheelMove());
            // if (index == self.items.len) {
            //     index = 0;
            // } else if (index < 0) {
            //     index = @as(i32, @intCast(self.items.len)) - 1;
            // }
            // self.index = @intCast(index);
        } else {
            self.state = .normal;
        }
    }

    pub fn draw(self: Button) void {
        rl.drawRectangleRec(self.rect, self.background);
        const border_color = if (self.state == .normal) Colors.border else Colors.border_hower;
        rl.drawRectangleLinesEx(self.rect, 1, border_color);

        const text = self.text.ptr;
        const text_size = rl.measureTextEx(font, text, font_size, 0);

        rl.drawTextEx(
            font,
            text,
            .{
                .x = (self.rect.width - text_size.x) / 2 + self.rect.x,
                .y = (self.rect.height - text_size.y) / 2 + self.rect.y,
            },
            font_size,
            0,
            rl.white,
        );
    }
};
