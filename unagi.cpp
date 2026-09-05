#ifndef UNAGI_CPP
#define UNAGI_CPP

#include "sakana.cpp"

#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include <SDL3_image/SDL_image.h>

typedef SDL_FPoint vec2;

struct App {
    SDL_Window *window;
    SDL_GPUDevice *device;
    SDL_GPUSampler *sampler;
    vec2 screen;
    bool running;
};

static App unagiInit(const char *name, const char *version, const char *identifier) {
    SDL_SetLogPriorities(SDL_LOG_PRIORITY_VERBOSE);
    SDL_assert(SDL_SetAppMetadata(name, version, identifier));
    SDL_assert(SDL_Init(SDL_INIT_VIDEO));

    const vec2 screen = {640, 360};
    auto *window = SDL_CreateWindow("tower", int(screen.x), int(screen.y), 0);
    SDL_assert(window);

    auto *device = SDL_CreateGPUDevice(SDL_GPU_SHADERFORMAT_SPIRV, true, 0);

    SDL_assert(device);

    SDL_assert(SDL_ClaimWindowForGPUDevice(device, window));

    const SDL_GPUSamplerCreateInfo sampler_create_info = {};

    return {.window = window,
            .device = device,
            .sampler = SDL_CreateGPUSampler(device, &sampler_create_info),
            .screen = screen,
            .running = true};
}

static void unagiInit(App app) {
    SDL_ReleaseGPUSampler(app.device, app.sampler);
    SDL_ReleaseWindowFromGPUDevice(app.device, app.window);
    SDL_DestroyGPUDevice(app.device);
    SDL_DestroyWindow(app.window);
    SDL_Quit();
}

struct Texture {
    vec2 size;
    SDL_GPUTexture *ptr;
};

static SDL_GPUBuffer *createGPUBuffer(SDL_GPUDevice *device, SDL_GPUBufferUsageFlags usage,
                                      Uint32 size) {
    const SDL_GPUBufferCreateInfo buffer_create_info = {usage, size, 0};
    auto *buffer = SDL_CreateGPUBuffer(device, &buffer_create_info);
    SDL_assert(buffer);
    return buffer;
};

static const usize VERTEX_BUFFER_SIZE = sizeof(vec2) * 4;
static const usize INDEX_BUFFER_SIZE = sizeof(i16) * 6;

struct Pipeline {
    SDL_GPUBuffer *vertex_buffer;
    SDL_GPUBuffer *index_buffer;
    SDL_GPUBuffer *instance_buffer;
    SDL_GPUGraphicsPipeline *ptr;
};

static SDL_GPUShader *createGPUShader(SDL_GPUDevice *device, SliceConstU8 code,
                                      SDL_GPUShaderStage stage, u32 num_samplers,
                                      u32 num_uniform_buffers) {
    SDL_GPUShaderCreateInfo create_info = {};
    create_info.code_size = code.len;
    create_info.code = code.ptr;
    create_info.entrypoint = "main";
    create_info.format = SDL_GPU_SHADERFORMAT_SPIRV;
    create_info.stage = stage;
    create_info.num_samplers = num_samplers;
    create_info.num_uniform_buffers = num_uniform_buffers;
    auto *shader = SDL_CreateGPUShader(device, &create_info);
    SDL_assert(shader);
    return shader;
};

Pipeline createPipeline(SDL_GPUDevice *device, usize instance_buffer_size,
                        SliceConstU8 vertex_code, SliceConstU8 fragment_code, u32 num_samplers,
                        u32 instance_size, const SDL_GPUVertexAttribute *vertex_attributes,
                        u32 vertex_attributes_len, SDL_GPUTextureFormat format) {
    auto *vertex_shader = createGPUShader(device, vertex_code, SDL_GPU_SHADERSTAGE_VERTEX, 0, 1);
    defer(SDL_ReleaseGPUShader(device, vertex_shader));

    auto *fragment_shader =
        createGPUShader(device, fragment_code, SDL_GPU_SHADERSTAGE_FRAGMENT, num_samplers, 0);
    defer(SDL_ReleaseGPUShader(device, fragment_shader));

    SDL_GPUGraphicsPipelineCreateInfo pipeline_create_info = {};
    pipeline_create_info.vertex_shader = vertex_shader;
    pipeline_create_info.fragment_shader = fragment_shader;
    const SDL_GPUVertexBufferDescription vertex_buffer_descriptions[2] = {
        {0, sizeof(vec2), SDL_GPU_VERTEXINPUTRATE_VERTEX, 0},
        {1, instance_size, SDL_GPU_VERTEXINPUTRATE_INSTANCE, 0}};
    pipeline_create_info.vertex_input_state.vertex_buffer_descriptions =
        (SDL_GPUVertexBufferDescription *)vertex_buffer_descriptions;
    pipeline_create_info.vertex_input_state.num_vertex_buffers =
        SDL_arraysize(vertex_buffer_descriptions);

    pipeline_create_info.vertex_input_state.vertex_attributes = vertex_attributes;
    pipeline_create_info.vertex_input_state.num_vertex_attributes = vertex_attributes_len;
    pipeline_create_info.primitive_type = SDL_GPU_PRIMITIVETYPE_TRIANGLELIST;
    SDL_GPUColorTargetDescription color_target_description = {};
    color_target_description.format = format;

    color_target_description.blend_state.enable_blend = true;

    color_target_description.blend_state.src_color_blendfactor = SDL_GPU_BLENDFACTOR_SRC_ALPHA;
    color_target_description.blend_state.dst_color_blendfactor =
        SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA;
    color_target_description.blend_state.color_blend_op = SDL_GPU_BLENDOP_ADD;

    color_target_description.blend_state.src_alpha_blendfactor = SDL_GPU_BLENDFACTOR_ONE;
    color_target_description.blend_state.dst_alpha_blendfactor =
        SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA;
    color_target_description.blend_state.alpha_blend_op = SDL_GPU_BLENDOP_ADD;

    pipeline_create_info.target_info.color_target_descriptions = &color_target_description;
    pipeline_create_info.target_info.num_color_targets = 1;

    return {
        .vertex_buffer = createGPUBuffer(device, SDL_GPU_BUFFERUSAGE_VERTEX, VERTEX_BUFFER_SIZE),
        .index_buffer = createGPUBuffer(device, SDL_GPU_BUFFERUSAGE_VERTEX, INDEX_BUFFER_SIZE),
        .instance_buffer =
            createGPUBuffer(device, SDL_GPU_BUFFERUSAGE_VERTEX, instance_buffer_size),
        .ptr = SDL_CreateGPUGraphicsPipeline(device, &pipeline_create_info),
    };
}

void uploadPipeline(Pipeline self, SDL_GPUDevice *device, SDL_GPUCopyPass *copy_pass,
                    vec2 vertices[4]) {
    SDL_GPUTransferBufferCreateInfo transfer_buffer_create_info = {};
    transfer_buffer_create_info.usage = SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD;
    transfer_buffer_create_info.size = VERTEX_BUFFER_SIZE + INDEX_BUFFER_SIZE;
    auto *transfer_buffer = SDL_CreateGPUTransferBuffer(device, &transfer_buffer_create_info);
    SDL_assert(transfer_buffer);
    defer(SDL_ReleaseGPUTransferBuffer(device, transfer_buffer));

    {
        auto *transfer_buffer_data =
            (Uint8 *)SDL_MapGPUTransferBuffer(device, transfer_buffer, false);
        defer(SDL_UnmapGPUTransferBuffer(device, transfer_buffer));

        SDL_assert(transfer_buffer_data);
        const i16 indices[6]{0, 1, 2, 0, 2, 3};
        SDL_memcpy(transfer_buffer_data, (Uint8 *)vertices, VERTEX_BUFFER_SIZE);
        SDL_memcpy(transfer_buffer_data + VERTEX_BUFFER_SIZE, (Uint8 *)indices,
                   INDEX_BUFFER_SIZE);
    }

    SDL_GPUTransferBufferLocation source{transfer_buffer, 0};

    SDL_GPUBufferRegion destination = {self.vertex_buffer, 0, VERTEX_BUFFER_SIZE};
    SDL_UploadToGPUBuffer(copy_pass, &source, &destination, false);

    source.offset = VERTEX_BUFFER_SIZE;
    destination.buffer = self.index_buffer;
    destination.size = INDEX_BUFFER_SIZE;
    SDL_UploadToGPUBuffer(copy_pass, &source, &destination, false);
}

void destroyPipeline(Pipeline self, SDL_GPUDevice *device) {
    SDL_ReleaseGPUGraphicsPipeline(device, self.ptr);
    SDL_ReleaseGPUBuffer(device, self.index_buffer);
    SDL_ReleaseGPUBuffer(device, self.instance_buffer);
    SDL_ReleaseGPUBuffer(device, self.vertex_buffer);
}

#endif // UNAGI_CPP
