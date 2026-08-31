#include "include/sakana/sakana.hpp"

#include <assert.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

time_t getModifiedTime(const char *filename) {
    struct stat statbuf;
    if (stat(filename, &statbuf) != 0) {
        return 0;
    }
    return statbuf.st_mtim.tv_sec;
}

bool needsUpdate(const char *input, const char *output) {
    auto input_time = getModifiedTime(input);
    if (input_time == 0) {
        printf("error: file %s dosen't exist\n", input);
        abort();
    }
    return input_time > getModifiedTime(output);
}

bool needsUpdate(const char *output, const char *const inputs[]) {
    const auto output_time = getModifiedTime(output);
    for (const char *const *input = inputs; *input != 0; ++input) {
        auto input_time = getModifiedTime(*input);
        if (input_time == 0) {
            printf("error: file %s dosen't exist\n", *input);
            abort();
        }
        if (input_time > output_time) {
            return true;
        }
    }
    return false;
}

void run(const char *args[]) {
    assert(args[0] != 0);
    printf("run:");
    for (i32 i = 0; args[i] != 0; i++) printf(" %s", args[i]);
    printf("\n");

    auto pid = fork();
    assert(pid != -1);
    if (pid == 0) {
        assert(execvp(args[0], (char **)args) != -1);
        _exit(1);
    } else {
        i32 status = 0;
        wait(&status);
        assert(status == 0);
    }
}

void glslc(const char *input, const char *output) {
    if (needsUpdate(input, output)) {
        const char *args[] = {"glslc", input, "-o", output, 0};
        run(args);
    }
}

SliceU8 loadFile(const char *filename) {
    auto *stream = fopen(filename, "r");
    defer(assert(fclose(stream) == 0));

    assert(stream != 0);
    assert(fseek(stream, 0, SEEK_END) == 0);
    auto position = ftell(stream);
    assert(position != -1);
    auto n = (usize)position;
    assert(fseek(stream, 0, SEEK_SET) == 0);
    auto *data = (u8 *)malloc(n);
    assert(fread(data, sizeof(char), n, stream) == n);

    return SliceU8{data, n};
}

void binToHpp(const char *input, const char *output, const char *var_name) {
    if (needsUpdate(input, output)) {
        printf("generate %s from %s\n", output, input);

        auto data = loadFile(input);
        defer(free(data.ptr));

        auto *stream = fopen(output, "w");
        defer(assert(fclose(stream) == 0));
        assert(stream);

        assert(fprintf(stream, "#include <sakana/sakana.hpp>\n\n") >= 0);

        assert(fprintf(stream, "const u8 %s_raw[] = {\n    ", var_name) >= 0);

        for (usize i = 0; i < data.len; i++) {
            if (i == 0) {
                assert(fprintf(stream, "0x%02x,", data.ptr[i]) >= 0);
            } else {
                if (i % 15 == 0) {
                    assert(fprintf(stream, "\n   ") >= 0);
                }
                assert(fprintf(stream, " 0x%02x", data.ptr[i]) >= 0);
                if (i < data.len) {
                    assert(fprintf(stream, ",") >= 0);
                }
            }
        }

        assert(fprintf(stream, "\n};\n") >= 0);
        assert(fprintf(stream, "const SliceConstU8 %s = {.ptr = %s_raw, .len = %zu};", var_name,
                       var_name, data.len) >= 0);
    }
}

void addArg(const char *args[], usize capacity, usize *args_len, const char *arg) {
    assert(*args_len < capacity);
    args[(*args_len)++] = arg;
}

i32 main([[maybe_unused]] i32 argc, const char *argv[]) {
    mkdir("./build", 0755);

    const auto *bin_filename = argv[0];
    if (needsUpdate("build.cpp", bin_filename)) {
        printf("Self-rebuild\n");
        const char *clangpp_args[] = {"clang++", "build.cpp", "-o", bin_filename, 0};
        run(clangpp_args);
        const char *build_args[] = {bin_filename, 0};
        run(build_args);
        return 0;
    }
    glslc("src/shader.vert", "build/shader.vert.spv");
    glslc("src/shader.frag", "build/shader.frag.spv");
    binToHpp("build/shader.vert.spv", "build/shader.vert.cpp", "shader_vert_code");
    binToHpp("build/shader.frag.spv", "build/shader.frag.cpp", "shader_frag_code");

    const char *output = "build/sakana.o";
    const char *const inputs[] = {"src/sakana.cpp", "build/shader.frag.cpp",
                                  "build/shader.vert.cpp", "include/sakana/sakana.hpp", 0};
    if (needsUpdate(output, inputs)) {
        const usize ARGS_CAPACITY = 1U << 4U;
        const char *args[ARGS_CAPACITY];
        usize args_len = 0;
        addArg(args, ARGS_CAPACITY, &args_len, "clang++");
        addArg(args, ARGS_CAPACITY, &args_len, "-c");
        addArg(args, ARGS_CAPACITY, &args_len, inputs[0]);
        addArg(args, ARGS_CAPACITY, &args_len, "-o");
        addArg(args, ARGS_CAPACITY, &args_len, output);
        auto compile_flags = loadFile("compile_flags.txt");
        defer(free(compile_flags.ptr));
        usize start = 0;
        for (usize i = 0; i < compile_flags.len; i++) {
            if (compile_flags.ptr[i] == '\n') {
                compile_flags.ptr[i] = 0;
                addArg(args, ARGS_CAPACITY, &args_len, (char *)(compile_flags.ptr + start));
                start = i + 1;
            }
        }
        addArg(args, ARGS_CAPACITY, &args_len, 0);
        run(args);
    }

    const char *tidy_args[] = {"clang-tidy", "src/sakana.cpp", 0};
    run(tidy_args);

    return 0;
}
