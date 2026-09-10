#pragma once

#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef int8_t i8;
typedef int16_t i16;
typedef int32_t i32;
typedef int64_t i64;

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

typedef float f32;
static_assert(sizeof(f32) == 4);
typedef double f64;
static_assert(sizeof(f64) == 8);

typedef unsigned int uint;
typedef size_t usize;

struct Location {
    const char *file;
    usize line;
};

static Location getLocation(const char *file = __builtin_FILE(), usize line = __builtin_LINE()) {
    return Location{file, line};
}

// Allocator interface
struct Allocator {
    void *(*malloc)(Allocator *, usize, Location);
    void (*free)(Allocator *, void *);
    void *(*calloc)(Allocator *, usize, usize, Location);
    void *(*realloc)(Allocator *, void *, usize, Location);
};

static void *malloc(Allocator *allocator, usize size, Location loc = getLocation()) {
    return allocator->malloc(allocator, size, loc);
}
static void free(Allocator *allocator, void *ptr) { allocator->free(allocator, ptr); }
static void *calloc(Allocator *allocator, usize len, usize size, Location loc = getLocation()) {
    return allocator->calloc(allocator, len, size, loc);
}
static void *realloc(Allocator *allocator, void *ptr, usize size, Location loc = getLocation()) {
    return allocator->realloc(allocator, ptr, size, loc);
}

// C allocator
static void *cMalloc([[maybe_unused]] Allocator *allocator, usize size,
                     [[maybe_unused]] Location loc) {
    return malloc(size);
}
static void cFree([[maybe_unused]] Allocator *allocator, void *mem) { free(mem); }
static void *cCalloc([[maybe_unused]] Allocator *allocator, usize len, usize size,
                     [[maybe_unused]] Location loc) {
    return calloc(len, size);
}
static void *cRealloc([[maybe_unused]] Allocator *allocator, void *mem, usize size,
                      [[maybe_unused]] Location loc) {
    return realloc(mem, size);
}
static Allocator c_allocator = {
    .malloc = cMalloc,
    .free = cFree,
    .calloc = cCalloc,
    .realloc = cRealloc,
};

// Slice
template <typename T> struct Slice {
    T *ptr;
    usize len;
};

template <typename T>
Slice<T> sliceAlloc(Allocator *allocator, usize len, bool zero = true,
                    Location loc = getLocation()) {
    if (len == 0) return {};
    if (zero) return {(T *)calloc(allocator, len, sizeof(T), loc), len};
    return {(T *)malloc(allocator, sizeof(T) * len, loc), len};
}

template <typename T>
Slice<T> sliceRealloc(Allocator *allocator, Slice<T> slice, usize len, bool zero = true,
                      Location loc = getLocation()) {
    if (slice.len == 0) return sliceAlloc<T>(allocator, len, zero, loc);
    slice.ptr = (T *)realloc(allocator, slice.ptr, len * sizeof(T), loc);
    assert(slice.ptr);
    if (zero and len > slice.len) memset(slice.ptr + slice.len, 0, (len - slice.len) * sizeof(T));
    slice.len = len;
    return slice;
}

template <typename T> void sliceFree(Allocator *allocator, Slice<T> slice) {
    free(allocator, slice.ptr);
}

// Dynamic
template <typename T> struct Dynamic {
    Slice<T> items;
    uint capacity;
};

template <typename T>
void append(Allocator *allocator, Dynamic<T> *array, T value, Location loc = getLocation()) {
    if (array->items.len == array->capacity) {
        array->capacity = array->capacity == 0 ? 1 : array->capacity * 2;
        auto old_len = array->items.len;
        array->items = sliceRealloc(allocator, array->items, array->capacity, false, loc);
        array->items.len = old_len;
    }
    array->items.ptr[array->items.len++] = value;
}

template <typename T> void dynamicDeinit(Allocator *allocator, Dynamic<T> array) {
    sliceFree(allocator, array.items);
}

// Debug Allocator
struct AllocationLocation {
    Location location;
    void *mem;
};

struct DebugAllocator {
    Allocator allocator;
    Allocator *parent;
    Dynamic<AllocationLocation> locations;
};

static void *debugAllocatorMalloc(Allocator *allocator, usize size, Location loc) {
    auto *da = (DebugAllocator *)allocator;
    void *mem = malloc(da->parent, size, loc);
    assert(mem);
    append(da->parent, &da->locations, {loc, mem});
    return mem;
}

static void debugAllocatorFree(Allocator *allocator, void *mem) {
    auto *da = (DebugAllocator *)allocator;
    for (uint i = 0; i < da->locations.items.len; i++) {
        if (da->locations.items.ptr[i].mem == mem) {
            da->locations.items.ptr[i].mem = 0;
            break;
        }
    }
    free(da->parent, mem);
}

static void *debugAllocatorCalloc(Allocator *allocator, usize len, usize size, Location loc) {
    auto *da = (DebugAllocator *)allocator;
    void *ptr = calloc(da->parent, len, size, loc);
    assert(ptr);
    append(da->parent, &da->locations, {loc, ptr});
    return ptr;
}

static void *debugAllocatorRealloc(Allocator *allocator, void *mem, usize size, Location loc) {
    auto *da = (DebugAllocator *)allocator;
    void *new_mem = realloc(da->parent, mem, size, loc);
    assert(new_mem);
    for (uint i = 0; i < da->locations.items.len; i++) {
        if (da->locations.items.ptr[i].mem == mem) {
            da->locations.items.ptr[i] = {loc, new_mem};
            break;
        }
    }
    return new_mem;
}

static DebugAllocator debugAllocatorInit(Allocator *parent) {
    return {
        .allocator = {.malloc = debugAllocatorMalloc,
                      .free = debugAllocatorFree,
                      .calloc = debugAllocatorCalloc,
                      .realloc = debugAllocatorRealloc},
        .parent = parent,
        .locations = {},
    };
}

static void debugAllocatorDeinit(DebugAllocator *da) {
    for (usize i = 0; i < da->locations.items.len; i++) {
        if (da->locations.items.ptr[i].mem != 0) {
            printf("%s:%zu:0: memory leak\n", da->locations.items.ptr[i].location.file,
                   da->locations.items.ptr[i].location.line);
        }
    }
    dynamicDeinit(da->parent, da->locations);
}

template <typename T>
static void debugAllocatorOwn(DebugAllocator *da, T *mem, Location loc = getLocation()) {
    assert(mem);
    append(da->parent, &da->locations, {loc, mem});
}
