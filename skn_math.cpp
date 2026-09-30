#pragma once

#include <math.h>

#include "skn.cpp"

template <typename T> struct Vector2 {
    T x;
    T y;

    // all
    void operator+=(Vector2 other) { x += other.x, y += other.y; }

    Vector2 operator+(T other) const { return {x + other, y + other}; }

    Vector2 operator+(Vector2 other) const { return {T(x + other.x), T(y + other.y)}; }
    Vector2 operator-(Vector2 other) const { return {T(x - other.x), T(y - other.y)}; }
    Vector2 operator*(Vector2 other) const { return {T(x * other.x), T(y * other.y)}; }

    T dot(Vector2 other) const { return (x * other.x) + (y * other.y); }

    // signed
    Vector2 operator-() const {
        static_assert(!__is_same(T, uint));
        return {-x, -y};
    }

    // float
    Vector2<float> operator/(float other) const { return {float(x) / other, float(y) / other}; }
    Vector2<float> operator*(float other) const { return {float(x) * other, float(y) * other}; }
    float length() const { return sqrtf((float(x) * float(x)) + (float(y) * float(y))); };
    Vector2<float> normalize() const {
        auto l = length();
        if (l > 0) return {float(x) / l, float(y) / l};
        return {float(x), float(y)};
    };
};

typedef Vector2<int> Vector2i;
typedef Vector2<uint> Vector2u;
typedef Vector2<float> Vector2f;

static Vector2f operator+(Vector2f a, Vector2i b) { return {a.x + float(b.x), a.y + float(b.y)}; }
static Vector2f operator-(Vector2i a, Vector2f b) { return {float(a.x) - b.x, float(a.y) - b.y}; }

struct Vector3f {
    float x;
    float y;
    float z;
};

template <typename T> struct Rectangle : Vector2<T> {
    T w;
    T h;

    static Rectangle fromVec(Vector2<T> position, Vector2<T> size) {
        return {position, size.x, size.y};
    }

    Vector2<T> position() const { return *(this); }
    Vector2<T> size() const { return {w, h}; }

    // float
    Rectangle<float> operator/(float value) const {
        return {position() / value, float(w) / value, float(h) / value};
    }

    void operator/=(float value) {
        static_assert(__is_same(T, float));
        this->x = this->x / value;
        this->y = this->y / value;
        w = w / value;
        h = h / value;
    }
};

typedef Rectangle<float> FRectangle;
typedef Rectangle<uint> URectangle;

static constexpr float deg2rad(float degrees) { return degrees * (M_PI / 180.0F); }

static constexpr float rad2deg(float radians) { return radians * (180.0F / M_PI); }

struct Matrix {
    float m[4][4];

    Matrix operator*(const Matrix &other) const {
        Matrix r = {};
        for (size_t y = 0; y < 4; y++)
            for (size_t x = 0; x < 4; x++)
                for (size_t i = 0; i < 4; i++) r.m[y][x] += m[y][i] * other.m[i][x];
        return r;
    }

    static Matrix scale(Vector3f v) {
        return {{{v.x, 0.0F, 0.0F, 0.0F},
                 {0.0F, v.y, 0.0F, 0.0F},
                 {0.0F, 0.0F, v.z, 0.0F},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    static Matrix translation(Vector3f v) {
        return {{{1.0F, 0.0F, 0.0F, v.x},
                 {0.0F, 1.0F, 0.0F, v.y},
                 {0.0F, 0.0F, 1.0F, v.z},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    static Matrix ortho(float left, float right, float bottom, float top, float near, float far) {
        float rl = right - left;
        float tb = top - bottom;
        float fn = far - near;

        return {{{2.0F / rl, 0.0F, 0.0F, -((right + left) / rl)},
                 {0.0F, 2.0F / tb, 0.0F, -((top + bottom) / tb)},
                 {0.0F, 0.0F, 1.0F / fn, -(near / fn)},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    // Pitch: rotate around X axis.
    static Matrix rotationX(float angle) {
        float c = cosf(angle);
        float s = sinf(angle);

        return {{{1.0F, 0.0F, 0.0F, 0.0F},
                 {0.0F, c, s, 0.0F},
                 {0.0F, -s, c, 0.0F},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    // Roll: rotate around Y axis.
    static Matrix rotationY(float angle) {
        float c = cosf(angle);
        float s = sinf(angle);

        return {{{c, 0.0F, -s, 0.0F},
                 {0.0F, 1.0F, 0.0F, 0.0F},
                 {s, 0.0F, c, 0.0F},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    // Yaw: rotate around Z axis.
    static Matrix rotationZ(float angle) {
        float c = cosf(angle);
        float s = sinf(angle);

        return {{{c, s, 0.0F, 0.0F},
                 {-s, c, 0.0F, 0.0F},
                 {0.0F, 0.0F, 1.0F, 0.0F},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }
};

struct Color {
    u8 r;
    u8 g;
    u8 b;
    u8 a;
};

static constexpr Color colorFromHex(u32 value) noexcept {
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
const Color GREEN = colorFromHex(0x00FF00FF);
const Color BLUE = colorFromHex(0x0000FFFF);
const Color YELLOW = colorFromHex(0xFFFF00FF);
const Color CYAN = colorFromHex(0x00FFFFFF);
const Color MAGENTA = colorFromHex(0xFF00FFFF);
const Color ORANGE = colorFromHex(0xFFA500FF);
const Color PURPLE = colorFromHex(0x800080FF);
const Color PINK = colorFromHex(0xFFC0CBFF);
const Color BROWN = colorFromHex(0xA52A2AFF);
const Color LIME = colorFromHex(0xBFFF00FF);
const Color NAVY = colorFromHex(0x000080FF);
const Color TEAL = colorFromHex(0x008080FF);

static bool checkCollisionAABB(FRectangle a, FRectangle b) {
    return a.x < (b.x + b.w) and b.x < (a.x + a.w) and a.y < (b.y + b.h) and b.y < (a.y + a.h);
};

struct Points4 {
    Vector2f v[4];
};

static Points4 calcRectPoints(FRectangle rect, float angle) {
    float half_w = rect.w * 0.5F;
    float half_h = rect.h * 0.5F;
    Vector2f center = {rect.x + half_w, rect.y + half_h};
    Points4 points = {{
        {-half_w, -half_h},
        {half_w, -half_h},
        {half_w, half_h},
        {-half_w, half_h},
    }};
    float c = cosf(angle);
    float s = sinf(angle);
    for (size_t i = 0; i < 4; i++) {
        float x = points.v[i].x;
        float y = points.v[i].y;
        points.v[i] = {(x * c) - (y * s), (x * s) + (y * c)};
        points.v[i] += center;
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

static bool checkCollisionSAT(FRectangle a, float a_angle, FRectangle b, float b_angle) {
    auto a_points = calcRectPoints(a, a_angle);
    auto b_points = calcRectPoints(b, b_angle);
    const Vector2f axes[4] = {a_points.v[1] - a_points.v[0], a_points.v[2] - a_points.v[1],
                              b_points.v[1] - b_points.v[0], b_points.v[2] - b_points.v[1]};

    for (size_t i = 0; i < 4; i++) {
        float a_values[4] = {a_points.v[0].dot(axes[i]), a_points.v[1].dot(axes[i]),
                             a_points.v[2].dot(axes[i]), a_points.v[3].dot(axes[i])};

        float b_values[4] = {b_points.v[0].dot(axes[i]), b_points.v[1].dot(axes[i]),
                             b_points.v[2].dot(axes[i]), b_points.v[3].dot(axes[i])};

        if (max(a_values) < min(b_values) or max(b_values) < min(a_values)) return false;
    }

    return true;
}
