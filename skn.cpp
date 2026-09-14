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

// defer
template <typename F> struct privDefer {
    F f;
    privDefer(F f) : f(f) {}
    ~privDefer() { f(); }
};

template <typename F> privDefer<F> defer_func(F f) { return privDefer<F>(f); }

#define DEFER_1(x, y) x##y
#define DEFER_2(x, y) DEFER_1(x, y)
#define DEFER_3(x) DEFER_2(x, __COUNTER__)
#define defer(code) auto DEFER_3(_defer_) = defer_func([&]() { code; })

// Location
struct Location {
    const char *file;
    usize line;
};

static Location getLocation(const char *file = __builtin_FILE(), usize line = __builtin_LINE()) {
    return Location{file, line};
}

[[noreturn]] static inline void panic(const char *message, Location loc = getLocation()) {
    printf("%s:%lu: panic: %s\n", loc.file, loc.line, message);
    abort();
}

template <typename T> usize lenZ(T *array) {
    usize len = 0;
    while (array[len] != 0) len++;
    return len;
}

// Slice
template <typename T> struct Slice {
    T *ptr;
    usize len;
    bool zero;
    T &operator[](usize index) { return ptr[index]; }
    const T &operator[](usize index) const { return ptr[index]; }
    T *begin() { return ptr; }
    T *end() { return ptr + len; }
    usize size() { return sizeof(T) * (zero ? len + 1 : len); }
    static Slice<T> fromZ(T *array) { return {array, lenZ(array), false}; }
    static Slice<T> zFromZ(T *array) { return {array, lenZ(array), true}; }
};

// String
typedef Slice<const char> ConstString;
typedef Slice<char> String;

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
    u8 *(*allocFn)(Allocator *, usize len, usize alignment, Location loc);
    u8 *(*reallocFn)(Allocator *, Slice<u8> memory, usize alignment, usize new_len, Location loc);
    void (*freeFn)(Allocator *, Slice<u8> memory, usize alignment);

    template <typename T> T *create(Location loc = getLocation()) {
        return (T *)allocFn(this, sizeof(T), alignof(T), loc);
    }

    template <typename T> void destroy(T *ptr) {
        freeFn(this, {(u8 *)ptr, sizeof(T), false}, alignof(T));
    }

    template <typename T>
    Slice<T> alloc(usize n, bool zero = false, Location loc = getLocation()) {
        auto *ptr = (T *)allocFn(this, sizeof(T) * n, alignof(T), loc);
        if (zero) memset(ptr, 0, sizeof(T) * n);
        return {ptr, n, false};
    }

    template <typename T>
    Slice<T> allocZ(usize n, bool zero = false, Location loc = getLocation()) {
        auto mem = alloc<T>(n + 1, zero, loc);
        if (!zero) mem.ptr[n] = 0;
        return {mem.ptr, n, true};
    }

    template <typename T> void free(Slice<T> memory) {
        freeFn(this, {(u8 *)memory.ptr, memory.size(), false}, alignof(T));
    }

    template <typename T>
    Slice<T> realloc(Slice<T> old_mem, usize new_n, Location loc = getLocation()) {
        if (old_mem.zero) {
            auto new_size = sizeof(T) * (new_n + 1);
            auto ptr = (T *)reallocFn(this, {(u8 *)old_mem.ptr, old_mem.size(), false},
                                      alignof(T), new_size, loc);
            ptr[new_n] = {};
            return {ptr, new_n, true};
        }
        return {
            (T *)reallocFn(this, {(u8 *)old_mem.ptr, old_mem.size(), false}, alignof(T),
                           sizeof(T) * new_n, loc),
            new_n,
            false,
        };
    }

    String dupeAndFree(const char *str_z, Allocator *source, Location loc = getLocation()) {
        auto slice_z = ConstString::zFromZ(str_z);
        auto slice_out = alloc<char>(slice_z.len, false, loc);
        memcpy(slice_out.ptr, slice_z.ptr, slice_out.len);
        source->free(slice_z);
        return slice_out;
    }

    String dupeAndFreeZ(const char *str_z, Allocator *source, Location loc = getLocation()) {
        auto slice_z = ConstString::zFromZ(str_z);
        auto slice_out = allocZ<char>(slice_z.len, false, loc);
        memcpy(slice_out.ptr, slice_z.ptr, slice_out.len);
        source->free(slice_z);
        return slice_out;
    }

    // Slice<String> dupeSliceAndFreeZ(const char **array, Allocator *source,
    //                                 Location loc = getLocation()) {
    //     auto slice_z = Slice<const char *>::zFromZ(array);
    //     auto slice_out = alloc<String>(slice_z.len, loc);
    //     for (usize i = 0; i < slice_z.len; i++) {
    //         slice_out[i] = dupeAndFreeZ(slice_z[i], source, loc);
    //     }
    //     source->free(slice_z);
    //     return slice_out;
    // }

    String allocFormatZ(const char *format, ...) __attribute__((format(gnu_printf, 2, 3))) {
        va_list args;
        va_start(args, format);
        va_list args_copy;
        va_copy(args_copy, args);
        const auto len = vsnprintf(0, 0, format, args_copy);
        va_end(args_copy);
        assert(len >= 0);
        auto memory = allocZ<char>(len);
        assert(vsnprintf(memory.ptr, memory.size(), format, args) == len);
        va_end(args);
        return memory;
    }
};

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
    .allocFn = cAlloc,
    .reallocFn = cRealloc,
    .freeFn = cFree,
};

// Dynamic
template <typename T> struct Dynamic {
    // items's len is capacity
    Slice<T> items;
    usize len;

    T &operator[](usize index) { return items[index]; }
    T *begin() { return items.ptr; }
    T *end() { return items.ptr + len; }

    void deinit(Allocator *a) { a->free(items); }

    void append(Allocator *a, T value, Location loc = getLocation()) {
        if (len == items.len) {
            auto capacity = items.len;
            capacity = capacity ? capacity * 2 : 1;
            assert(capacity > items.len);
            items = a->realloc(items, capacity, loc);
        }
        items[len++] = value;
    }
};

// FixedStack
template <typename T, usize N> struct FixedStack {
    static_assert(N > 0);
    Array<T, N> items;
    usize len;
    usize next;

    void push(T value) {
        items.data[next] = value;
        next = (next + 1) % N;
        if (len < N) len++;
    }

    T pop() {
        assert(len > 0);
        len--;
        next = len ? (N + next - 1) % N : 0;
        return items.data[next];
    }

    T peek() {
        assert(len > 0);
        auto index = (N + next - 1) % N;
        return items.data[index];
    }
};

// Debug Allocator
struct AllocationLocation {
    Location location;
    void *mem;
};

struct DebugAllocator {
    Allocator allocator;
    Allocator *parent;
    Dynamic<AllocationLocation> locations;

    static DebugAllocator init(Allocator *parent) {
        return {
            .allocator =
                {
                    .allocFn = allocFn,
                    .reallocFn = reallocFn,
                    .freeFn = freeFn,
                },
            .parent = parent,
            .locations = {},
        };
    }

    static void deinit(DebugAllocator *da) {
        for (auto &location : da->locations) {
            if (location.mem != 0) {
                printf("%s:%zu:0: memory leak\n", location.location.file, location.location.line);
            }
        }
        da->locations.deinit(da->parent);
    }

    static u8 *allocFn(Allocator *allocator, usize len, usize alignment, Location loc) {
        auto *da = (DebugAllocator *)allocator;

        u8 *mem = da->parent->allocFn(da->parent, len, alignment, loc);
        assert(mem);

        da->locations.append(da->parent, {loc, mem});

        return mem;
    }

    static u8 *reallocFn(Allocator *allocator, Slice<u8> memory, usize alignment, usize new_len,
                         Location loc) {
        auto *da = (DebugAllocator *)allocator;
        if (memory.ptr == 0) return allocFn(allocator, new_len, alignment, loc);

        u8 *new_mem = da->parent->reallocFn(da->parent, memory, alignment, new_len, loc);
        assert(new_mem);

        for (auto &location : da->locations) {
            if (location.mem == memory.ptr) {
                location = {loc, new_mem};
                break;
            }
        }

        return new_mem;
    }

    static void freeFn(Allocator *allocator, Slice<u8> memory, usize alignment) {
        auto *da = (DebugAllocator *)allocator;

        for (auto &location : da->locations) {
            if (location.mem == memory.ptr) {
                location.mem = 0;
                break;
            }
        }

        da->parent->freeFn(da->parent, memory, alignment);
    }
};

// Arena
struct Arena {
    Allocator allocator;
    Allocator *parent;
    Slice<u8> memory;
    usize next_position;
    usize position;

    void init(Allocator *parent, usize size) {
        allocator = {
            .allocFn = Arena::allocFn,
            .reallocFn = Arena::reallocFn,
            .freeFn = Arena::freeFn,
        };
        this->parent = parent;
        memory = parent->alloc<u8>(size);
        next_position = 0;
        position = 0;
    }

    void deinit() const { parent->free(memory); }

    static usize alignPosition(usize position, usize alignment) {
        auto mod = position % alignment;
        return mod ? position + (alignment - mod) : position;
    }

    void checkCapacity(usize pos) const {
        if (pos > memory.len) {
            auto kb = f32(pos) / 1024.0F;
            auto mb = kb / 1024.0F;
            if (pos < 10000) {
                printf("You need more memory: %luB\n", pos);
            } else if (kb < 10000) {
                printf("You need more memory: %.02fK\n", kb);
            } else {
                printf("You need more memory: %.02fM\n", mb);
            }
            assert((pos) <= memory.len);
        }
    }

    static u8 *allocFn(Allocator *allocator, usize len, usize alignment,
                       [[maybe_unused]] Location loc) {
        auto *a = (Arena *)allocator;
        const usize pos = alignPosition(a->next_position, alignment);
        a->checkCapacity(pos + len);
        a->position = pos;
        a->next_position = pos + len;
        return a->memory.ptr + pos;
    }

    usize checkAndGetPosition(const u8 *ptr) const {
        auto diff = isize(ptr) - isize(memory.ptr);
        assert(diff >= 0);
        auto pos = usize(diff);
        assert(pos < memory.len);
        return pos;
    }

    static u8 *reallocFn(Allocator *allocator, Slice<u8> memory, usize alignment, usize new_len,
                         Location loc) {
        auto *a = (Arena *)allocator;
        if (memory.ptr == 0) return allocFn(allocator, new_len, alignment, loc);
        const usize pos = a->checkAndGetPosition(memory.ptr);
        if (pos != a->position) {
            u8 *out_memory = allocFn(allocator, new_len, alignment, loc);
            memcpy(out_memory, memory.ptr, min(new_len, memory.len));
            return out_memory;
        }
        assert((pos % alignment) == 0);
        a->checkCapacity(pos + new_len);
        a->next_position = pos + new_len;
        return a->memory.ptr + pos;
    }

    static void freeFn(Allocator *allocator, Slice<u8> memory, [[maybe_unused]] usize alignment) {
        auto *a = (Arena *)allocator;
        const usize pos = a->checkAndGetPosition(memory.ptr);
        if (pos == a->position) {
            a->next_position = pos;
        }
    }
};

struct ScopeArena {
    Arena *arena;
    usize position;
    usize next_position;
    ScopeArena(Arena *arena) : arena(arena) {
        printf("ScopeArena: %.02fM\n", f32(arena->next_position) / 1024.0F / 1024.0);
        position = arena->position;
        next_position = arena->next_position;
    }
    ~ScopeArena() {
        printf("~ScopeArena: %.02fM\n", f32(arena->next_position) / 1024.0F / 1024.0F);
        arena->position = position;
        arena->next_position = next_position;
        printf("~ScopeArena: %.02fM\n", f32(arena->next_position) / 1024.0F / 1024.0F);
    }
};

inline usize fnv1aHash(const char *string) {
    constexpr usize fnv_prime = 1099511628211ULL;
    constexpr usize fnv_offset_basis = 14695981039346656037ULL;

    usize hash = fnv_offset_basis;
    auto len = strlen(string);
    for (usize i = 0; i < len; i++) {
        hash = hash xor (usize) string[i];
        hash = hash * fnv_prime;
    }
    return hash;
}

template <typename T> struct HashMap {
    struct Item {
        const char *key;
        T value;
        bool exist;
    };

    Slice<Item> data;

    enum class PutInSliceResult : u8 { updated, need_resize, put };
    static PutInSliceResult putInSlice(Slice<Item> slice, const char *key, T value) {
        auto hash = fnv1aHash(key);

        for (usize offset = 0; offset < slice.len; offset++) {
            auto index = (hash + offset) % slice.len;

            if (slice[index].exist) {
                if (strcmp(slice[index].key, key) == 0) {
                    slice[index].value = value;
                    return PutInSliceResult::updated;
                }
            } else {
                slice[index] = {key, value, true};
                return PutInSliceResult::put;
            }
        }

        return PutInSliceResult::need_resize;
    }

    void resize(Allocator *a, Location loc = getLocation()) {
        auto new_data = a->alloc<Item>(data, data.len ? data.len * 2 : 1, true, loc);
        for (const auto &item : data) {
            if (item.exist) {
                assert(putInSlice(new_data, item.key, item.value) !=
                       PutInSliceResult::need_resize);
            }
        }
        a->free(data);
        data = new_data;
    }

    Item *getItemByKey(const char *key) {
        auto hash = fnv1aHash(key);

        for (usize offset = 0; offset < data.len; offset++) {
            auto index = (hash + offset) % data.len;

            if (!data[index].exist) {
                return 0;
            }

            if (strcmp(data[index].key, key) == 0) {
                return &data[index];
            }
        }
        return 0;
    }

    T get() { return getItemByKey().value; }

    enum class PutResult : u8 { put, updated };
    PutResult put(Allocator *a, const char *key, T value, Location loc = getLocation()) {
        if (data.len == 0) resize(a, loc);
        while (true) {
            switch (putInSlice(data, key, value)) {
            case PutInSliceResult::put: {
                return PutResult::put;
            }
            case PutInSliceResult::updated: {
                return PutResult::updated;
            }
            case PutInSliceResult::need_resize: {
                resize(a, loc);
            }
            }
        }
    }
};
