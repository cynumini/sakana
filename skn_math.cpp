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
