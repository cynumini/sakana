#pragma once

#include <cassert>
#include <cmath>

#include "skn/types.cpp"

struct Vec2;
struct Vec2i;
struct Vec3;
struct Vec3i;
struct Vec4;

struct Vec2 {
    f32 x = 0;
    f32 y = 0;

    constexpr Vec2() = default;
    constexpr Vec2(f32 x, f32 y) : x(x), y(y) {}
    constexpr Vec2(int x, int y) : x(x), y(y) {}
    constexpr Vec2(Vec2i v);
    constexpr Vec2(Vec3 v);

    constexpr f32 &operator[](size_t i) {
        assert(i < 2);
        return (&x)[i];
    }

    constexpr const f32 &operator[](size_t i) const {
        assert(i < 2);
        return (&x)[i];
    }

    constexpr Vec2 operator-() const { return {-x, -y}; }

    constexpr Vec2 operator*(f32 other) const { return {x * other, y * other}; }
    constexpr Vec2 operator+(f32 other) const { return {x + other, y + other}; }
    constexpr Vec2 operator/(f32 other) const { return {x / other, y / other}; }

    constexpr Vec2 operator*(Vec2 other) const { return {x * other.x, y * other.y}; }
    constexpr Vec2 operator+(Vec2 other) const { return {x + other.x, y + other.y}; }
    constexpr Vec2 operator-(Vec2 other) const { return {x - other.x, y - other.y}; }

    constexpr Vec2 &operator+=(const Vec2 &other) {
        x += other.x, y += other.y;
        return *this;
    }

    constexpr f32 dot(const Vec2 other) const { return (x * other.x) + (y * other.y); }

    constexpr f32 length() const { return std::sqrt(x * x + y * y); };

    constexpr Vec2 normalize() const {
        auto l = length();
        if (l > 0) return {x / l, y / l};
        return {x, y};
    };

    constexpr Vec2 rotate(f32 rad) const {
        f32 c = cos(rad);
        f32 s = sin(rad);
        return {x * c - y * s, x * s + y * c};
    }
};

struct Vec2i {
    int x = 0;
    int y = 0;

    constexpr Vec2i() = default;
    constexpr Vec2i(int x, int y) : x(x), y(y) {}
    constexpr Vec2i(uint x, uint y) : x(x), y(y) {}
    constexpr Vec2i(f32 x, f32 y) : x(int(x)), y(int(y)) {}
    constexpr Vec2i(Vec2 v) : x(int(v.x)), y(int(v.y)) {}

    constexpr int &operator[](size_t i) {
        assert(i < 2);
        return (&x)[i];
    }

    constexpr const int &operator[](size_t i) const {
        assert(i < 2);
        return (&x)[i];
    }

    constexpr bool operator==(Vec2i other) { return x == other.x and y == other.y; }
    constexpr bool operator!=(Vec2i other) { return x != other.x or y != other.y; }

    constexpr Vec2i operator*(int other) const { return {x * other, y * other}; }

    constexpr Vec2i operator*(Vec2i other) const { return {x * other.x, y * other.y}; }
    constexpr Vec2i operator+(Vec2i other) const { return {x + other.x, y + other.y}; }

    constexpr Vec2 operator*(f32 other) const { return {x * other, y * other}; }

    constexpr Vec2 operator+(Vec2 other) const { return {x + other.x, y + other.y}; }
    constexpr Vec2 operator-(Vec2 other) const { return {x - other.x, y - other.y}; }

    constexpr Vec3 operator+(Vec3 other) const;
};

constexpr Vec2::Vec2(Vec2i v) : x(v.x), y(v.y) {}

struct Vec3 {
    f32 x;
    f32 y;
    f32 z;

    constexpr Vec3() : x(0), y(0), z(0) {}
    constexpr Vec3(f32 x, f32 y, f32 z) : x(x), y(y), z(z) {}
    constexpr Vec3(Vec2 v, f32 z) : x(v.x), y(v.y), z(z) {}
    constexpr Vec3(Vec3i v);
    constexpr Vec3(Vec4 v);

    constexpr f32 &operator[](size_t i) {
        assert(i < 3);
        return (&x)[i];
    }

    constexpr const f32 &operator[](size_t i) const {
        assert(i < 3);
        return (&x)[i];
    }

    constexpr Vec3 operator-() const { return {-x, -y, -z}; }

    constexpr Vec3 operator*(f32 other) const { return {x * other, y * other, z * other}; }
    constexpr Vec3 operator+(f32 other) const { return {x + other, y + other, z + other}; }
    constexpr Vec3 operator+(int other) const { return operator+(f32(other)); }
    constexpr Vec3 operator-(f32 other) const { return {x - other, y - other, z - other}; }
    constexpr Vec3 operator-(int other) const { return operator-(f32(other)); }

    constexpr Vec3 operator/(Vec3 other) const { return {x / other.x, y / other.y, z / other.z}; }
    constexpr Vec3 operator+(Vec3 other) const { return {x + other.x, y + other.y, z + other.z}; }
    constexpr Vec3 operator-(Vec3 other) const { return {x - other.x, y - other.y, z - other.z}; }

    constexpr Vec3 operator+(Vec2 other) const { return {x + other.x, y + other.y, z}; }

    constexpr Vec3 &operator+=(const Vec3 &other) {
        x += other.x, y += other.y, z += other.z;
        return *this;
    }

    constexpr Vec3 &operator-=(const Vec3 &other) {
        x -= other.x, y -= other.y, z -= other.z;
        return *this;
    }

    constexpr Vec3 &operator+=(const Vec2 &other) {
        x += other.x, y += other.y;
        return *this;
    }

    constexpr Vec3 rotateZ(f32 rad) const {
        const f32 c = cos(rad);
        const f32 s = sin(rad);
        return {x * c - y * s, x * s + y * c, z};
    }

    constexpr f32 length() const { return std::sqrt(x * x + y * y + z * z); }

    constexpr Vec3 normalize() const {
        auto l = length();
        if (l > 0) return {x / l, y / l, z / l};
        return {x, y, z};
    }

    constexpr Vec3 floor() { return {std::floor(x), std::floor(y), std::floor(z)}; }
    constexpr Vec3 round() { return {std::round(x), std::round(y), std::round(z)}; }
};

constexpr Vec2::Vec2(Vec3 v) : x(v.x), y(v.y) {}
constexpr Vec3 Vec2i::operator+(Vec3 other) const { return {x + other.x, y + other.y, other.z}; }

struct Vec3i {
    int x = 0;
    int y = 0;
    int z = 0;

    constexpr Vec3i() = default;
    constexpr Vec3i(int x, int y, int z) : x(x), y(y), z(z) {}
    constexpr Vec3i(Vec2i v, int z) : x(v.x), y(v.y), z(z) {}
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

    constexpr bool operator==(Vec3i other) const {
        return x == other.x and y == other.y and z == other.z;
    }

    constexpr Vec3 operator*(f32 other) const { return {x * other, y * other, z * other}; }

    constexpr Vec3 operator+(Vec3 other) const { return {x + other.x, y + other.y, z + other.z}; }
    constexpr Vec3 operator-(Vec3 other) const { return {x - other.x, y - other.y, z - other.z}; }
};

constexpr Vec3::Vec3(Vec3i v) : x(f32(v.x)), y(f32(v.y)), z(f32(v.z)) {}

struct Vec4 {
    f32 x = 0;
    f32 y = 0;
    f32 z = 0;
    f32 w = 0;

    constexpr Vec4() = default;
    constexpr Vec4(f32 x, f32 y, f32 z, f32 w) : x(x), y(y), z(z), w(w) {};
    constexpr Vec4(Vec3 v, f32 w) : x(v.x), y(v.y), z(v.z), w(w) {};
};

constexpr Vec3::Vec3(Vec4 v) : x(v.x), y(v.y), z(v.z) {};

struct Rect {
    f32 x = 0;
    f32 y = 0;
    f32 w = 0;
    f32 h = 0;

    constexpr Rect() = default;

    constexpr Rect(f32 x, f32 y, f32 w, f32 h) : x(x), y(y), w(w), h(h) {}

    constexpr Rect(Vec2 pos, Vec2 size) : x(pos.x), y(pos.y), w(size.x), h(size.y) {}

    constexpr Rect operator/(f32 value) const {
        return {x / value, y / value, w / value, h / value};
    }

    constexpr Rect &operator/=(f32 value) {
        x /= value;
        y /= value;
        w /= value;
        h /= value;
        return *this;
    }

    constexpr Vec2 position() const { return {x, y}; }

    constexpr Vec2 size() const { return {w, h}; }
};

static constexpr f32 deg2rad(f32 degrees) { return degrees * (M_PIf / 180.0F); }

static constexpr f32 rad2deg(f32 radians) { return radians * (180.0F / M_PIf); }

struct Mat4 {
    f32 m[4][4];

    constexpr Mat4 operator*(const Mat4 &other) const {
        Mat4 r = {};
        for (size_t y = 0; y < 4; y++)
            for (size_t x = 0; x < 4; x++)
                for (size_t i = 0; i < 4; i++) r.m[y][x] += m[y][i] * other.m[i][x];
        return r;
    }

    constexpr Vec4 operator*(const Vec4 &v) const {
        return {m[0][0] * v.x + m[0][1] * v.y + m[0][2] * v.z + m[0][3] * v.w,
                m[1][0] * v.x + m[1][1] * v.y + m[1][2] * v.z + m[1][3] * v.w,
                m[2][0] * v.x + m[2][1] * v.y + m[2][2] * v.z + m[2][3] * v.w,
                m[3][0] * v.x + m[3][1] * v.y + m[3][2] * v.z + m[3][3] * v.w};
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

    constexpr static Mat4 ortho(f32 left, f32 right, f32 bottom, f32 top, f32 near,
                                f32 far) {
        f32 rl = right - left;
        f32 tb = top - bottom;
        f32 fn = far - near;

        return {{{2.0F / rl, 0.0F, 0.0F, -((right + left) / rl)},
                 {0.0F, 2.0F / tb, 0.0F, -((top + bottom) / tb)},
                 {0.0F, 0.0F, 1.0F / fn, -(near / fn)},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    constexpr static Vec4 unprojectOrtho(Vec3 ndc, f32 left, f32 right, f32 bottom,
                                         f32 top, f32 near, f32 far) {
        return {left + (ndc.x + 1.0F) * 0.5F * (right - left),
                bottom + (ndc.y + 1.0F) * 0.5F * (top - bottom), near + ndc.z * (far - near), 1};
    }

    // Pitch
    constexpr static Mat4 rotationX(f32 angle) {
        f32 c = std::cos(angle);
        f32 s = std::sin(angle);

        return {{{1.0F, 0.0F, 0.0F, 0.0F},
                 {0.0F, c, s, 0.0F},
                 {0.0F, -s, c, 0.0F},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    constexpr static Mat4 iso45() {
        constexpr f32 s = 0.7071067811865475F;

        return {{{1.0F, 0.0F, 0.0F, 0.0F},
                 {0.0F, 1.0F, 1.0F, 0.0F},
                 {0.0F, -s, s, 0.0F},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    // constexpr static Mat4 inverseIso45() {
    //     constexpr f32 s = 0.7071067811865475F;

    //     return {{{1.0F, 0.0F, 0.0F, 0.0F},
    //              {0.0F, 0.5F, -s, 0.0F},
    //              {0.0F, 0.5F, s, 0.0F},
    //              {0.0F, 0.0F, 0.0F, 1.0F}}};
    // }

    constexpr static Mat4 inverseIso45() {
        constexpr f32 s = 0.7071067811865475F;

        return {{{1.0F, 0.0F, 0.0F, 0.0F},
                 {0.0F, 0.5F, -s, 0.0F},
                 {0.0F, 0.5F, s, 0.0F},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    // Roll
    constexpr static Mat4 rotationY(f32 angle) {
        f32 c = std::cos(angle);
        f32 s = std::sin(angle);

        return {{{c, 0.0F, -s, 0.0F},
                 {0.0F, 1.0F, 0.0F, 0.0F},
                 {s, 0.0F, c, 0.0F},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    // Yaw
    constexpr static Mat4 rotationZ(f32 angle) {
        f32 c = std::cos(angle);
        f32 s = std::sin(angle);

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

static Points4 calcRectPoints(Rect rect, f32 angle) {
    auto half = Vec2{rect.w, rect.h} * 0.5F;
    // Vec2 center = rect.position() + half;
    Vec2 center = {rect.x, rect.y};
    Points4 points = {-half, {half.x, -half.y}, half, {-half.x, half.y}};
    f32 c = std::cos(angle), s = std::sin(angle);
    for (size_t i = 0; i < 4; i++) {
        f32 x = points.v[i].x;
        f32 y = points.v[i].y;
        points.v[i] = Vec2{(x * c) - (y * s), (x * s) + (y * c)} + center;
    }
    return points;
}

template <typename T, size_t N> static f32 max(const T (&values)[N]) {
    static_assert(N > 0);
    f32 best = values[0];
    for (const auto &value : values) best = value > best ? value : best;
    return best;
}

template <typename T, size_t N> static T min(const T (&values)[N]) {
    static_assert(N > 0);
    f32 best = values[0];
    for (const auto &value : values) best = value < best ? value : best;
    return best;
}

static bool checkCollisionSAT(Rect a, f32 a_angle, Rect b, f32 b_angle) {
    auto a_points = calcRectPoints(a, a_angle);
    auto b_points = calcRectPoints(b, b_angle);
    const Vec2 axes[4] = {a_points.v[1] - a_points.v[0], a_points.v[2] - a_points.v[1],
                          b_points.v[1] - b_points.v[0], b_points.v[2] - b_points.v[1]};
    for (size_t i = 0; i < 4; i++) {
        f32 a_values[4] = {a_points.v[0].dot(axes[i]), a_points.v[1].dot(axes[i]),
                             a_points.v[2].dot(axes[i]), a_points.v[3].dot(axes[i])};
        f32 b_values[4] = {b_points.v[0].dot(axes[i]), b_points.v[1].dot(axes[i]),
                             b_points.v[2].dot(axes[i]), b_points.v[3].dot(axes[i])};
        if (max(a_values) < min(b_values) or max(b_values) < min(a_values)) return false;
    }
    return true;
}
