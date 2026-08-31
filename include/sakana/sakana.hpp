#ifndef SAKANA_HPP
#define SAKANA_HPP

#include <stdint.h>

#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>
#include <SDL3_image/SDL_image.h>

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

#define offsetof(t, d) __builtin_offsetof(t, d)

typedef SDL_FPoint vec2;

struct App {
    SDL_Window *window;
    SDL_GPUDevice *device;
    vec2 screen;
};

App sakanaInit(const char *name, const char *version, const char *identifier);
void sakanaDeinit(App app);

typedef int32_t i32;
typedef uint8_t u8;
typedef size_t usize;

struct SliceU8 {
    u8 *ptr;
    usize len;
};

struct SliceConstU8 {
    const u8 *ptr;
    usize len;
};

#endif // SAKANA_HPP
