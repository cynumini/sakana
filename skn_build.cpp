#pragma once

#include "skn.cpp"

#include <assert.h>
#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

#define CXX "clang++"

static const char *program;

template <bool new_line> void vlog(const char *level, const char *fmt, va_list args) {
    if (program) {
        printf("%s[%s]: ", program, level);
    } else {
        printf("%s: ", level);
    }
    vprintf(fmt, args);
    if constexpr (new_line) putchar('\n');
}

template <bool new_line = true>
__attribute__((format(printf, 1, 2))) void logInfo(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vlog<new_line>("info", fmt, args);
    va_end(args);
}

template <bool new_line = true>
__attribute__((format(printf, 1, 2))) void logError(const char *fmt, ...) {
    va_list args;
    va_start(args, fmt);
    vlog<new_line>("error", fmt, args);
    va_end(args);
}

typedef struct timespec Time;

static Time getModifiedTime(const char *filename) {
    struct stat buf;
    if (stat(filename, &buf) != 0) return {};
    return buf.st_mtim;
}

bool operator>(const Time a, const Time b) {
    return (a.tv_sec > b.tv_sec) or ((a.tv_sec == b.tv_sec) and (a.tv_nsec > b.tv_nsec));
}

static bool needsUpdate(const char *output, const char *input) {
    auto input_time = getModifiedTime(input);
    assert(input_time.tv_sec != 0 or input_time.tv_nsec != 0);
    return input_time > getModifiedTime(output);
}

template <size_t N> static bool needsUpdate(const char *output, const char *(&inputs)[N]) {
    auto output_time = getModifiedTime(output);
    for (auto &input : inputs) {
        auto input_time = getModifiedTime(input);
        assert(input_time.tv_sec != 0 or input_time.tv_nsec != 0);
        if (input_time > output_time) return true;
    }
    return false;
}

static void runReplace(Arena *a, Dynamic<const char *> args) {
    assert(args.len > 0);
    logInfo<false>("run:");
    for (auto &arg : args) printf(" %s", arg);
    putchar('\n');
    args.append(a, 0);
    execvp(args[0], (char **)args.ptr);
    logError("%s", strerror(errno));
    args.pop();
}

static void run(Arena *a, Dynamic<const char *> args) {
    auto pid = fork();
    assert(pid != -1);
    if (pid == 0) {
        runReplace(a, args);
        _exit(1);
    } else {
        int status = 0;
        assert(waitpid(pid, &status, 0) == pid);
        assert(WIFEXITED(status));
        assert(WEXITSTATUS(status) == 0);
    }
}

static void rebuildAndRestartOnChanges(Arena *a, int argc, const char *argv[], const char *name) {
    assert(argc >= 1);

    auto result = mkdir("./build", 0755);
    assert(result == 0 or errno == EEXIST);

    program = argv[0];

    const char *inputs[] = {name, __FILE__};

    if (needsUpdate(program, inputs)) {
        logInfo("self-rebuild");

        auto args = Dynamic<const char *>::init(a, 10);
        args.append(a, CXX);
        args.append(a, inputs[0]);
        args.append(a, "-o");
        args.append(a, program);
        args.append(a, "-g");
        run(a, args);

        args.clear();
        args.append(a, program);
        runReplace(a, args);
    }
}

#define REBUILD_AND_RESTART_ON_CHANGES(ctx, argc, argv)                                          \
    rebuildAndRestartOnChanges(ctx, argc, argv, __FILE__)

template <typename T = char> static Slice<T> loadFile(Arena *a, const char *filename) {
    auto *stream = fopen(filename, "rb");
    assert(stream);
    assert(fseek(stream, 0, SEEK_END) == 0);
    auto position = ftell(stream);
    assert(position != -1);
    size_t n = position;
    assert(fseek(stream, 0, SEEK_SET) == 0);
    assert(n % sizeof(T) == 0);
    size_t count = n / sizeof(T);
    auto data = a->alloc<T>(count);
    assert(fread(data.ptr, sizeof(T), count, stream) == count);
    assert(fclose(stream) == 0);
    return data;
}

static void addArgsFromCompileFlags(Arena *a, Dynamic<const char *> *args) {
    auto data = loadFile(a, "compile_flags.txt");
    uint offset = 0;
    for (uint i = 0; i < data.len; i++) {
        if (data.ptr[i] == '\n') {
            if (i > offset) {
                args->append(a, a->dupeZ({i - offset, data.ptr + offset}).ptr);
            }
            offset = i + 1;
        }
    }
    if (offset < data.len) {
        args->append(a, a->dupeZ({data.len - offset, data.ptr + offset}).ptr);
    }
}

static const char *glslc(Arena *a, const char *input, const char *output) {
    if (needsUpdate(output, input)) {
        auto args = Dynamic<const char *>::init(a, 5);
        args.append(a, "glslc");
        args.append(a, input);
        args.append(a, "-o");
        args.append(a, output);
        run(a, args);
    }
    return output;
}

static const char *shadercross(Arena *a, const char *input, const char *output) {
    if (needsUpdate(output, input)) {
        auto args = Dynamic<const char *>::init(a, 5);
        args.append(a, "shadercross");
        args.append(a, input);
        args.append(a, "-o");
        args.append(a, output);
        run(a, args);
    }
    return output;
}

template <size_t N>
static const char *binToHpp(Arena *a, const char *(&inputs)[N], const char *output,
                            const char *(&var_names)[N]) {
    if (needsUpdate(output, inputs)) {
        auto *stream = fopen(output, "w");
        assert(stream);

        assert(fprintf(stream, "#pragma once\n\n") >= 0);
        assert(fprintf(stream, "#include <skn.cpp>\n\n") >= 0);

        for (size_t i = 0; i < N; i++) {
            auto input = inputs[i];
            auto var_name = var_names[i];
            logInfo("generate %s from %s", output, input);

            auto data = loadFile<u8>(a, input);
            defer(a->free(data));

            assert(fprintf(stream, "const u8 %s[] = {\n    ", var_name) >= 0);

            for (uint i = 0; i < data.len; i++) {
                if (i == 0) {
                    assert(fprintf(stream, "0x%02x,", data.ptr[i]) >= 0);
                } else {
                    if (i % 15 == 0) {
                        assert(fprintf(stream, "\n   ") >= 0);
                    }
                    assert(fprintf(stream, " 0x%02x,", (unsigned)data.ptr[i]) >= 0);
                }
            }
            assert(fprintf(stream, "\n};\n") >= 0);
            if ((i + 1) < N) assert(fprintf(stream, "\n") >= 0);
        }

        assert(fclose(stream) == 0);
    }

    return output;
}

static const char *binToHpp(Arena *a, const char *input, const char *output,
                            const char *var_name) {
    const char *inputs[] = {input};
    const char *var_names[] = {var_name};
    return binToHpp(a, inputs, output, var_names);
}

static const char *glslcHpp(Arena *a, const char *input, const char *output,
                            const char *var_name) {
    return binToHpp(a, glslc(a, input, a->allocPrintZ("%s.spv", output).ptr), output, var_name);
}

static const char *shadercrossHpp(Arena *a, const char *input, const char *output,
                                  const char *var_prefix) {
    const char *inputs[] = {shadercross(a, input, a->allocPrintZ("%s.spv", output).ptr),
                            shadercross(a, input, a->allocPrintZ("%s.dxil", output).ptr)};
    const char *var_names[] = {a->allocPrintZ("%s_spv", var_prefix).ptr,
                               a->allocPrintZ("%s_dxil", var_prefix).ptr};
    return binToHpp(a, inputs, output, var_names);
}
