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
};

static Texture loadTexture(SDL_GPUDevice *device, SDL_GPUCopyPass *copy_pass, const char *file) {
    Texture texture = {};
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

// SDL allocator
static void *sdlMalloc([[maybe_unused]] Allocator *allocator, usize size,
                       [[maybe_unused]] Location loc) {
    return SDL_malloc(size);
}

static void sdlFree([[maybe_unused]] Allocator *allocator, void *mem) { SDL_free(mem); }

static void *sdlCalloc([[maybe_unused]] Allocator *allocator, usize len, usize size,
                       [[maybe_unused]] Location loc) {
    return SDL_calloc(len, size);
}

static void *sdlRealloc([[maybe_unused]] Allocator *allocator, void *mem, usize size,
                        [[maybe_unused]] Location loc) {
    return SDL_realloc(mem, size);
}

static Allocator sdl_allocator = {
    .malloc = sdlMalloc,
    .free = sdlFree,
    .calloc = sdlCalloc,
    .realloc = sdlRealloc,
};
