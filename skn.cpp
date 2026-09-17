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
    T *ptr;
    size_t len;
    T &operator[](size_t index) { return ptr[index]; }
    const T &operator[](size_t index) const { return ptr[index]; }
    T *begin() { return ptr; }
    T *end() { return ptr + len; }
    size_t size() { return sizeof(T) * (zero ? len + 1 : len); }
    static Slice<T, zero> fromZ(T *array) { return {array, lenZ(array)}; }
};

// String
typedef Slice<char, true> StringZ;
typedef Slice<char> String;
typedef Slice<const char, true> ConstStringZ;
typedef Slice<const char> ConstString;

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

struct Allocator {
    void *(*malloc)(size_t size);
    void (*free)(void *p);
    void *(*calloc)(size_t n, size_t size);
    void *(*realloc)(void *p, size_t size);
};

// Allocator interface
struct AllocatorOld {
    struct VTable {
        u8 *(*mallocFn)(void *, size_t size, size_t alignment);
        void (*freeFn)(void *, Slice<u8> mem, size_t alignment);
        u8 *(*callocFn)(void *, size_t n, size_t size, size_t alignment);
        u8 *(*reallocFn)(void *, Slice<u8> mem, size_t alignment, size_t new_len);
    };
    void *ptr;
    const VTable *vtable;

    template <typename T, bool zero = false> T *create() {
        if constexpr (zero) return (T *)vtable->mallocFn(ptr, sizeof(T), alignof(T));
        return (T *)vtable->callocFn(ptr, 1, sizeof(T), alignof(T));
    }

    template <typename T> void destroy(T *value) {
        vtable->freeFn(ptr, {(u8 *)value, sizeof(T)}, alignof(T));
    }

    template <typename T, bool zero = false> Slice<T> alloc(size_t n) {
        if constexpr (zero) {
            return {(T *)vtable->callocFn(ptr, n, sizeof(T), alignof(T)), n};
        }
        return {(T *)vtable->mallocFn(ptr, sizeof(T) * n, alignof(T)), n};
    }

    template <typename T, bool zero = false> Slice<T, true> allocZ(size_t n) {
        auto mem = alloc<T, zero>(n + 1);
        if constexpr (!zero) mem.ptr[n] = 0;
        return {mem.ptr, n};
    }

    template <typename T, bool zero> void free(Slice<T, zero> mem) {
        vtable->freeFn(ptr, {(u8 *)mem.ptr, mem.size()}, alignof(T));
    }

    template <typename T, bool zero = false>
    Slice<T, zero> realloc(Slice<T, zero> old_mem, size_t new_n) {
        if constexpr (zero) {
            auto new_size = sizeof(T) * (new_n + 1);
            auto value = (T *)vtable->reallocFn(ptr, {(u8 *)old_mem.ptr, old_mem.size()},
                                                alignof(T), new_size);
            value[new_n] = {};
            return {value, new_n, true};
        }
        return {
            (T *)vtable->reallocFn(ptr, {(u8 *)old_mem.ptr, old_mem.size()}, alignof(T),
                                   sizeof(T) * new_n),
            new_n,
        };
    }

    StringZ dupeZ(const char *string) {
        auto len = strlen(string);
        auto slice_out = allocZ<char, false>(len);
        memcpy(slice_out.ptr, string, len);
        return slice_out;
    }

    template <typename T> StringZ dupeZ(Slice<T> string) {
        auto slice_out = allocZ<char, false>(string.len);
        memcpy(slice_out.ptr, string.ptr, string.len);
        return slice_out;
    }

    String dupeAndFree(const char *str_z, AllocatorOld *source) {
        auto slice_z = ConstString::fromZ(str_z);
        auto slice_out = alloc<char, false>(slice_z.len);
        memcpy(slice_out.ptr, slice_z.ptr, slice_out.len);
        source->free(slice_z);
        return slice_out;
    }

    StringZ dupeAndFreeZ(const char *str_z, AllocatorOld *source) {
        auto slice_z = ConstString::fromZ(str_z);
        auto slice_out = allocZ<char, false>(slice_z.len);
        memcpy(slice_out.ptr, slice_z.ptr, slice_out.len);
        source->free(slice_z);
        return slice_out;
    }

    // Slice<String> dupeSliceAndFreeZ(const char **array, Allocator *source,
    //                                 Location loc = getLocation()) {
    //     auto slice_z = Slice<const char *>::zFromZ(array);
    //     auto slice_out = alloc<String>(slice_z.len, loc);
    //     for (size_t i = 0; i < slice_z.len; i++) {
    //         slice_out[i] = dupeAndFreeZ(slice_z[i], source, loc);
    //     }
    //     source->free(slice_z);
    //     return slice_out;
    // }

    StringZ allocFormatZ(const char *format, ...) __attribute__((format(gnu_printf, 2, 3))) {
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
static Allocator c_allocator = {
    .malloc = malloc,
    .free = free,
    .calloc = calloc,
    .realloc = realloc,
};

// Dynamic
template <typename T> struct Dynamic {
    // items's len is capacity
    Slice<T> items;
    size_t len;

    T &operator[](size_t index) { return items[index]; }
    T *begin() { return items.ptr; }
    T *end() { return items.ptr + len; }

    void deinit(AllocatorOld *a) { a->free(items); }

    void append(AllocatorOld *a, T value) {
        if (len == items.len) {
            auto capacity = items.len;
            capacity = capacity ? capacity * 2 : 1;
            assert(capacity > items.len);
            items = a->realloc(items, capacity);
        }
        items[len++] = value;
    }
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

    static u8 *mallocFn(void *ctx, size_t len, size_t alignment) {
        auto *a = (Arena *)ctx;
        const size_t pos = alignPosition(a->next_position, alignment);
        a->checkCapacity(pos + len);
        a->position = pos;
        a->next_position = pos + len;
        return a->mem + pos;
    }

    static u8 *callocFn(void *ctx, size_t n, size_t size, size_t alignment) {
        size *= n;
        auto *mem = mallocFn(ctx, size, alignment);
        memset(mem, 0, size);
        return mem;
    }

    static u8 *reallocFn(void *ctx, Slice<u8> memory, size_t alignment, size_t new_len) {
        auto *a = (Arena *)ctx;
        if (memory.ptr == 0) return mallocFn(ctx, new_len, alignment);
        const size_t pos = a->checkAndGetPosition(memory.ptr);
        if (pos != a->position) {
            u8 *out_memory = mallocFn(ctx, new_len, alignment);
            memcpy(out_memory, memory.ptr, min(new_len, memory.len));
            return out_memory;
        }
        assert((pos % alignment) == 0);
        a->checkCapacity(pos + new_len);
        a->next_position = pos + new_len;
        return a->mem + pos;
    }

    static void freeFn(void *ctx, Slice<u8> memory, [[maybe_unused]] size_t alignment) {
        auto *a = (Arena *)ctx;
        if (memory.len == 0) return;
        const size_t pos = a->checkAndGetPosition(memory.ptr);
        if (pos == a->position) {
            a->next_position = pos;
        }
    }

    constexpr static AllocatorOld::VTable vtable = {
        .mallocFn = Arena::mallocFn,
        .freeFn = Arena::freeFn,
        .callocFn = Arena::callocFn,
        .reallocFn = Arena::reallocFn,

    };

    AllocatorOld allocator() { return {.ptr = this, .vtable = &vtable}; }

    static size_t alignPosition(size_t position, size_t alignment) {
        auto mod = position % alignment;
        return mod ? position + (alignment - mod) : position;
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
};

struct ScopeArena {
    Arena *arena;
    Arena tmp;
    size_t prev_capacity;
    ScopeArena(Arena *arena) : arena(arena), tmp({}) {
        auto free_space = arena->capacity - arena->next_position;
        auto half_free = free_space / 2;
        tmp.mem = arena->mem + arena->next_position + half_free;
        tmp.capacity = half_free;
        prev_capacity = arena->capacity;
        arena->capacity = arena->next_position + half_free;
    }
    ~ScopeArena() {
        arena->capacity = prev_capacity;
    }
};


inline size_t fnv1aHash(const char *string) {
    constexpr size_t fnv_prime = 1099511628211ULL;
    constexpr size_t fnv_offset_basis = 14695981039346656037ULL;

    size_t hash = fnv_offset_basis;
    auto len = strlen(string);
    for (size_t i = 0; i < len; i++) {
        hash = hash xor (size_t) string[i];
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

    static HashMap<T> init(AllocatorOld *a, size_t size) {
        HashMap<T> self = {};
        self.resize(a, size);
        return self;
    }

    enum class PutInSliceResult : u8 { updated, need_resize, put };
    static PutInSliceResult putInSlice(Slice<Item> slice, const char *key, T value) {
        auto hash = fnv1aHash(key);

        for (size_t offset = 0; offset < slice.len; offset++) {
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

    void resize(AllocatorOld *a, size_t new_len) {
        auto new_data = a->alloc<Item, true>(new_len);
        for (const auto &item : data) {
            if (item.exist) {
                assert(putInSlice(new_data, item.key, item.value) !=
                       PutInSliceResult::need_resize);
            }
        }
        a->free(data);
        data = new_data;
    }

    void resize(AllocatorOld *a) { resize(a, data.len ? data.len * 2 : 1); }

    Item *getItemByKey(const char *key) {
        auto hash = fnv1aHash(key);

        for (size_t offset = 0; offset < data.len; offset++) {
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

    T get(const char *key) { return getItemByKey(key)->value; }

    enum class PutResult : u8 { put, updated };
    PutResult put(AllocatorOld *a, const char *key, T value) {
        if (data.len == 0) resize(a);
        while (true) {
            switch (putInSlice(data, key, value)) {
            case PutInSliceResult::put: {
                return PutResult::put;
            }
            case PutInSliceResult::updated: {
                return PutResult::updated;
            }
            case PutInSliceResult::need_resize: {
                resize(a);
            }
            }
        }
    }

    HashMap<T> copy(AllocatorOld *a) {
        HashMap<T> copy = HashMap<T>::init(a, data.len);

        for (const auto &item : data) {
            if (item.exist) {
                copy.put(a, a->dupeZ(item.key).ptr, item.value);
            }
        }

        return copy;
    }
};

template <typename T> struct Dictionary {
    struct Item {
        const char *key;
        T value;
    };

    Dynamic<Item> items;

    Item *begin() { return items.items.ptr; }
    Item *end() { return items.items.ptr + items.len; }

    void put(AllocatorOld *a, const char *key, T value) { items.append(a, {key, value}); }

    void sort(int (*sortFn)(const void *a, const void *b)) {
        qsort(items.items.ptr, items.len, sizeof(Item), sortFn);
    }
};

static ConstString getStem(const char *string) {
    int pos = -1;
    auto len = strlen(string);
    for (int i = int(len) - 1; i >= 0; i--) {
        if (string[i] == '.') {
            pos = i;
            break;
        }
    }
    if (pos == -1) return {string, len};
    return {string, (size_t)pos};
}
