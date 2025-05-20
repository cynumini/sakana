const std = @import("std");
pub const c = @import("c");

/// The caller owns the returned memory
pub fn getDefaultFontPath(allocator: std.mem.Allocator) ![]const u8 {
    return getFontPath(allocator, "");
}

/// The caller owns the returned memory
pub fn getFontPath(allocator: std.mem.Allocator, font_name: []const u8) ![]const u8 {
    const config = c.FcInitLoadConfigAndFonts() orelse return error.FcInitFailed;
    defer c.FcConfigDestroy(config);

    const pattern = c.FcNameParse(font_name.ptr) orelse return error.FontNameParseFailed;
    defer c.FcPatternDestroy(pattern);

    std.debug.assert(c.FcConfigSubstitute(config, pattern, c.FcMatchPattern) == c.FcTrue);

    c.FcDefaultSubstitute(pattern);

    var result: c.FcResult = undefined;

    const font = c.FcFontMatch(config, pattern, &result) orelse return error.FontMatchFailed;
    defer c.FcPatternDestroy(font);

    var file: [*c]c.FcChar8 = undefined;
    if (c.FcPatternGetString(font, c.FC_FILE, 0, &file) != c.FcResultMatch) return error.PatternGetStringFailed;
    return try allocator.dupe(u8, std.mem.span(file));
}
