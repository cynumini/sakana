pub const c = @cImport({
    @cInclude("GLFW/glfw3.h");
});

const Action = enum {
    release,
    press,
    repeat,
};

const Key = enum(i32) {
    space = 32,
    apostrophe = 39,
    comma = 44,
    minus = 45,
    period = 46,
    slash = 47,
    @"0" = 48,
    @"1" = 49,
    @"2" = 50,
    @"3" = 51,
    @"4" = 52,
    @"5" = 53,
    @"6" = 54,
    @"7" = 55,
    @"8" = 56,
    @"9" = 57,
    semicolon = 59,
    equal = 61,
    a = 65,
    b = 66,
    c = 67,
    d = 68,
    e = 69,
    f = 70,
    g = 71,
    h = 72,
    i = 73,
    j = 74,
    k = 75,
    l = 76,
    m = 77,
    n = 78,
    o = 79,
    p = 80,
    q = 81,
    r = 82,
    s = 83,
    t = 84,
    u = 85,
    v = 86,
    w = 87,
    x = 88,
    y = 89,
    z = 90,
    left_bracket = 91,
    backslash = 92,
    right_bracket = 93,
    grave_accent = 96,
    world_1 = 161,
    world_2 = 162,
    escape = 256,
    enter = 257,
    tab = 258,
    backspace = 259,
    insert = 260,
    delete = 261,
    right = 262,
    left = 263,
    down = 264,
    up = 265,
    page_up = 266,
    page_down = 267,
    home = 268,
    end = 269,
    caps_lock = 280,
    scroll_lock = 281,
    num_lock = 282,
    print_screen = 283,
    pause = 284,
    f1 = 290,
    f2 = 291,
    f3 = 292,
    f4 = 293,
    f5 = 294,
    f6 = 295,
    f7 = 296,
    f8 = 297,
    f9 = 298,
    f10 = 299,
    f11 = 300,
    f12 = 301,
    f13 = 302,
    f14 = 303,
    f15 = 304,
    f16 = 305,
    f17 = 306,
    f18 = 307,
    f19 = 308,
    f20 = 309,
    f21 = 310,
    f22 = 311,
    f23 = 312,
    f24 = 313,
    f25 = 314,
    kp_0 = 320,
    kp_1 = 321,
    kp_2 = 322,
    kp_3 = 323,
    kp_4 = 324,
    kp_5 = 325,
    kp_6 = 326,
    kp_7 = 327,
    kp_8 = 328,
    kp_9 = 329,
    kp_decimal = 330,
    kp_divide = 331,
    kp_multiply = 332,
    kp_subtract = 333,
    kp_add = 334,
    kp_enter = 335,
    kp_equal = 336,
    left_shift = 340,
    left_control = 341,
    left_alt = 342,
    left_super = 343,
    right_shift = 344,
    right_control = 345,
    right_alt = 346,
    right_super = 347,
    menu = 348,
};

pub fn init() !void {
    if (c.glfwInit() != c.GLFW_TRUE) return error.GLFWInitError;
}

pub fn deinit() void {
    c.glfwTerminate();
}

const OpenGLProfile = enum(i32) {
    core_profile = c.GLFW_OPENGL_CORE_PROFILE,
    compat_profile = c.GLFW_OPENGL_COMPAT_PROFILE,
    any_profile = c.GLFW_OPENGL_ANY_PROFILE,
};

pub fn setupOpenGL(context_version_major: i32, context_version_minor: i32, opengl_profile: OpenGLProfile) void {
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, context_version_major);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, context_version_minor);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, @intFromEnum(opengl_profile));
}

pub fn pollEvents() void {
    c.glfwPollEvents();
}

pub fn getTime() f64 {
    return c.glfwGetTime();
}

pub const Window = struct {
    window: *c.GLFWwindow,

    const Self = @This();

    pub fn init(width: i32, height: i32, title: []const u8) !Self {
        const window = c.glfwCreateWindow(width, height, title.ptr, null, null) orelse {
            return error.GLFWCreateWindowError;
        };
        return .{ .window = window };
    }

    pub fn makeContextCurrent(self: Self) void {
        c.glfwMakeContextCurrent(self.window);
    }

    const FramebufferSizeCallback = *const fn (self: Self, width: i32, height: i32) void;

    pub fn setFramebufferSizeCallback(self: Self, comptime callback: FramebufferSizeCallback) FramebufferSizeCallback {
        _ = c.glfwSetFramebufferSizeCallback(
            self.window,
            struct {
                export fn func(window: ?*c.GLFWwindow, width: c_int, height: c_int) void {
                    callback(.{ .window = window.? }, width, height);
                }
            }.func,
        );
        return callback;
    }

    pub fn getKey(self: Self, key: Key) Action {
        return @enumFromInt(c.glfwGetKey(self.window, @intFromEnum(key)));
    }

    pub fn setShouldClose(self: Self, value: bool) void {
        c.glfwSetWindowShouldClose(self.window, @intFromBool(value));
    }

    pub fn shouldClose(self: Self) bool {
        return c.glfwWindowShouldClose(self.window) == 1;
    }
    pub fn swapBuffers(self: Self) void {
        c.glfwSwapBuffers(self.window);
    }
};
