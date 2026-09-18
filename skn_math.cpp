#pragma once

#include <math.h>

#include "skn.cpp"

template <typename T> struct Vector2 {
    T x;
    T y;

    void operator+=(Vector2 other) { x += other.x, y += other.y; }

    Vector2 operator-() const { return {-x, -y}; }
    Vector2 operator/(float other) const { return {T(float(x) / other), T(float(y) / other)}; }
    Vector2 operator*(float other) const { return {T(float(x) * other), T(float(y) * other)}; }
    Vector2 operator+(Vector2 other) const { return {x + other.x, y + other.y}; }
    Vector2 operator-(Vector2 other) const { return {x - other.x, y - other.y}; }
    Vector2 operator*(Vector2 other) const { return {x * other.x, y * other.y}; }

    T dot(Vector2 other) const { return (x * other.x) + (y * other.y); }

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

static vec2 operator+(vec2 a, ivec2 b) { return {a.x + float(b.x), a.y + float(b.y)}; }
static vec2 operator-(ivec2 a, vec2 b) { return {float(a.x) - b.x, float(a.y) - b.y}; }

template <typename T> struct Rectangle {
    T x;
    T y;
    T w;
    T h;

    static Rectangle fromVec(Vector2<T> position, Vector2<T> size) {
        return {position.x, position.y, size.x, size.y};
    }

    Vector2<T> position() { return {x, y}; }
    Vector2<T> size() { return {w, h}; }

    Rectangle operator/(float value) const {
        return {
            T(float(x) / value),
            T(float(y) / value),
            T(float(w) / value),
            T(float(h) / value),
        };
    }

    void operator/=(float value) {
        x = T(float(x) / value);
        y = T(float(y) / value);
        w = T(float(w) / value);
        h = T(float(h) / value);
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

static bool checkCollisionAABB(Rect a, Rect b) {
    return a.x < (b.x + b.w) and b.x < (a.x + a.w) and a.y < (b.y + b.h) and b.y < (a.y + a.h);
};

union Points4 {
    vec2 v[4];
    struct {
        vec2 p0;
        vec2 p1;
        vec2 p2;
        vec2 p3;
    };
};

static Points4 calcRectPoints(Rect rect, float angle) {
    float half_w = rect.w / 2.0F;
    float half_h = rect.h / 2.0F;
    Points4 points = {{
        {-half_w, -half_h},
        {half_w, -half_h},
        {half_w, half_h},
        {-half_w, half_h},
    }};
    for (size_t i = 0; i < 4; i++) {
        points.v[i] = {(points.v[i].x * cosf(angle)) - (points.v[i].y * sinf(angle)),
                       (points.v[i].x * sinf(angle)) + (points.v[i].y * cosf(angle))};
        points.v[i] += vec2{rect.x, rect.y};
    }
    return points;
}

static float max(const float values[4]) {
    float value = values[0];
    for (size_t i = 1; i < 4; i++) value = values[i] > value ? values[i] : value;
    return value;
}

static float min(const float values[4]) {
    float value = values[0];
    for (size_t i = 1; i < 4; i++) value = values[i] < value ? values[i] : value;
    return value;
}

static bool checkCollisionSAT(Rect a, float a_angle, Rect b, float b_angle) {
    auto a_points = calcRectPoints(a, a_angle);
    auto b_points = calcRectPoints(b, b_angle);
    const vec2 axes[4] = {a_points.p1 - a_points.p0, a_points.p2 - a_points.p1,
                          b_points.p1 - b_points.p0, b_points.p2 - b_points.p1};

    for (size_t i = 0; i < 4; i++) {
        float a_values[4] = {a_points.p0.dot(axes[i]), a_points.p1.dot(axes[i]),
                             a_points.p2.dot(axes[i]), a_points.p3.dot(axes[i])};

        float b_values[4] = {b_points.p0.dot(axes[i]), b_points.p1.dot(axes[i]),
                             b_points.p2.dot(axes[i]), b_points.p3.dot(axes[i])};

        if (max(a_values) < min(b_values) or max(b_values) < min(a_values)) return false;
    }

    return true;
}
