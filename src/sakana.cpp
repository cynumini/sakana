#include <sakana/sakana.hpp>

#include "../build/shader.frag.cpp"
#include "../build/shader.vert.cpp"

App sakanaInit(const char *name, const char *version, const char *identifier) {
    SDL_SetLogPriorities(SDL_LOG_PRIORITY_VERBOSE);
    SDL_assert(SDL_SetAppMetadata(name, version, identifier));
    SDL_assert(SDL_Init(SDL_INIT_VIDEO));

    const vec2 screen = {640, 360};
    auto *window = SDL_CreateWindow("tower", int(screen.x), int(screen.y), 0);
    SDL_assert(window);

    auto *device = SDL_CreateGPUDevice(SDL_GPU_SHADERFORMAT_SPIRV, true, 0);

    SDL_assert(device);

    SDL_assert(SDL_ClaimWindowForGPUDevice(device, window));


    return {.window = window, .device = device, .screen = screen};
}

void sakanaDeinit(App app) {
    SDL_ReleaseWindowFromGPUDevice(app.device, app.window);
    SDL_DestroyGPUDevice(app.device);
    SDL_DestroyWindow(app.window);
    SDL_Quit();
}
