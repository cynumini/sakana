#pragma once

#include "skn.cpp"
#include "skn_math.cpp"

#include <SDL3/SDL.h>
#include <SDL3_image/SDL_image.h>

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
    const SDL_GPUTransferBufferCreateInfo createinfo = {SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD, size,
                                                        0};
    return SDL_CreateGPUTransferBuffer(device, &createinfo);
}

static void uploadToGPUBuffer(SDL_GPUCopyPass *copy_pass, SDL_GPUTransferBuffer *transfer_buffer,
                              uint offset, SDL_GPUBuffer *buffer, uint size) {
    const SDL_GPUTransferBufferLocation source = {transfer_buffer, offset};
    const SDL_GPUBufferRegion destination = {buffer, 0, size};
    SDL_UploadToGPUBuffer(copy_pass, &source, &destination, false);
}

struct Texture {
    ivec2 size;
    SDL_GPUTexture *ptr;

    static bool create(SDL_GPUDevice *device, ivec2 size, Texture *out_texture) {
        SDL_GPUTextureCreateInfo createinfo = {};
        createinfo.format = SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM;
        createinfo.usage = SDL_GPU_TEXTUREUSAGE_SAMPLER;
        createinfo.width = size.x;
        createinfo.height = size.y;
        createinfo.layer_count_or_depth = 1;
        createinfo.num_levels = 1;
        out_texture->size.x = size.x;
        out_texture->size.y = size.y;
        out_texture->ptr = SDL_CreateGPUTexture(device, &createinfo);
        return out_texture != 0;
    }

    static bool load(SDL_GPUDevice *device, SDL_GPUCopyPass *copy_pass, const char *file,
                     Texture *out_texture) {
        out_texture->ptr = IMG_LoadGPUTexture(device, copy_pass, file, &out_texture->size.x,
                                              &out_texture->size.y);
        return out_texture != 0;
    }

    static bool load(SDL_GPUDevice *device, SDL_GPUCopyPass *copy_pass, Slice<u8> data,
    Texture *out_texture) {
        auto *src = SDL_IOFromConstMem(data.ptr, data.len);
        out_texture->ptr = IMG_LoadGPUTexture_IO(device, copy_pass, src, true, &out_texture->size.x,
                                              &out_texture->size.y);
        return out_texture != 0;
    }
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

// SDL allocator
static u8 *sdlAlloc([[maybe_unused]] Allocator *allocator, usize len,
                    [[maybe_unused]] usize alignment, [[maybe_unused]] Location loc) {
    return (u8 *)SDL_malloc(len);
}

static u8 *sdlRealloc([[maybe_unused]] Allocator *allocator, Slice<u8> memory,
                      [[maybe_unused]] usize alignment, usize new_len,
                      [[maybe_unused]] Location loc) {
    return (u8 *)SDL_realloc(memory.ptr, new_len);
}

static void sdlFree([[maybe_unused]] Allocator *allocator, Slice<u8> memory,
                    [[maybe_unused]] usize alignment) {
    SDL_free(memory.ptr);
}

static Allocator sdl_allocator = {
    .alloc = sdlAlloc,
    .realloc = sdlRealloc,
    .free = sdlFree,
};
