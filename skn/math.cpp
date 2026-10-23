#pragma once

#include "types.cpp"

namespace skn {
namespace {
constexpr f64 PI = 3.14159265358979323846;
constexpr f32 PI_F = static_cast<f32>(PI);
constexpr f32 log10(f32 value) { return __builtin_log10f(value); }
constexpr f64 log10(f64 value) { return __builtin_log10(value); }
constexpr usize log10(usize value) {
    usize result = 0;
    while (value >= 10) {
        value /= 10;
        result++;
    }
    return result;
}
constexpr f32 sqrt(f32 value) { return __builtin_sqrtf(value); }
constexpr f64 sqrt(f64 value) { return __builtin_sqrt(value); }
constexpr f32 sin(f32 value) { return __builtin_sinf(value); }
constexpr f64 sin(f64 value) { return __builtin_sin(value); }
constexpr f32 cos(f32 value) { return __builtin_cosf(value); }
constexpr f64 cos(f64 value) { return __builtin_cos(value); }
constexpr f32 floor(f32 value) { return __builtin_floorf(value); }
constexpr f64 floor(f64 value) { return __builtin_floor(value); }
constexpr f32 round(f32 value) { return __builtin_roundf(value); }
constexpr f64 round(f64 value) { return __builtin_round(value); }
constexpr i32 abs(i32 value) { return __builtin_abs(value); }
constexpr f32 abs(f32 value) { return __builtin_fabsf(value); }
constexpr f64 abs(f64 value) { return __builtin_fabs(value); }

constexpr f32 deg2rad(f32 degrees) { return degrees * (skn::PI_F / 180.0F); }
constexpr f32 rad2deg(f32 radians) { return radians * (180.0F / skn::PI_F); }
} // namespace
} // namespace skn
