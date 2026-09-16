#pragma once

#include "skn.cpp"
#include "skn_math.cpp"

#include <SDL3/SDL.h>
#include <SDL3_image/SDL_image.h>

const u8 MAX_TEXTURE_SAMPLERS = 16;

#define SDL_CHECK2(cond, file, line)                                                             \
    do {                                                                                         \
        if (!(cond)) {                                                                           \
            SDL_Log("%s:%d: error: %s", file, line, SDL_GetError());                             \
            return SDL_APP_FAILURE;                                                              \
        }                                                                                        \
    } while (false)

#define SDL_CHECK(cond) SDL_CHECK2(cond, __FILE__, __LINE__)

static SDL_GPUShader *createGPUShader(SDL_GPUDevice *device, Slice<const u8> code,
                                      SDL_GPUShaderStage stage, uint num_samplers,
                                      uint num_uniform_buffers) {
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
        out_texture->size = size;
        out_texture->ptr = SDL_CreateGPUTexture(device, &createinfo);
        return out_texture->ptr!= 0;
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
        out_texture->ptr = IMG_LoadGPUTexture_IO(device, copy_pass, src, true,
                                                 &out_texture->size.x, &out_texture->size.y);
        return out_texture->ptr != 0;
    }

    void uploadToGPU(SDL_GPUCopyPass *copy_pass, SDL_GPUTransferBuffer *transfer_buffer,
                     URect region) {
        const SDL_GPUTextureTransferInfo source = {.transfer_buffer = transfer_buffer};
        const SDL_GPUTextureRegion destination = {
            .texture = ptr,
            .x = region.x,
            .y = region.y,
            .w = region.w,
            .h = region.h,
            .d = 1,
        };
        SDL_UploadToGPUTexture(copy_pass, &source, &destination, false);
    }
};

/// Don't forget sdl_allocator.free on result
Slice<char *, true> globDirectory(const char *path, const char *pattern, SDL_GlobFlags flags) {
    return Slice<char *, true>::fromZ(SDL_GlobDirectory(path, pattern, flags, 0));
};

static Allocator sdl_allocator = {
    .malloc = SDL_malloc,
    .free = SDL_free,
    .calloc = SDL_calloc,
    .realloc = SDL_realloc,
};
