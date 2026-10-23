#pragma once

#include "skn/core.cpp"
#include "skn/types.cpp"

namespace skn {
namespace {
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
    constexpr Vec2(i32 x, i32 y) : x(static_cast<f32>(x)), y(static_cast<f32>(y)) {}
    constexpr Vec2(Vec2i v);
    constexpr Vec2(Vec3 v);

    constexpr f32 &operator[](usize i) {
        ASSERT(i < 2);
        return (&x)[i];
    }

    constexpr const f32 &operator[](usize i) const {
        ASSERT(i < 2);
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

    [[nodiscard]] constexpr f32 dot(const Vec2 other) const {
        return (x * other.x) + (y * other.y);
    }

    [[nodiscard]] constexpr f32 length() const { return skn::sqrt(x * x + y * y); };

    [[nodiscard]] constexpr Vec2 normalize() const {
        auto l = length();
        if (l > 0) return {x / l, y / l};
        return {x, y};
    };

    [[nodiscard]] constexpr Vec2 rotate(f32 rad) const {
        f32 c = skn::cos(rad);
        f32 s = skn::sin(rad);
        return {x * c - y * s, x * s + y * c};
    }
};

struct Vec2i {
    i32 x = 0;
    i32 y = 0;

    constexpr Vec2i() = default;
    constexpr Vec2i(i32 x, i32 y) : x(x), y(y) {}
    constexpr Vec2i(u32 x, u32 y) : x(static_cast<i32>(x)), y(static_cast<i32>(y)) {}
    constexpr Vec2i(f32 x, f32 y) : x(static_cast<i32>(x)), y(static_cast<i32>(y)) {}
    constexpr Vec2i(Vec2 v) : x(static_cast<i32>(v.x)), y(static_cast<i32>(v.y)) {}

    constexpr i32 &operator[](usize i) {
        ASSERT(i < 2);
        return (&x)[i];
    }

    constexpr const i32 &operator[](usize i) const {
        ASSERT(i < 2);
        return (&x)[i];
    }

    constexpr bool operator==(Vec2i other) const { return x == other.x and y == other.y; }
    constexpr bool operator!=(Vec2i other) const { return x != other.x or y != other.y; }

    constexpr Vec2i operator*(i32 other) const { return {x * other, y * other}; }

    constexpr Vec2i operator*(Vec2i other) const { return {x * other.x, y * other.y}; }
    constexpr Vec2i operator+(Vec2i other) const { return {x + other.x, y + other.y}; }

    constexpr Vec2 operator*(f32 other) const {
        return {static_cast<f32>(x) * other, other * static_cast<f32>(y)};
    }

    constexpr Vec2 operator+(Vec2 other) const {
        return {static_cast<f32>(x) + other.x, static_cast<f32>(y) + other.y};
    }
    constexpr Vec2 operator-(Vec2 other) const {
        return {static_cast<f32>(x) - other.x, static_cast<f32>(y) - other.y};
    }

    constexpr Vec3 operator+(Vec3 other) const;
};

constexpr Vec2::Vec2(Vec2i v) : x(static_cast<f32>(v.x)), y(static_cast<f32>(v.y)) {}

struct Vec3 {
    f32 x;
    f32 y;
    f32 z;

    constexpr Vec3() : x(0), y(0), z(0) {}
    constexpr Vec3(f32 x, f32 y, f32 z) : x(x), y(y), z(z) {}
    constexpr Vec3(Vec2 v, f32 z) : x(v.x), y(v.y), z(z) {}
    constexpr Vec3(Vec3i v);
    constexpr Vec3(Vec4 v);

    constexpr f32 &operator[](usize i) {
        ASSERT(i < 3);
        return (&x)[i];
    }

    constexpr const f32 &operator[](usize i) const {
        ASSERT(i < 3);
        return (&x)[i];
    }

    constexpr Vec3 operator-() const { return {-x, -y, -z}; }

    constexpr Vec3 operator*(f32 other) const { return {x * other, y * other, z * other}; }
    constexpr Vec3 operator+(f32 other) const { return {x + other, y + other, z + other}; }
    constexpr Vec3 operator+(i32 other) const { return operator+(static_cast<f32>(other)); }
    constexpr Vec3 operator-(f32 other) const { return {x - other, y - other, z - other}; }
    constexpr Vec3 operator-(i32 other) const { return operator-(static_cast<f32>(other)); }

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

    [[nodiscard]] constexpr Vec3 rotateZ(f32 rad) const {
        const f32 c = skn::cos(rad);
        const f32 s = skn::sin(rad);
        return {x * c - y * s, x * s + y * c, z};
    }

    [[nodiscard]] constexpr f32 length() const { return skn::sqrt(x * x + y * y + z * z); }

    [[nodiscard]] constexpr Vec3 normalize() const {
        auto l = length();
        if (l > 0) return {x / l, y / l, z / l};
        return {x, y, z};
    }

    [[nodiscard]] constexpr Vec3 floor() const {
        return {skn::floor(x), skn::floor(y), skn::floor(z)};
    }
    [[nodiscard]] constexpr Vec3 round() const {
        return {skn::round(x), skn::round(y), skn::round(z)};
    }
};

constexpr Vec2::Vec2(Vec3 v) : x(v.x), y(v.y) {}
constexpr Vec3 Vec2i::operator+(Vec3 other) const {
    return {static_cast<f32>(x) + other.x, static_cast<f32>(y) + other.y, other.z};
}

struct Vec3i {
    i32 x = 0;
    i32 y = 0;
    i32 z = 0;

    constexpr Vec3i() = default;
    constexpr Vec3i(i32 x, i32 y, i32 z) : x(x), y(y), z(z) {}
    constexpr Vec3i(Vec2i v, i32 z) : x(v.x), y(v.y), z(z) {}
    constexpr Vec3i(Vec3 v)
        : x(static_cast<i32>(v.x)), y(static_cast<i32>(v.y)), z(static_cast<i32>(v.z)) {}

    constexpr i32 &operator[](usize i) {
        ASSERT(i < 3);
        return (&x)[i];
    }

    constexpr const i32 &operator[](usize i) const {
        ASSERT(i < 3);
        return (&x)[i];
    }

    constexpr Vec3i operator+(Vec3i other) const {
        return {x + other.x, y + other.y, z + other.z};
    }

    constexpr bool operator==(Vec3i other) const {
        return x == other.x and y == other.y and z == other.z;
    }

    constexpr Vec3 operator*(f32 other) const {
        return {static_cast<f32>(x) * other, static_cast<f32>(y) * other,
                static_cast<f32>(z) * other};
    }

    constexpr Vec3 operator+(Vec3 other) const {
        return {static_cast<f32>(x) + other.x, static_cast<f32>(y) + other.y,
                static_cast<f32>(z) + other.z};
    }
    constexpr Vec3 operator-(Vec3 other) const {
        return {static_cast<f32>(x) - other.x, static_cast<f32>(y) - other.y,
                static_cast<f32>(z) - other.z};
    }
};

constexpr Vec3::Vec3(Vec3i v)
    : x(static_cast<f32>(v.x)), y(static_cast<f32>(v.y)), z(static_cast<f32>(v.z)) {}

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
} // namespace
} // namespace skn
