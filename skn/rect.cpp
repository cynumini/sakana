#pragma once

#include "skn/types.cpp"
#include "skn/vec.cpp"

namespace skn {
namespace {

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

    [[nodiscard]] constexpr Vec2 position() const { return {x, y}; }

    [[nodiscard]] constexpr Vec2 size() const { return {w, h}; }
};

bool checkCollisionAABB(Rect a, Rect b) {
    return skn::abs(a.x - b.x) * 2.0F < a.w + b.w && skn::abs(a.y - b.y) * 2.0F < a.h + b.h;
}

bool checkCollisionPointRect(Vec2 p, Rect r) {
    return skn::abs(p.x - r.x) * 2.0F < r.w && skn::abs(p.y - r.y) * 2.0F < r.h;
}

Array<Vec2, 4> calcRectPoints(Rect rect, f32 angle) {
    auto half = Vec2{rect.w, rect.h} * 0.5F;
    // Vec2 center = rect.position() + half;
    Vec2 center = {rect.x, rect.y};
    Array<Vec2, 4> points = {-half, {half.x, -half.y}, half, {-half.x, half.y}};
    f32 c = skn::cos(angle), s = skn::sin(angle);
    for (usize i = 0; i < 4; i++) {
        f32 x = points[i].x;
        f32 y = points[i].y;
        points[i] = Vec2{(x * c) - (y * s), (x * s) + (y * c)} + center;
    }
    return points;
}

template <typename T, usize N>  f32 max(Array<T, N> &values) {
    static_assert(N > 0);
    f32 best = values[0];
    for (const auto &value : values) best = value > best ? value : best;
    return best;
}

template <typename T, usize N>  T min(Array<T, N> &values) {
    static_assert(N > 0);
    f32 best = values[0];
    for (const auto &value : values) best = value < best ? value : best;
    return best;
}

 bool checkCollisionSAT(Rect a, f32 a_angle, Rect b, f32 b_angle) {
    auto a_points = calcRectPoints(a, a_angle);
    auto b_points = calcRectPoints(b, b_angle);
    Array<Vec2, 4> axes = {a_points[1] - a_points[0], a_points[2] - a_points[1],
                          b_points[1] - b_points[0], b_points[2] - b_points[1]};
    for (usize i = 0; i < 4; i++) {
        Array<f32, 4>  a_values = {a_points[0].dot(axes[i]), a_points[1].dot(axes[i]),
                           a_points[2].dot(axes[i]), a_points[3].dot(axes[i])};
        Array<f32, 4> b_values = {b_points[0].dot(axes[i]), b_points[1].dot(axes[i]),
                           b_points[2].dot(axes[i]), b_points[3].dot(axes[i])};
        if (max(a_values) < min(b_values) or max(b_values) < min(a_values)) return false;
    }
    return true;
}
} // namespace
} // namespace skn
