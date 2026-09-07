#ifndef UNAGI_CPP
#define UNAGI_CPP

#include "sakana.cpp"

#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include <SDL3_image/SDL_image.h>

typedef SDL_FPoint vec2;
typedef SDL_FColor Color;

const Color BLACK = {1.0F, 1.0F, 1.0F, 1.0F};
const Color RED = {1.0F, 0.0F, 0.0F, 1.0F};
const Color WHITE = {1.0F, 1.0F, 1.0F, 1.0F};
const Color GREY = {0.5F, 0.5F, 0.5F, 1.0F};

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

static void unagiDeinit(App app) {
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

    u32 instance_buffer_size;
    SDL_GPUTransferBuffer *instances_transfer_buffer;

    SDL_GPUGraphicsPipeline *ptr;
};

static SDL_GPUShader *createGPUShader(SDL_GPUDevice *device, Slice<const u8> code,
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

static Pipeline createPipeline(SDL_GPUDevice *device, u32 instance_size, u32 instance_len,
                               Slice<const u8> vertex_code, Slice<const u8> fragment_code,
                               u32 num_samplers, const SDL_GPUVertexAttribute *vertex_attributes,
                               u32 vertex_attributes_len, SDL_GPUTextureFormat format) {
    auto *vertex_shader = createGPUShader(device, vertex_code, SDL_GPU_SHADERSTAGE_VERTEX, 0, 1);
    defer(SDL_ReleaseGPUShader(device, vertex_shader));

    auto *fragment_shader =
        createGPUShader(device, fragment_code, SDL_GPU_SHADERSTAGE_FRAGMENT, num_samplers, 0);
    defer(SDL_ReleaseGPUShader(device, fragment_shader));

    SDL_GPUGraphicsPipelineCreateInfo create_info = {};
    create_info.vertex_shader = vertex_shader;
    create_info.fragment_shader = fragment_shader;
    const SDL_GPUVertexBufferDescription vertex_buffer_descriptions[2] = {
        {0, sizeof(vec2), SDL_GPU_VERTEXINPUTRATE_VERTEX, 0},
        {1, instance_size, SDL_GPU_VERTEXINPUTRATE_INSTANCE, 0}};
    create_info.vertex_input_state.vertex_buffer_descriptions =
        (SDL_GPUVertexBufferDescription *)vertex_buffer_descriptions;
    create_info.vertex_input_state.num_vertex_buffers = SDL_arraysize(vertex_buffer_descriptions);

    create_info.vertex_input_state.vertex_attributes = vertex_attributes;
    create_info.vertex_input_state.num_vertex_attributes = vertex_attributes_len;
    create_info.primitive_type = SDL_GPU_PRIMITIVETYPE_TRIANGLELIST;
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

    create_info.target_info.color_target_descriptions = &color_target_description;
    create_info.target_info.num_color_targets = 1;

    return {
        .vertex_buffer = createGPUBuffer(device, SDL_GPU_BUFFERUSAGE_VERTEX, VERTEX_BUFFER_SIZE),
        .index_buffer = createGPUBuffer(device, SDL_GPU_BUFFERUSAGE_INDEX, INDEX_BUFFER_SIZE),
        .instance_buffer =
            createGPUBuffer(device, SDL_GPU_BUFFERUSAGE_VERTEX, instance_size * instance_len),
        .instance_buffer_size = instance_size * instance_len,
        .instances_transfer_buffer = 0,
        .ptr = SDL_CreateGPUGraphicsPipeline(device, &create_info),
    };
}

static void uploadPipeline(Pipeline self, SDL_GPUDevice *device, SDL_GPUCopyPass *copy_pass,
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

static void *beginUploadInstances(Pipeline *self, SDL_GPUDevice *device) {
    SDL_GPUTransferBufferCreateInfo transfer_buffer_create_info = {};
    transfer_buffer_create_info.usage = SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD;
    transfer_buffer_create_info.size = self->instance_buffer_size;
    self->instances_transfer_buffer =
        SDL_CreateGPUTransferBuffer(device, &transfer_buffer_create_info);
    SDL_assert(self->instances_transfer_buffer);
    return SDL_MapGPUTransferBuffer(device, self->instances_transfer_buffer, true);
}

static void endUploadInstances(Pipeline *self, SDL_GPUDevice *device,
                               SDL_GPUCopyPass *copy_pass) {
    SDL_assert(self->instances_transfer_buffer);
    defer(self->instances_transfer_buffer = 0);

    SDL_UnmapGPUTransferBuffer(device, self->instances_transfer_buffer);

    const SDL_GPUTransferBufferLocation source{self->instances_transfer_buffer, 0};
    const SDL_GPUBufferRegion destination = {self->instance_buffer, 0,
                                             self->instance_buffer_size};
    SDL_UploadToGPUBuffer(copy_pass, &source, &destination, true);

    SDL_ReleaseGPUTransferBuffer(device, self->instances_transfer_buffer);
}

static void destroyPipeline(Pipeline self, SDL_GPUDevice *device) {
    SDL_ReleaseGPUGraphicsPipeline(device, self.ptr);
    SDL_ReleaseGPUBuffer(device, self.index_buffer);
    SDL_ReleaseGPUBuffer(device, self.instance_buffer);
    SDL_ReleaseGPUBuffer(device, self.vertex_buffer);
}

static SDL_GPURenderPass *beginRenderPass(SDL_GPUCommandBuffer *command_buffer,
                                          SDL_GPUTexture *swapchain_texture) {
    SDL_GPUColorTargetInfo color_target_info = {};
    color_target_info.texture = swapchain_texture;
    color_target_info.clear_color = GREY;
    color_target_info.load_op = SDL_GPU_LOADOP_CLEAR;
    color_target_info.store_op = SDL_GPU_STOREOP_STORE;
    return SDL_BeginGPURenderPass(command_buffer, &color_target_info, 1, 0);
}

static void bindPipeline(Pipeline self, SDL_GPURenderPass *render_pass) {
    SDL_BindGPUGraphicsPipeline(render_pass, self.ptr);
    SDL_GPUBufferBinding buffer_binding = {self.vertex_buffer, 0};
    SDL_BindGPUVertexBuffers(render_pass, 0, &buffer_binding, 1);
    buffer_binding.buffer = self.instance_buffer;
    SDL_BindGPUVertexBuffers(render_pass, 1, &buffer_binding, 1);
    buffer_binding.buffer = self.index_buffer;
    SDL_BindGPUIndexBuffer(render_pass, &buffer_binding, SDL_GPU_INDEXELEMENTSIZE_16BIT);
}

#endif // UNAGI_CPP
