#pragma once

#include "skn.cpp"
#include "skn_math.cpp"

#include <SDL3/SDL.h>
#include <SDL3_image/SDL_image.h>

#define SDL_CHECK2(cond, file, line)                                                             \
    do {                                                                                         \
        if (!(cond)) {                                                                           \
            SDL_Log("%s:%d: error: %s", file, line, SDL_GetError());                             \
            return SDL_APP_FAILURE;                                                              \
        }                                                                                        \
    } while (false)

#define SDL_CHECK(cond) SDL_CHECK2(cond, __FILE__, __LINE__) // NOLINT

static SDL_GPUShader *createGPUShader(SDL_GPUDevice *device, Slice<const u8> code,
                                      SDL_GPUShaderStage stage, uint num_samplers,
                                      uint num_uniform_buffers) {
    const SDL_GPUShaderCreateInfo createinfo = {
        .code_size = code.len,
        .code = code.ptr,
        .entrypoint = "main",
        .format = SDL_GPU_SHADERFORMAT_SPIRV,
        .stage = stage,
        .num_samplers = num_samplers,
        .num_uniform_buffers = num_uniform_buffers,
    };
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

    static bool create(SDL_GPUDevice *device, ivec2 size, Texture *texture) {
        const SDL_GPUTextureCreateInfo createinfo = {
            .format = SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM,
            .usage = SDL_GPU_TEXTUREUSAGE_SAMPLER,
            .width = uint(size.x),
            .height = uint(size.y),
            .layer_count_or_depth = 1,
            .num_levels = 1,
        };
        *texture = {.size = size, .ptr = SDL_CreateGPUTexture(device, &createinfo)};
        return texture->ptr != 0;
    }

    static bool load(SDL_GPUDevice *device, SDL_GPUCopyPass *copy_pass, const char *file,
                     Texture *texture) {
        texture->ptr =
            IMG_LoadGPUTexture(device, copy_pass, file, &texture->size.x, &texture->size.y);
        return texture->ptr != 0;
    }

    static bool load(SDL_GPUDevice *device, SDL_GPUCopyPass *copy_pass, Slice<u8> data,
                     Texture *texture) {
        auto *src = SDL_IOFromConstMem(data.ptr, data.len);
        texture->ptr = IMG_LoadGPUTexture_IO(device, copy_pass, src, true, &texture->size.x,
                                             &texture->size.y);
        return texture->ptr != 0;
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
