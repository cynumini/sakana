#pragma once

#include <math.h>

#include "skn.cpp"

template <typename T> struct Vector2 {
    T x;
    T y;

    Vector2 operator/(float other) const { return {T(float(x) / other), T(float(y) / other)}; }

    // old
    Vector2 operator-() const { return {-x, -y}; }
    Vector2 operator+(Vector2<int> other) const { return {x + T(other.x), y + T(other.y)}; }
    Vector2 operator-(Vector2 other) const { return {x - other.x, y - other.y}; }

    float length() const { return sqrtf((x * x) + (y * y)); };

    Vector2 normalize() {
        auto l = length();
        if (l > 0) return {x / l, y / l};
        return *this;
    };
};

typedef Vector2<int> ivec2;
typedef Vector2<uint> uvec2;
typedef Vector2<float> vec2;

template <typename T> struct Rectangle {
    T x;
    T y;
    T w;
    T h;

    Vector2<T> size() { return {w, h}; }

    Rectangle operator/(float value) const {
        return {
            T(float(x) / value),
            T(float(y) / value),
            T(float(w) / value),
            T(float(h) / value),
        };
    }
};

typedef Rectangle<float> Rect;
typedef Rectangle<uint> URect;

struct Color {
    u8 r;
    u8 g;
    u8 b;
    u8 a;
};

constexpr Color colorFromHex(u32 value) noexcept {
    return {
        .r = u8(value >> 24),
        .g = u8(value >> 16),
        .b = u8(value >> 8),
        .a = u8(value),
    };
}

const Color WHITE = colorFromHex(0xFFFFFFFF);
const Color BLACK = colorFromHex(0x000000FF);
const Color GRAY = colorFromHex(0x808080FF);
const Color RED = colorFromHex(0xFF0000FF);
