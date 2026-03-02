#ifndef SKN_TYPES_H
#define SKN_TYPES_H

#include <stddef.h>
#include <stdint.h>
#include <stdbool.h>

// #define bool _Bool;

typedef _Float16 f16;
typedef float f32;
typedef double f64;
typedef __float128 f128;

typedef int8_t i8;
typedef int16_t i16;
typedef int32_t i32;
typedef int64_t i64;

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

typedef size_t usize;
typedef intptr_t isize;

#endif /* end of include guard: SKN_TYPES_H */
