#include "sakana.cpp"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <unistd.h>

#define CXX "clang++"

static time_t getModifiedTime(const char *filename) {
    struct stat buf;
    if (stat(filename, &buf) != 0) return 0;
    return buf.st_mtim.tv_sec;
}

static bool needsUpdate(const char *output, const char *input) {
    auto input_time = getModifiedTime(input);
    if (input_time == 0) {
        printf("error: file %s dosen't exist\n", input);
        abort();
    }
    return input_time > getModifiedTime(output);
}

// static bool needsUpdate(const char *output, const char *const inputs[]) {
//     const auto output_time = getModifiedTime(output);
//     for (const char *const *input = inputs; *input != 0; ++input) {
//         auto input_time = getModifiedTime(*input);
//         if (input_time == 0) {
//             printf("error: file %s dosen't exist\n", *input);
//             abort();
//         }
//         if (input_time > output_time) {
//             return true;
//         }
//     }
//     return false;
// }

const usize ARGS_CAPACITY = 1U << 4U;

struct Args {
    usize capacity = ARGS_CAPACITY;
    const char *data[ARGS_CAPACITY + 1]; // +1 for sentinel
    usize len = 0;
};

static void runReplace(Args args) {
    assert(args.data[0] != 0);
    printf("run:");
    for (i32 i = 0; args.data[i] != 0; i++) printf(" %s", args.data[i]);
    printf("\n");
    execvp(args.data[0], (char **)args.data);
    perror("errno");
}

static void run(Args args) {
    auto pid = fork();
    assert(pid != -1);
    if (pid == 0) {
       runReplace(args);
       _exit(1);
    } else {
        i32 status = 0;
        wait(&status);
        assert(status == 0);
    }
}

static void addArg(Args *args, const char *arg) {
    assert(args->len < args->capacity);
    args->data[args->len++] = arg;
    args->data[args->len] = 0;
}

static void rebuildAndRestartOnChanges(i32 argc, const char *argv[]) {
    assert(argc >= 1);
    mkdir("./build", 0755);

    const auto *bin_filename = argv[0];

    if (needsUpdate(bin_filename, "b.cpp")) {
        printf("b.cpp: self-rebuild\n");

        Args cxx_args{};
        addArg(&cxx_args, CXX);
        addArg(&cxx_args, "b.cpp");
        addArg(&cxx_args, "-o");
        addArg(&cxx_args, bin_filename);
        run(cxx_args);

        Args b_args{};
        addArg(&b_args, bin_filename);
        runReplace(b_args);

    }
}

static void glslc(const char *input, const char *output) {
    if (needsUpdate(output, input)) {
        Args args{};
        addArg(&args, "glslc");
        addArg(&args, input);
        addArg(&args, "-o");
        addArg(&args, output);
        run(args);
    }
}

static void addArgsFromCompileFlags(Args *args, SliceU8 compile_flags) {
    usize start = 0;
    for (usize i = 0; i < compile_flags.len; i++) {
        if (compile_flags.ptr[i] == '\n') {
            compile_flags.ptr[i] = 0;
            addArg(args, (char *)(compile_flags.ptr + start));
            start = i + 1;
        }
    }
}

static SliceU8 loadFile(const char *filename) {
    auto *stream = fopen(filename, "r");
    assert(stream);
    defer(assert(fclose(stream) == 0));

    assert(fseek(stream, 0, SEEK_END) == 0);

    auto position = ftell(stream);
    assert(position != -1);
    auto n = (usize)position;

    assert(fseek(stream, 0, SEEK_SET) == 0);

    auto *data = (u8 *)malloc(n);

    assert(fread(data, sizeof(char), n, stream) == n);

    return SliceU8{data, n};
}

// static void binToHpp(const char *input, const char *output, const char *var_name) {
//     if (needsUpdate(output, input)) {
//         printf("generate %s from %s\n", output, input);

//         auto data = loadFile(input);
//         defer(free(data.ptr));

//         auto *stream = fopen(output, "w");
//         assert(stream);
//         defer(assert(fclose(stream) == 0));

//         assert(fprintf(stream, "#include <sakana/sakana.hpp>\n\n") >= 0);
//         assert(fprintf(stream, "const u8 %s_raw[] = {\n    ", var_name) >= 0);

//         for (usize i = 0; i < data.len; i++) {
//             if (i == 0) {
//                 assert(fprintf(stream, "0x%02x,", data.ptr[i]) >= 0);
//             } else {
//                 if (i % 15 == 0) {
//                     assert(fprintf(stream, "\n   ") >= 0);
//                 }
//                 assert(fprintf(stream, " 0x%02x", data.ptr[i]) >= 0);
//                 if (i < data.len) {
//                     assert(fprintf(stream, ",") >= 0);
//                 }
//             }
//         }

//         assert(fprintf(stream, "\n};\n") >= 0);
//         assert(fprintf(stream, "const SliceConstU8 %s = {.ptr = %s_raw, .len = %zu};", var_name,
//                        var_name, data.len) >= 0);
//     }
// }
