#include "build.cpp"

void binToHpp(const char *input, const char *output, const char *var_name) {
    if (needsUpdate(output, input)) {
        printf("generate %s from %s\n", output, input);

        auto data = loadFile(input);
        defer(free(data.ptr));

        auto *stream = fopen(output, "w");
        assert(stream);
        defer(assert(fclose(stream) == 0));

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

i32 main(i32 argc, const char *argv[]) {
    sakanaBuild(argc, argv);

    glslc("src/shader.vert", "build/shader.vert.spv");
    binToHpp("build/shader.vert.spv", "build/shader.vert.cpp", "shader_vert_code");

    glslc("src/shader.frag", "build/shader.frag.spv");
    binToHpp("build/shader.frag.spv", "build/shader.frag.cpp", "shader_frag_code");

    const char *output = "build/sakana.o";
    const char *const inputs[] = {"src/sakana.cpp", "build/shader.frag.cpp",
                                  "build/shader.vert.cpp", "include/sakana/sakana.hpp", 0};
    if (needsUpdate(output, inputs)) {
        Args args{};
        addArg(&args, CXX);
        addArg(&args, "-c");
        addArg(&args, inputs[0]);

        auto compile_flags = loadFile("compile_flags.txt");
        defer(free(compile_flags.ptr));
        addArgsFromCompileFlags(&args, compile_flags);

        addArg(&args, "-o");
        addArg(&args, output);
        run(args);
    }

    // const char *tidy_args[] = {"clang-tidy", "src/sakana.cpp", 0};
    // run(tidy_args);

    return 0;
}
