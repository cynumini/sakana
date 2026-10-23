#pragma once

namespace skn {
using usize = __SIZE_TYPE__;
using isize = __PTRDIFF_TYPE__;

using i8 = __INT8_TYPE__;
using i16 = __INT16_TYPE__;
using i32 = __INT32_TYPE__;
using i64 = __INT64_TYPE__;

using u8 = __UINT8_TYPE__;
using u16 = __UINT16_TYPE__;
using u32 = __UINT32_TYPE__;
using u64 = __UINT64_TYPE__;

using f32 = float;
static_assert(sizeof(f32) == 4);

using f64 = double;
static_assert(sizeof(f64) == 8);

static constexpr i8 I8_MAX = __INT8_MAX__;
static constexpr i8 I8_MIN = -I8_MAX - 1;

static constexpr i16 I16_MAX = __INT16_MAX__;
static constexpr i16 I16_MIN = -I16_MAX - 1;

static constexpr i32 I32_MAX = __INT32_MAX__;
static constexpr i32 I32_MIN = -I32_MAX - 1;

static constexpr i64 I64_MAX = __INT64_MAX__;
static constexpr i64 I64_MIN = -I64_MAX - 1;

static constexpr isize ISIZE_MAX = __PTRDIFF_MAX__;
static constexpr isize ISIZE_MIN = -ISIZE_MAX - 1;

static constexpr u8 U8_MAX = __UINT8_MAX__;
static constexpr u8 U8_MIN = 0;

static constexpr u16 U16_MAX = __UINT16_MAX__;
static constexpr u16 U16_MIN = 0;

static constexpr u32 U32_MAX = __UINT32_MAX__;
static constexpr u32 U32_MIN = 0;

static constexpr u64 U64_MAX = __UINT64_MAX__;
static constexpr u64 U64_MIN = 0;

static constexpr usize USIZE_MAX = __SIZE_MAX__;
static constexpr usize USIZE_MIN = 0;
} // namespace skn
