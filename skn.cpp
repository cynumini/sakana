#pragma once

#include <assert.h>
#include <stdarg.h>
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
typedef ptrdiff_t isize;

#define KB(value) ((value) * 1024UL)
#define MB(value) (KB(value) * 1024UL)

template <typename T> T min(T a, T b) { return a < b ? a : b; }
template <typename T> T max(T a, T b) { return a > b ? a : b; }

struct Location {
    const char *file;
    usize line;
};

static Location getLocation(const char *file = __builtin_FILE(), usize line = __builtin_LINE()) {
    return Location{file, line};
}

// Slice
template <typename T> struct Slice {
    T *ptr;
    usize len;
    T &operator[](usize index) { return ptr[index]; }
    T *begin() { return ptr; }
    T *end() { return ptr + len; }
};

template <typename T> static Slice<T> sliceFromZeroSentinelArray(T *array) {
    usize len = 0;
    while (array[len] != 0) len++;
    return {array, len};
}

// Array
template <typename T, usize N> struct Array {
    T data[N];
    static constexpr usize len = N;
    T &operator[](usize index) { return data[index]; }
    const T &operator[](usize index) const { return data[index]; }
    T *begin() { return data; }
    T *end() { return data + len; }
};

#define ARRAY_LEN(array) (sizeof(array) / sizeof((array)[0]))

// Allocator interface
struct Allocator {
    u8 *(*alloc)(Allocator *, usize len, usize alignment, Location loc);
    u8 *(*realloc)(Allocator *, Slice<u8> memory, usize alignment, usize new_len, Location loc);
    void (*free)(Allocator *, Slice<u8> memory, usize alignment);
};

template <typename T> T *create(Allocator *a, Location loc = getLocation()) {
    return (T *)a->alloc(a, sizeof(T), alignof(T), loc);
}
template <typename T> void destroy(Allocator *a, T *ptr) {
    a->free(a, {ptr, sizeof(T)}, alignof(T));
}
template <typename T> Slice<T> alloc(Allocator *a, usize n, Location loc = getLocation()) {
    return {(T *)a->alloc(a, sizeof(T) * n, alignof(T), loc), n};
}
template <typename T> void free(Allocator *a, Slice<T> memory) {
    a->free(a, {(u8 *)memory.ptr, sizeof(T) * memory.len}, alignof(T));
}
template <typename T>
Slice<T> realloc(Allocator *a, Slice<T> old_mem, usize new_n, Location loc = getLocation()) {
    return {
        (T *)a->realloc(a, {(u8 *)old_mem.ptr, sizeof(T) * old_mem.len}, alignof(T),
                        sizeof(T) * new_n, loc),
        new_n,
    };
}

// C allocator
static u8 *cAlloc([[maybe_unused]] Allocator *allocator, usize len,
                  [[maybe_unused]] usize alignment, [[maybe_unused]] Location loc) {
    return (u8 *)malloc(len);
}

static u8 *cRealloc([[maybe_unused]] Allocator *allocator, Slice<u8> memory,
                    [[maybe_unused]] usize alignment, usize new_len,
                    [[maybe_unused]] Location loc) {
    return (u8 *)realloc(memory.ptr, new_len);
}

static void cFree([[maybe_unused]] Allocator *allocator, Slice<u8> memory,
                  [[maybe_unused]] usize alignment) {
    free(memory.ptr);
}

static Allocator c_allocator = {
    .alloc = cAlloc,
    .realloc = cRealloc,
    .free = cFree,
};

// Dynamic
template <typename T> struct Dynamic {
    // items's len is capacity
    Slice<T> items;
    usize len;

    T *operator[](usize index) { return items[index]; }
    T *begin() { return items.ptr; }
    T *end() { return items.ptr + len; }
};

template <typename T>
void append(Allocator *allocator, Dynamic<T> *array, T value, Location loc = getLocation()) {
    if (array->len == array->items.len) {
        auto len = array->items.len;
        len = len ? len * 2 : 1;
        assert(len > array->items.len);
        array->items = realloc(allocator, array->items, len, loc);
    }
    array->items.ptr[array->len++] = value;
}

template <typename T> void dynamicDeinit(Allocator *allocator, Dynamic<T> array) {
    free(allocator, array.items);
}

// FixedStack
template <typename T, usize N> struct FixedStack {
    static_assert(N > 0);
    Array<T, N> items;
    usize len;
    usize next;
};

template <typename T, usize N> void push(FixedStack<T, N> *stack, T value) {
    stack->items.data[stack->next] = value;
    stack->next = (stack->next + 1) % N;
    if (stack->len < N) stack->len++;
}

template <typename T, usize N> T pop(FixedStack<T, N> *stack) {
    assert(stack->len > 0);
    stack->len--;
    stack->next = stack->len ? (N + stack->next - 1) % N : 0;
    return stack->items.data[stack->next];
}

template <typename T, usize N> T peek(const FixedStack<T, N> *stack) {
    assert(stack->len > 0);
    auto index = (N + stack->next - 1) % N;
    return stack->items.data[index];
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

static u8 *debugAllocatorAlloc(Allocator *allocator, usize len, usize alignment, Location loc) {
    auto *da = (DebugAllocator *)allocator;

    u8 *mem = da->parent->alloc(da->parent, len, alignment, loc);
    assert(mem);

    append(da->parent, &da->locations, {loc, mem});

    return mem;
}

static u8 *debugAllocatorRealloc(Allocator *allocator, Slice<u8> memory, usize alignment,
                                 usize new_len, Location loc) {
    auto *da = (DebugAllocator *)allocator;
    if (memory.ptr == 0) return debugAllocatorAlloc(allocator, new_len, alignment, loc);

    u8 *new_mem = da->parent->realloc(da->parent, memory, alignment, new_len, loc);
    assert(new_mem);

    for (auto location : da->locations) {
        if (location.mem == memory.ptr) {
            location = {loc, new_mem};
            break;
        }
    }

    return new_mem;
}

static void debugAllocatorFree(Allocator *allocator, Slice<u8> memory, usize alignment) {
    auto *da = (DebugAllocator *)allocator;

    for (auto &location : da->locations) {
        if (location.mem == memory.ptr) {
            location.mem = 0;
            break;
        }
    }

    da->parent->free(da->parent, memory, alignment);
}

static DebugAllocator debugAllocatorInit(Allocator *parent) {
    return {
        .allocator =
            {
                .alloc = debugAllocatorAlloc,
                .realloc = debugAllocatorRealloc,
                .free = debugAllocatorFree,
            },
        .parent = parent,
        .locations = {},
    };
}

static void debugAllocatorDeinit(DebugAllocator *da) {
    for (auto &location : da->locations) {
        if (location.mem != 0) {
            printf("%s:%zu:0: memory leak\n", location.location.file, location.location.line);
        }
    }
    dynamicDeinit(da->parent, da->locations);
}

template <typename T>
static void debugAllocatorOwn(DebugAllocator *da, T *mem, Location loc = getLocation()) {
    assert(mem);
    append(da->parent, &da->locations, {loc, mem});
}

template <typename T>
static void debugAllocatorOwn(DebugAllocator *da, Slice<T> mem, Location loc = getLocation()) {
    assert(mem.ptr);
    append(da->parent, &da->locations, {loc, (void *)mem.ptr});
}


// Arena
static usize alignPosition(usize position, usize alignment) {
    auto mod = position % alignment;
    return mod ? position + (alignment - mod) : position;
}

struct Arena {
    Slice<u8> memory;
    usize next_position;
    usize prev_position;

    void init(usize size) {
        memory = {.ptr = (u8 *)malloc(size), .len = size};
        next_position = 0;
        prev_position = 0;
    }
    void deinit() const { free(memory.ptr); }

    template <typename T>
    Slice<T> pushSlice(usize len, bool zero = true, usize alignment = alignof(T)) {
        usize pos = alignPosition(next_position, alignment);
        auto size = sizeof(T) * len;
        if ((pos + size) > memory.len) {
            printf("You need more memory: %.02fM\n", f32(pos + size) / 1024 / 1024);
            assert((pos + size) <= memory.len);
        }
        prev_position = pos;
        next_position = pos + size;
        if (zero) memset(memory.ptr + pos, 0, size);
        return {(T *)(memory.ptr + pos), len};
    }

    template <typename T> T *push(bool zero = true, usize alignment = alignof(u8)) {
        return (T *)pushSlice<T>(1, zero, alignment).ptr;
    }

    template <typename T>
    Slice<T> realloc(Slice<T> slice, usize new_len, bool zero = true,
                     usize alignment = alignof(T)) {
        if (slice.ptr == 0) return pushSlice<T>(new_len, zero, alignment);
        auto pos = isize(slice.ptr) - isize(memory.ptr);
        assert(pos >= 0 and pos < memory.len);
        usize old_size = sizeof(T) * slice.len;
        usize new_size = sizeof(T) * new_len;
        if ((usize)pos != prev_position) {
            Slice<T> out_slice = pushSlice<T>(new_len, zero, alignment);
            memcpy(out_slice.ptr, slice.ptr, min(new_size, old_size));
            return out_slice;
        }
        assert((pos % alignment) == 0);
        if ((pos + new_size) > memory.len) {
            printf("You need more memory: %.02fM\n", f32(pos + new_size) / 1024.0F / 1024.0F);
            assert((pos + new_size) <= memory.len);
        }
        if (zero and (new_size > old_size)) {
            memset(memory.ptr + pos + old_size, 0, new_size - old_size);
        }
        next_position = pos + new_size;
        return {(T *)slice.ptr, new_len};
    }
};

struct ScopeArena {
    Arena *arena;
    usize position;
    ScopeArena(Arena *arena) : arena(arena) {
        printf("ScopeArena: %.02fM\n", f32(arena->next_position) / 1024.0F / 1024.0);
        position = arena->next_position;
    }
    ~ScopeArena() {
        printf("~ScopeArena: %.02fM\n", f32(arena->next_position) / 1024.0F / 1024.0F);
        arena->next_position = position;
        printf("~ScopeArena: %.02fM\n", f32(arena->next_position) / 1024.0F / 1024.0F);
    }
};

static Slice<char> allocFormatSentinel(Arena *arena, const char *format, ...) {
    va_list args;
    va_start(args, format);
    va_list args_copy;
    va_copy(args_copy, args);
    const auto len = vsnprintf(0, 0, format, args_copy);
    va_end(args_copy);
    assert(len >= 0);
    auto memory = arena->pushSlice<char>(len + 1);
    assert(vsnprintf(memory.ptr, memory.len, format, args) == len);
    va_end(args);
    return memory;
}
