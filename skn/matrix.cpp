#pragma once

#include "skn/types.cpp"
#include "skn/vec.cpp"

namespace skn {
namespace {
struct Mat4 {
    Array<Array<f32, 4>, 4> m;

    constexpr Mat4 operator*(const Mat4 &other) const {
        Mat4 r = {};
        for (usize y = 0; y < 4; y++)
            for (usize x = 0; x < 4; x++)
                for (usize i = 0; i < 4; i++) r.m[y][x] += m[y][i] * other.m[i][x];
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

    constexpr static Mat4 ortho(f32 left, f32 right, f32 bottom, f32 top, f32 near, f32 far) {
        f32 rl = right - left;
        f32 tb = top - bottom;
        f32 fn = far - near;

        return {{{2.0F / rl, 0.0F, 0.0F, -((right + left) / rl)},
                 {0.0F, 2.0F / tb, 0.0F, -((top + bottom) / tb)},
                 {0.0F, 0.0F, 1.0F / fn, -(near / fn)},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    constexpr static Vec4 unprojectOrtho(Vec3 ndc, f32 left, f32 right, f32 bottom, f32 top,
                                         f32 near, f32 far) {
        return {left + (ndc.x + 1.0F) * 0.5F * (right - left),
                bottom + (ndc.y + 1.0F) * 0.5F * (top - bottom), near + ndc.z * (far - near), 1};
    }

    // Pitch
    constexpr static Mat4 rotationX(f32 angle) {
        f32 c = skn::cos(angle);
        f32 s = skn::sin(angle);

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

    constexpr static Mat4 inverseIso45() {
        constexpr f32 s = 0.7071067811865475F;

        return {{{1.0F, 0.0F, 0.0F, 0.0F},
                 {0.0F, 0.5F, -s, 0.0F},
                 {0.0F, 0.5F, s, 0.0F},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    // Roll
    constexpr static Mat4 rotationY(f32 angle) {
        f32 c = skn::cos(angle);
        f32 s = skn::sin(angle);

        return {{{c, 0.0F, -s, 0.0F},
                 {0.0F, 1.0F, 0.0F, 0.0F},
                 {s, 0.0F, c, 0.0F},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }

    // Yaw
    constexpr static Mat4 rotationZ(f32 angle) {
        f32 c = skn::cos(angle);
        f32 s = skn::sin(angle);

        return {{{c, s, 0.0F, 0.0F},
                 {-s, c, 0.0F, 0.0F},
                 {0.0F, 0.0F, 1.0F, 0.0F},
                 {0.0F, 0.0F, 0.0F, 1.0F}}};
    }
};
} // namespace
} // namespace skn
