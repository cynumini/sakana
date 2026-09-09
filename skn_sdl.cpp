#include "skn.cpp"
#include "skn_math.cpp"

#include <SDL3/SDL.h>
#include <SDL3_image/SDL_image.h>

typedef SDL_FRect Rect;
typedef SDL_Color Color;
typedef SDL_FColor FColor;

const Color WHITE = {255, 255, 255, 255};
const Color GRAY = {128, 128, 128, 255};

FColor toFColor(Color color) {
    return {
        f32(color.r) / 255.0F,
        f32(color.g) / 255.0F,
        f32(color.b) / 255.0F,
        f32(color.a) / 255.0F,
    };
}

const u8 MAX_TEXTURE_SAMPLERS = 16;

#define SDL_CHECK(cond, desc)                                                                    \
    do {                                                                                         \
        if (!(cond)) {                                                                           \
            SDL_Log("Couldn't " desc ": %s", SDL_GetError());                                    \
            return SDL_APP_FAILURE;                                                              \
        }                                                                                        \
    } while (false);

static SDL_GPUShader *createGPUShader(SDL_GPUDevice *device, Slice<const u8> code,
                                      SDL_GPUShaderStage stage, u32 num_samplers,
                                      u32 num_uniform_buffers) {
    SDL_GPUShaderCreateInfo createinfo = {};
    createinfo.code_size = code.len;
    createinfo.code = code.ptr;
    createinfo.entrypoint = "main";
    createinfo.format = SDL_GPU_SHADERFORMAT_SPIRV;
    createinfo.stage = stage;
    createinfo.num_samplers = num_samplers;
    createinfo.num_uniform_buffers = num_uniform_buffers;
    return SDL_CreateGPUShader(device, &createinfo);
};

static SDL_GPUBuffer *createGPUBuffer(SDL_GPUDevice *device, SDL_GPUBufferUsageFlags usage,
                                      Uint32 size) {
    const SDL_GPUBufferCreateInfo createinfo = {usage, size, 0};
    return SDL_CreateGPUBuffer(device, &createinfo);
};

static SDL_GPUTransferBuffer *createGPUTransferBuffer(SDL_GPUDevice *device, uint size) {
    const SDL_GPUTransferBufferCreateInfo createinfo = {SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD, size, 0};
    return SDL_CreateGPUTransferBuffer(device, &createinfo);
}

static void uploadToGPUBuffer(SDL_GPUCopyPass *copy_pass, SDL_GPUTransferBuffer *transfer_buffer,
                              uint offset, SDL_GPUBuffer *buffer, uint size) {
    const SDL_GPUTransferBufferLocation source = {transfer_buffer, offset};
    const SDL_GPUBufferRegion destination = {buffer, 0, size};
    SDL_UploadToGPUBuffer(copy_pass, &source, &destination, false);
}

struct SDLTexture {
    ivec2 size;
    SDL_GPUTexture *ptr;
};

SDLTexture loadTexture(SDL_GPUDevice *device, SDL_GPUCopyPass *copy_pass, const char *file) {
    SDLTexture texture = {};
    texture.ptr = IMG_LoadGPUTexture(device, copy_pass, file, &texture.size.x, &texture.size.y);
    return texture;
};

// __attribute__((format(printf, 2, 3))) static void bufferPrint(Slice<char> buffer, const char
// *fmt,
//                                                               ...) {
//     va_list args;
//     va_start(args, fmt);

//     auto result = SDL_vsnprintf(buffer.ptr, buffer.len, fmt, args);
//     va_end(args);
//     SDL_assert(result >= 0 and usize(result) < buffer.len);
// }

// struct Location {
//     const char *file;
//     usize line;
// };

// Location getLocation(const char *file = __builtin_FILE(), usize line = __builtin_LINE()) {
//     return Location{file, line};
// }

// template <typename T> struct DynamicArray {
//     T *items;
//     usize len;
//     usize capacity;
// };

// enum class AllocatorKind : u8 {
//     tracking,
//     arena,
// };

// struct AllocatorLocation {
//     Location location;
//     void *mem;
// };

// struct Chunk {
//     void *data;
//     usize size;
//     usize position;
//     Chunk *next;
// };

// struct Allocator {
//     AllocatorKind kind;
//     Allocator *parent;
//     union {
//         DynamicArray<AllocatorLocation> locations;
//         Chunk chunk;
//     };
// };

// [[noreturn]] static void unreachable(const char *file, usize line) {
//     SDL_Log("%s:%zu:0: unreachable", file, line);
//     abort();
// }

// #define UNREACHABLE() unreachable(__FILE__, __LINE__)

// template <typename T>
// static T *realloc(Allocator *allocator, T *mem, usize len, Location loc = getLocation()) {
//     if (allocator == 0) {
//         return (T *)SDL_realloc(mem, sizeof(T) * len);
//     }
//     switch (allocator->kind) {
//     case AllocatorKind::tracking: {
//         T *tmp = realloc<T>(allocator->parent, mem, len, loc);
//         for (usize i = 0; i < allocator->locations.len; i++) {
//             if (allocator->locations.items[i].mem == mem) {
//                 allocator->locations.items[i] = {loc, tmp};
//                 return tmp;
//             }
//         }
//     }
//     case AllocatorKind::arena: {
//         UNREACHABLE();
//     }
//     };
//     UNREACHABLE();
// }

// template <typename T>
// void append(Allocator *allocator, DynamicArray<T> *array, T value, Location loc) {
//     if (array->len == array->capacity) {
//         array->capacity = array->capacity != 0 ? array->capacity * 2 : 1;
//         array->items = realloc<T>(allocator, array->items, array->capacity);
//     }
//     array->items = alloc<T>(allocator, sizeof(T) * array->capacity, loc);
//     array->items[array->len++] = value;
// }

// template <typename T>
// static T *alloc(Allocator *allocator, usize len, Location loc = getLocation()) {
//     if (allocator == 0) {
//         void *mem = SDL_malloc(sizeof(T) * len);
//         SDL_memset(mem, 0, sizeof(T) * len);
//         return (T *)mem;
//     }
//     switch (allocator->kind) {
//     case AllocatorKind::tracking: {
//         T *tmp = alloc<T>(allocator->parent, len, loc);
//         append(allocator->parent, &allocator->locations, {loc, tmp}, loc);
//         return tmp;
//     }
//     case AllocatorKind::arena: {
//         UNREACHABLE();
//     }
//     };
//     UNREACHABLE();
// }

// template <typename T> static T *create(Allocator *allocator, Location loc = getLocation()) {
//     return alloc<T>(allocator, 1, loc);
// }

// template <typename T> static void free(Allocator *allocator, T *mem) {
//     if (allocator == 0) {
//         SDL_free(mem);
//         return;
//     }
//     switch (allocator->kind) {
//     case AllocatorKind::tracking: {
//         for (usize i = 0; i < allocator->locations.len; i++) {
//             if (allocator->locations.items[i].mem == mem) {
//                 free(allocator->parent, mem);
//                 allocator->locations.items[i].mem = 0;
//                 return;
//             }
//         }
//     }
//     case AllocatorKind::arena:
//         UNREACHABLE();
//     }
//     UNREACHABLE();
// }

// static void checkMemoryLeaks(const Allocator *allocator) {
//     SDL_assert(allocator->kind == AllocatorKind::tracking);
//     for (usize i = 0; i < allocator->locations.len; i++) {
//         if (allocator->locations.items[i].mem != 0) {
//             SDL_Log("%s:%zu:0: memory leak", allocator->locations.items[i].location.file,
//                     allocator->locations.items[i].location.line);
//         }
//     }
// }

// Allocator tracking_allocator{
//     .kind = AllocatorKind::tracking,
// };
