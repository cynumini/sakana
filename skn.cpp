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

typedef unsigned int uint;

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

template <typename T> size_t lenZ(T *array) {
    size_t len = 0;
    while (array[len] != 0) len++;
    return len;
}

// Slice
template <typename T, bool zero = false> struct Slice {
    size_t len;
    T *ptr;

    T &operator[](size_t index) {
        assert(index < len);
        return ptr[index];
    }

    const T &operator[](size_t index) const {
        assert(index < len);
        return ptr[index];
    }

    bool operator==(Slice other) {
        if (len != other.len) return false;
        for (size_t i = 0; i < len; i++) {
            if (ptr[i] != other[i]) return false;
        }
        return true;
    }

    T *begin() { return ptr; }
    T *end() { return ptr + len; }

    Slice<T, false> withoutZero() {
        static_assert(zero);
        return {len, ptr};
    }

    Slice<T, false> withZero() {
        static_assert(zero);
        return {len + 1, ptr};
    }
};

template <typename T> using SliceZ = Slice<T, true>;

static Slice<const char> getStem(const char *c_str) {
    int pos = -1;
    auto len = strlen(c_str);
    assert(len);
    for (int i = int(len - 1); i >= 0; i--) {
        if (c_str[i] == '.') {
            pos = i;
            break;
        }
    }
    if (pos == -1) return {len, c_str};
    return {(size_t)pos, c_str};
}

// Array
template <typename T, size_t N> struct Array {
    T data[N];
    static constexpr size_t len = N;
    T &operator[](size_t index) { return data[index]; }
    const T &operator[](size_t index) const { return data[index]; }
    T *begin() { return data; }
    T *end() { return data + len; }
};

#define ARRAY_LEN(array) (sizeof(array) / sizeof((array)[0]))

// Dynamic


// Allocator interface

struct Allocator {
    void *(*malloc)(size_t size);
    void (*free)(void *p);
    void *(*calloc)(size_t n, size_t size);
    void *(*realloc)(void *p, size_t size);
};

// // Allocator interface
// struct AllocatorOld {
//     struct VTable {
//         u8 *(*mallocFn)(void *, size_t size, size_t alignment);
//         void (*freeFn)(void *, SliceOld<u8> mem, size_t alignment);
//         u8 *(*callocFn)(void *, size_t n, size_t size, size_t alignment);
//         u8 *(*reallocFn)(void *, SliceOld<u8> mem, size_t alignment, size_t new_len);
//     };
//     void *ptr;
//     const VTable *vtable;

//     template <typename T, bool zero = false> T *create() {
//         if constexpr (zero) return (T *)vtable->mallocFn(ptr, sizeof(T), alignof(T));
//         return (T *)vtable->callocFn(ptr, 1, sizeof(T), alignof(T));
//     }

//     template <typename T> void destroy(T *value) {
//         vtable->freeFn(ptr, {(u8 *)value, sizeof(T)}, alignof(T));
//     }

//     template <typename T, bool zero = false> SliceOld<T> alloc(size_t n) {
//         if constexpr (zero) {
//             return {(T *)vtable->callocFn(ptr, n, sizeof(T), alignof(T)), n};
//         }
//         return {(T *)vtable->mallocFn(ptr, sizeof(T) * n, alignof(T)), n};
//     }

//     template <typename T, bool zero = false> SliceOld<T, true> allocZ(size_t n) {
//         auto mem = alloc<T, zero>(n + 1);
//         if constexpr (!zero) mem.ptr[n] = 0;
//         return {mem.ptr, n};
//     }

//     template <typename T, bool zero> void free(SliceOld<T, zero> mem) {
//         vtable->freeFn(ptr, {(u8 *)mem.ptr, mem.size()}, alignof(T));
//     }

//     template <typename T, bool zero = false>
//     SliceOld<T, zero> realloc(SliceOld<T, zero> old_mem, size_t new_n) {
//         if constexpr (zero) {
//             auto new_size = sizeof(T) * (new_n + 1);
//             auto value = (T *)vtable->reallocFn(ptr, {(u8 *)old_mem.ptr, old_mem.size()},
//                                                 alignof(T), new_size);
//             value[new_n] = {};
//             return {value, new_n, true};
//         }
//         return {
//             (T *)vtable->reallocFn(ptr, {(u8 *)old_mem.ptr, old_mem.size()}, alignof(T),
//                                    sizeof(T) * new_n),
//             new_n,
//         };
//     }

//     StringZ dupeZ(const char *string) {
//         auto len = strlen(string);
//         auto slice_out = allocZ<char, false>(len);
//         memcpy(slice_out.ptr, string, len);
//         return slice_out;
//     }

//     template <typename T> StringZ dupeZ(SliceOld<T> string) {
//         auto slice_out = allocZ<char, false>(string.len);
//         memcpy(slice_out.ptr, string.ptr, string.len);
//         return slice_out;
//     }

//     String dupeAndFree(const char *str_z, AllocatorOld *source) {
//         auto slice_z = ConstString::fromZ(str_z);
//         auto slice_out = alloc<char, false>(slice_z.len);
//         memcpy(slice_out.ptr, slice_z.ptr, slice_out.len);
//         source->free(slice_z);
//         return slice_out;
//     }

//     StringZ dupeAndFreeZ(const char *str_z, AllocatorOld *source) {
//         auto slice_z = ConstString::fromZ(str_z);
//         auto slice_out = allocZ<char, false>(slice_z.len);
//         memcpy(slice_out.ptr, slice_z.ptr, slice_out.len);
//         source->free(slice_z);
//         return slice_out;
//     }

//     // Slice<String> dupeSliceAndFreeZ(const char **array, Allocator *source,
//     //                                 Location loc = getLocation()) {
//     //     auto slice_z = Slice<const char *>::zFromZ(array);
//     //     auto slice_out = alloc<String>(slice_z.len, loc);
//     //     for (size_t i = 0; i < slice_z.len; i++) {
//     //         slice_out[i] = dupeAndFreeZ(slice_z[i], source, loc);
//     //     }
//     //     source->free(slice_z);
//     //     return slice_out;
//     // }
// };

// C allocator
static Allocator c_allocator = {
    .malloc = malloc,
    .free = free,
    .calloc = calloc,
    .realloc = realloc,
};

// Fixed
template <typename T> struct Fixed {
    Slice<T> items;
    size_t len;

    T &operator[](size_t index) { return items[index]; }
    T *begin() { return items.ptr; }
    T *end() { return items.ptr + len; }

    void append(T value) {
        assert(len <= items.len);
        items[len++] = value;
    }
};

// FixedStack
template <typename T, size_t N> struct FixedStack {
    static_assert(N > 0);
    Array<T, N> items;
    size_t len;
    size_t next;

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

// // Debug Allocator
// struct AllocationLocation {
//     Location location;
//     void *mem;
// };

// struct DebugAllocator {
//     Allocator *parent;
//     Dynamic<AllocationLocation> locations;

//     static u8 *allocFn(void *ctx, size_t len, size_t alignment, Location loc) {
//         auto *da = (DebugAllocator *)ctx;

//         u8 *mem = da->parent->vtable->allocFn(da->parent, len, alignment, loc);
//         assert(mem);

//         da->locations.append(da->parent, {loc, mem});

//         return mem;
//     }

//     static u8 *reallocFn(void *ctx, Slice<u8> memory, size_t alignment, size_t new_len,
//                          Location loc) {
//         auto *da = (DebugAllocator *)ctx;
//         if (memory.ptr == 0) return allocFn(ctx, new_len, alignment, loc);

//         u8 *new_mem = da->parent->vtable->reallocFn(da->parent, memory, alignment, new_len,
//         loc); assert(new_mem);

//         for (auto &location : da->locations) {
//             if (location.mem == memory.ptr) {
//                 location = {loc, new_mem};
//                 break;
//             }
//         }

//         return new_mem;
//     }

//     static void freeFn(void *ctx, Slice<u8> memory, size_t alignment) {
//         auto *da = (DebugAllocator *)ctx;

//         for (auto &location : da->locations) {
//             if (location.mem == memory.ptr) {
//                 location.mem = 0;
//                 break;
//             }
//         }

//         da->parent->vtable->freeFn(da->parent, memory, alignment);
//     }

//     constexpr static Allocator::VTable vtable = {
//         .allocFn = DebugAllocator::allocFn,
//         .reallocFn = DebugAllocator::reallocFn,
//         .freeFn = DebugAllocator::freeFn,
//     };

//     Allocator allocator() { return {.ptr = this, .vtable = &vtable}; }

//     static DebugAllocator init(Allocator *parent) {
//         return {
//             .parent = parent,
//             .locations = {},
//         };
//     }

//     static void deinit(DebugAllocator *da) {
//         for (auto &location : da->locations) {
//             if (location.mem != 0) {
//                 printf("%s:%hu:0: memory leak\n", location.location.file,
//                 location.location.line);
//             }
//         }
//         da->locations.deinit(da->parent);
//     }
// };

// template <typename T> struct SliceZ {
//     size_t len;
//     T *ptr;

//     T &operator[](size_t index) {
//         assert(index < len);
//         return ptr[index];
//     }

//     const T &operator[](size_t index) const {
//         assert(index < len);
//         return ptr[index];
//     }

//     T *begin() { return ptr; }
//     T *end() { return ptr + len; }

//     Slice<T> toSlice() { return {len + 1, ptr}; }
// };

// template <typename T> SliceZ<T> Slice<T>::toSliceZ() {
//     assert(len > 0);
//     return {len - 1, ptr};
// }

// Arena
struct Arena {
    u8 *mem;
    uint capacity;
    uint next_position;
    uint position;

    void init(Allocator a, uint size) {
        mem = static_cast<u8 *>(a.malloc(size));
        capacity = size;
    }

    void checkCapacity(size_t pos) const {
        if (pos > capacity) {
            auto kb = float(pos) / 1024.0F;
            auto mb = kb / 1024.0F;
            if (pos < 10000) {
                printf("You need more memory: %luB\n", pos);
            } else if (kb < 10000) {
                printf("You need more memory: %.02fK\n", kb);
            } else {
                printf("You need more memory: %.02fM\n", mb);
            }
            assert((pos) <= capacity);
        }
    }

    template <typename T> Slice<T> alloc(size_t len) {
        if (len == 0) return {};
        const auto size = len * sizeof(T);
        auto mod = next_position % alignof(T);
        const size_t pos = mod ? next_position + (alignof(T) - mod) : next_position;
        checkCapacity(pos + size);
        position = pos;
        next_position = pos + size;
        return Slice<T>{len, (T *)(mem + pos)};
    };

    template <typename T> SliceZ<T> allocZ(size_t len) {
        auto slice = alloc<T>(len + 1);
        slice[len] = 0;
        return {len, slice.ptr};
    };

    template <typename T> void free(Slice<T> slice) {
        if (slice.len == 0) return;
        const size_t pos = checkAndGetPosition((u8 *)slice.ptr);
        if (pos == position) next_position = pos;
    }

    template <typename T> void free(SliceZ<T> slice_z) { free(slice_z.withZero()); }

    template <typename T> Slice<T> realloc(Slice<T> slice, size_t new_len) {
        const auto new_size = new_len * sizeof(T);
        if (slice.len == 0) return alloc<T>(new_len);
        const size_t pos = checkAndGetPosition((u8 *)slice.ptr);
        if (pos != position) {
            Slice<T> out_slice = alloc<T>(new_len);
            memcpy(out_slice.ptr, slice.ptr, min(slice.len * sizeof(T), new_size));
            return out_slice;
        }
        assert((pos % alignof(T)) == 0);
        checkCapacity(pos + new_size);
        next_position = pos + new_size;
        slice.len = new_len;
        return slice;
    }

    // static u8 *callocFn(void *ctx, size_t n, size_t size, size_t alignment) {
    //     size *= n;
    //     auto *mem = mallocFn(ctx, size, alignment);
    //     memset(mem, 0, size);
    //     return mem;
    // }

    // constexpr static AllocatorOld::VTable vtable = {
    //     .mallocFn = Arena::mallocFn,
    //     .freeFn = Arena::freeFn,
    //     .callocFn = Arena::callocFn,
    //     .reallocFn = Arena::reallocFn,
    // };

    // AllocatorOld allocator() { return {.ptr = this, .vtable = &vtable}; }

    size_t checkAndGetPosition(const u8 *ptr) const {
        auto diff = ptrdiff_t(ptr) - ptrdiff_t(mem);
        assert(diff >= 0);
        auto pos = size_t(diff);
        assert(pos < capacity);
        return pos;
    }

    void reset() {
        position = 0;
        next_position = 0;
    }

    SliceZ<char> dupeZ(Slice<const char> src) {
        auto slice_z = allocZ<char>(src.len);
        memcpy(slice_z.ptr, src.ptr, src.len);
        return slice_z;
    }

    Slice<const char> dupeConst(Slice<const char> src) {
        auto dst = alloc<char>(src.len);
        memcpy(dst.ptr, src.ptr, src.len);
        return {dst.len, dst.ptr};
    }

    SliceZ<char> dupeZ(char *src) {
        auto slice_z = allocZ<char>(strlen(src) + 1);
        strcpy(slice_z.ptr, src);
        return slice_z;
    }

    SliceZ<char> vAllocPrintZ(const char *fmt, va_list ap) {
        va_list copy;

        va_copy(copy, ap);
        const auto len = vsnprintf(0, 0, fmt, copy);
        va_end(copy);

        assert(len >= 0);
        SliceZ<char> slice = allocZ<char>(len);

        assert(vsnprintf(slice.ptr, len + 1, fmt, ap) == len);

        return slice;
    }

    SliceZ<char> allocPrintZ(const char *fmt, ...) __attribute__((format(gnu_printf, 2, 3))) {
        va_list ap;
        va_start(ap, fmt);
        auto slice = vAllocPrintZ(fmt, ap);
        va_end(ap);
        return slice;
    }

    Slice<char> allocPrint(const char *fmt, ...) __attribute__((format(gnu_printf, 2, 3))) {
        va_list ap;
        va_start(ap, fmt);
        auto slice = vAllocPrintZ(fmt, ap);
        va_end(ap);
        return slice.withoutZero();
    }
};

struct ScopeArena {
    Arena *arena;
    Arena tmp;
    size_t prev_capacity;
    ScopeArena(Arena *arena) : arena(arena), tmp({}) {
        uint arena_half_free = (arena->capacity - arena->next_position) / 2U;

        tmp.mem = arena->mem + arena->next_position + arena_half_free;
        tmp.capacity = arena_half_free;

        prev_capacity = arena->capacity;

        arena->capacity = arena->next_position + arena_half_free;
    }
    ~ScopeArena() { arena->capacity = prev_capacity; }
};

// Dynamic
template <typename T> struct Dynamic {
    // items's len is capacity
    size_t len;
    Slice<T> items;

    T &operator[](size_t index) { return items[index]; }
    T *begin() { return items.ptr; }
    T *end() { return items.ptr + len; }

    static Dynamic init(Arena *a, size_t initial_capacity) {
        return {.items = a->alloc<T>(initial_capacity)};
    }

    void deinit(Arena *a) { a->free(items); }

    void append(Arena *a, T value) {
        if (len == items.len) {
            auto capacity = items.len ? items.len * 2 : 1;
            items = a->realloc(items, capacity);
        }
        items[len++] = value;
    }

    void sort(int (*sortFn)(const void *a, const void *b)) {
        qsort(items.ptr, items.len, sizeof(T), sortFn);
    }
};

inline size_t fnv1aHash(Slice<const char> string) {
    constexpr size_t fnv_prime = 1099511628211ULL;
    constexpr size_t fnv_offset_basis = 14695981039346656037ULL;

    size_t hash = fnv_offset_basis;

    for (auto c : string) {
        hash = hash xor (size_t) c;
        hash = hash * fnv_prime;
    }

    return hash;
}

template <typename T> struct HashMap {
    struct Item {
        Slice<const char> key;
        T value;
    };

    Slice<Item> data;

    static HashMap<T> init(Arena *a, size_t len) { return {.data = a->alloc<Item>(len)}; }

    static bool putInSlice(Slice<Item> slice, Slice<const char> key, T value) {
        assert(key.len);
        if (slice.len == 0) return false;
        auto hash = fnv1aHash(key);

        for (size_t offset = 0; offset < slice.len; offset++) {
            auto index = (hash + offset) % slice.len;

            if (slice[index].key.len) {
                assert(slice[index].key != key);
            } else {
                slice[index] = {key, value};
                return true;
            }
        }

        return false;
    }

    Item *getItem(Slice<const char> key) {
        assert(key.len);
        auto hash = fnv1aHash(key);

        for (size_t offset = 0; offset < data.len; offset++) {
            auto index = (hash + offset) % data.len;

            if (!data[index].key.len) {
                return 0;
            }

            if (data[index].key == key) {
                return &data[index];
            }
        }
        return 0;
    }

    T get(const char *key) { return getItem({strlen(key), key})->value; }

    void put(Arena *a, Slice<const char> key, T value) {
        while (true) {
            if (putInSlice(data, key, value)) return;
            auto new_len = data.len ? data.len * 2 : 1;
            auto new_data = a->alloc<Item>(new_len);
            for (const auto &item : data) {
                if (item.key.len) assert(putInSlice(new_data, item.key, item.value));
            }
            a->free(data);
            data = new_data;
        }
    }

    HashMap<T> copy(Arena *a) {
        HashMap<T> copy = HashMap<T>::init(a, data.len);

        for (const auto &item : data) {
            if (item.exist) {
                copy.put(a, a->dupeZ(item.key).ptr, item.value);
            }
        }

        return copy;
    }
};
