#pragma once

#include <math.h>

#include "skn.cpp"

struct ivec2 {
    int x;
    int y;

    ivec2 operator/(float other) const { return {int(float(x) / other), int(float(y) / other)}; }
};

struct vec2 {
    float x;
    float y;

    vec2 operator-() const { return {-x, -y}; }
    vec2 operator+(ivec2 other) const { return {x + float(other.x), y + float(other.y)}; }
    vec2 operator-(vec2 other) const { return {x - other.x, y - other.y}; }
    vec2 operator/(float other) const { return {x / other, y / other}; }

    float length() const { return sqrtf((x * x) + (y * y)); };

    vec2 normalize() {
        auto l = length();
        if (l > 0) return {x / l, y / l};
        return *this;
    };
};

struct Rect {
    float x;
    float y;
    float w;
    float h;

    vec2 size() { return {w, h}; }

    Rect operator/(float value) const { return {x / value, y / value, w / value, h / value}; }
};

struct URect {
    uint x;
    uint y;
    uint w;
    uint h;
};

struct Color {
    u8 r;
    u8 g;
    u8 b;
    u8 a;
};

const Color WHITE = {255, 255, 255, 255};
const Color BLACK = {0, 0, 0, 255};
const Color GRAY = {128, 128, 128, 255};
const Color RED = {255, 0, 0, 255};

struct FColor {
    float r;
    float g;
    float b;
    float a;
};

static FColor toFColor(Color color) {
    return {
        float(color.r) / 255.0F,
        float(color.g) / 255.0F,
        float(color.b) / 255.0F,
        float(color.a) / 255.0F,
    };
}
