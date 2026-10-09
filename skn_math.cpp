#pragma once

#include <cassert>
#include <cmath>

#include "skn_types.cpp"

struct Vec3;

struct Vec2 {
    float x = 0;
    float y = 0;

    constexpr Vec2() = default;

    constexpr Vec2(float x, float y = 0) : x(x), y(y) {}

    constexpr Vec2(int x, int y = 0) : x(x), y(y) {}

    constexpr Vec2(Vec3 v);

    constexpr float &operator[](size_t i) {
        assert(i < 2);
        return (&x)[i];
    }

    constexpr const float &operator[](size_t i) const {
        assert(i < 2);
        return (&x)[i];
    }

    constexpr Vec2 operator*(Vec2 other) const { return {x * other.x, y * other.y}; }

    constexpr Vec2 operator+(Vec2 other) const { return {x + other.x, y + other.y}; }

    constexpr Vec2 operator-(Vec2 other) const { return {x - other.x, y - other.y}; }

    constexpr Vec2 &operator+=(const Vec2 &other) {
        x += other.x, y += other.y;
        return *this;
    }

    constexpr Vec2 operator*(float other) const { return {x * other, y * other}; }

    constexpr Vec2 operator+(float other) const { return {x + other, y + other}; }

    constexpr Vec2 operator/(float other) const { return {x / other, y / other}; }

    constexpr Vec2 operator-() const { return {-x, -y}; }

    constexpr float dot(const Vec2 other) const { return (x * other.x) + (y * other.y); }

    constexpr float length() const { return std::sqrt(x * x + y * y); };

    constexpr Vec2 normalize() const {
        auto l = length();
        if (l > 0) return {x / l, y / l};
        return {x, y};
    };

    constexpr Vec2 rotate(float rad) const {
        float c = cos(rad);
        float s = sin(rad);
        return {x * c - y * s, x * s + y * c};
    }
};

struct Vec3 {
    float x = 0;
    float y = 0;
    float z = 0;

    constexpr Vec3() = default;

    constexpr Vec3(float x, float y = 0, float z = 0) : x(x), y(y), z(z) {}

    constexpr Vec3(Vec2 v, float z = 0) : x(v.x), y(v.y), z(z) {}

    constexpr float &operator[](size_t i) {
        assert(i < 3);
        return (&x)[i];
    }

    constexpr const float &operator[](size_t i) const {
        assert(i < 3);
        return (&x)[i];
    }

    constexpr void operator+=(Vec3 other) { x += other.x, y += other.y, z += other.z; }

    constexpr Vec3 operator+(Vec3 other) const { return {x + other.x, y + other.y, z + other.z}; }

    constexpr Vec3 operator*(float other) const { return {x * other, y * other, z * other}; }

    constexpr Vec3 operator+(float other) const { return {x + other, y + other, z + other}; }

    constexpr Vec3 operator+(int other) const {
        return {x + float(other), y + float(other), z + float(other)};
    }

    constexpr Vec3 operator-(float other) const { return {x - other, y - other, z - other}; }

    constexpr Vec3 operator-(int other) const {
        return {x - float(other), y - float(other), z - float(other)};
    }

    constexpr Vec3 operator-() const { return {-x, -y, -z}; }

    constexpr Vec3 operator+(Vec2 other) const { return {x + other.x, y + other.y, z}; }

    constexpr Vec3 &operator+=(const Vec2 &other) {
        x += other.x, y += other.y;
        return *this;
    }

    constexpr Vec2 xy() { return {x, y}; }
};

constexpr Vec2::Vec2(Vec3 v) : x(v.x), y(v.y) {}

struct Vec3i {
    int x = 0;
    int y = 0;
    int z = 0;

    constexpr Vec3i() = default;

    constexpr Vec3i(int x, int y = 0, int z = 0) : x(x), y(y), z(z) {}

    constexpr Vec3i(Vec3 v) : x(int(v.x)), y(int(v.y)), z(int(v.z)) {}

    constexpr int &operator[](size_t i) {
        assert(i < 3);
        return (&x)[i];
    }

    constexpr const int &operator[](size_t i) const {
        assert(i < 3);
        return (&x)[i];
    }

    constexpr Vec3i operator+(Vec3i other) const {
        return {x + other.x, y + other.y, z + other.z};
    }

    constexpr Vec3 operator-(Vec3 other) const { return {x - other.x, y - other.y, z - other.z}; }

    constexpr Vec3 operator+(Vec3 other) const { return {x + other.x, y + other.y, z + other.z}; }

    constexpr Vec3 operator*(float other) const { return {x * other, y * other, z * other}; }
};

struct Rect {
    float x = 0;
    float y = 0;
    float w = 0;
    float h = 0;

    constexpr Rect() = default;

    constexpr Rect(float x, float y, float w, float h) : x(x), y(y), w(w), h(h) {}

    constexpr Rect(Vec2 pos, Vec2 size) : x(pos.x), y(pos.y), w(size.x), h(size.y) {}

    constexpr Rect operator/(float value) const {
        return {x / value, y / value, w / value, h / value};
    }

    constexpr Rect &operator/=(float value) {
        x /= value;
        y /= value;
        w /= value;
        h /= value;
        return *this;
    }

    constexpr Vec2 position() const { return {x, y}; }

    constexpr Vec2 size() const { return {w, h}; }
};

static constexpr float deg2rad(float degrees) { return degrees * (M_PIf / 180.0F); }

static constexpr float rad2deg(float radians) { return radians * (180.0F / M_PIf); }

struct Mat4 {
    float m[4][4];

    constexpr Mat4 operator*(const Mat4 &other) const {
        Mat4 r = {};
        for (size_t y = 0; y < 4; y++)
            for (size_t x = 0; x < 4; x++)
                for (size_t i = 0; i < 4; i++) r.m[y][x] += m[y][i] * other.m[i][x];
        return r;
    }

    constexpr static Mat4 scale(Vec3 v) {
        return {{{v.x, 0.0F, 0.0F, 0.0F},
                 {0.0F, v.y, 0.0F, 0.0F},
                 {0.0F, 0.0F, v.z, 0.0F},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    constexpr static Mat4 translation(Vec3 v) {
        return {{{1.0F, 0.0F, 0.0F, v.x},
                 {0.0F, 1.0F, 0.0F, v.y},
                 {0.0F, 0.0F, 1.0F, v.z},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    constexpr static Mat4 ortho(float left, float right, float bottom, float top, float near,
                                float far) {
        float rl = right - left;
        float tb = top - bottom;
        float fn = far - near;

        return {{{2.0F / rl, 0.0F, 0.0F, -((right + left) / rl)},
                 {0.0F, 2.0F / tb, 0.0F, -((top + bottom) / tb)},
                 {0.0F, 0.0F, 1.0F / fn, -(near / fn)},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    // Pitch
    constexpr static Mat4 rotationX(float angle) {
        float c = std::cos(angle);
        float s = std::sin(angle);

        return {{{1.0F, 0.0F, 0.0F, 0.0F},
                 {0.0F, c, s, 0.0F},
                 {0.0F, -s, c, 0.0F},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    constexpr static Mat4 iso45() {
        constexpr float s = 0.7071067811865475F;

        return {{{1.0F, 0.0F, 0.0F, 0.0F},
                 {0.0F, 1.0F, 1.0F, 0.0F},
                 {0.0F, -s, s, 0.0F},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    // Roll
    constexpr static Mat4 rotationY(float angle) {
        float c = std::cos(angle);
        float s = std::sin(angle);

        return {{{c, 0.0F, -s, 0.0F},
                 {0.0F, 1.0F, 0.0F, 0.0F},
                 {s, 0.0F, c, 0.0F},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    // Yaw
    constexpr static Mat4 rotationZ(float angle) {
        float c = std::cos(angle);
        float s = std::sin(angle);

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

    constexpr Color() = default;

    constexpr Color(u8 r, u8 g, u8 b, u8 a) : r(r), g(g), b(b), a(a) {}

    constexpr Color(u32 value)
        : r(u8(value >> 24)), g(u8(value >> 16)), b(u8(value >> 8)), a(u8(value)) {}
};

constexpr Color WHITE = 0xFFFFFFFF;
constexpr Color BLACK = 0x000000FF;
constexpr Color GRAY = 0x808080FF;
constexpr Color RED = 0xFF0000FF;
constexpr Color GREEN = 0x00FF00FF;
constexpr Color BLUE = 0x0000FFFF;
constexpr Color YELLOW = 0xFFFF00FF;
constexpr Color CYAN = 0x00FFFFFF;
constexpr Color MAGENTA = 0xFF00FFFF;
constexpr Color ORANGE = 0xFFA500FF;
constexpr Color PURPLE = 0x800080FF;
constexpr Color PINK = 0xFFC0CBFF;
constexpr Color BROWN = 0xA52A2AFF;
constexpr Color LIME = 0xBFFF00FF;
constexpr Color NAVY = 0x000080FF;
constexpr Color TEAL = 0x008080FF;

static bool checkCollisionAABB(Rect a, Rect b) {
    return std::abs(a.x - b.x) * 2.0F < a.w + b.w && std::abs(a.y - b.y) * 2.0F < a.h + b.h;
}

static bool checkCollisionPointRect(Vec2 p, Rect r) {
    return std::abs(p.x - r.x) * 2.0F < r.w && std::abs(p.y - r.y) * 2.0F < r.h;
}

struct Points4 {
    Vec2 v[4];
};

static Points4 calcRectPoints(Rect rect, float angle) {
    auto half = Vec2{rect.w, rect.h} * 0.5F;
    // Vec2 center = rect.position() + half;
    Vec2 center = {rect.x, rect.y};
    Points4 points = {-half, {half.x, -half.y}, half, {-half.x, half.y}};
    float c = std::cos(angle), s = std::sin(angle);
    for (size_t i = 0; i < 4; i++) {
        float x = points.v[i].x;
        float y = points.v[i].y;
        points.v[i] = Vec2{(x * c) - (y * s), (x * s) + (y * c)} + center;
    }
    return points;
}

template <typename T, size_t N> static float max(const T (&values)[N]) {
    static_assert(N > 0);
    float best = values[0];
    for (const auto &value : values) best = value > best ? value : best;
    return best;
}

template <typename T, size_t N> static T min(const T (&values)[N]) {
    static_assert(N > 0);
    float best = values[0];
    for (const auto &value : values) best = value < best ? value : best;
    return best;
}

static bool checkCollisionSAT(Rect a, float a_angle, Rect b, float b_angle) {
    auto a_points = calcRectPoints(a, a_angle);
    auto b_points = calcRectPoints(b, b_angle);
    const Vec2 axes[4] = {a_points.v[1] - a_points.v[0], a_points.v[2] - a_points.v[1],
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
