#pragma once

#include "skn.cpp"

struct ivec2 {
    int x;
    int y;
};

struct vec2 {
    f32 x;
    f32 y;
};

struct Rect {
    f32 x;
    f32 y;
    f32 w;
    f32 h;
};

struct Color {
    u8 r;
    u8 g;
    u8 b;
    u8 a;
};

const Color WHITE = {255, 255, 255, 255};
const Color GRAY = {128, 128, 128, 255};

struct FColor {
    f32 r;
    f32 g;
    f32 b;
    f32 a;
};

static FColor toFColor(Color color) {
    return {
        f32(color.r) / 255.0F,
        f32(color.g) / 255.0F,
        f32(color.b) / 255.0F,
        f32(color.a) / 255.0F,
    };
}
