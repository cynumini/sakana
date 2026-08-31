FLAGS := $(shell tr '\n' ' ' < compile_flags.txt)
SHADER_SRC := build/shader.frag.spv.hpp build/shader.vert.spv.hpp

build: build/libsakana.a

build/shader.vert.spv: src/shader.vert
	@mkdir -p build
	glslc $< -o $@

build/shader.frag.spv: src/shader.frag
	@mkdir -p build
	glslc $< -o $@

build/shader.vert.spv.hpp: build/shader.vert.spv
	@mkdir -p build
	xxd -i $< | sed 's/unsigned char/const unsigned char/g; s/unsigned int/const unsigned int/g' > $@

build/shader.frag.spv.hpp: build/shader.frag.spv
	@mkdir -p build
	xxd -i $< | sed 's/unsigned char/const unsigned char/g; s/unsigned int/const unsigned int/g' > $@

build/sakana.o: src/sakana.cpp include/sakana/sakana.hpp $(SHADER_SRC) compile_flags.txt
	@mkdir -p build
	clang++ -c src/sakana.cpp -o $@ $(FLAGS) -g

build/libsakana.a: build/sakana.o
		ar rcs $@ $<

tidy:
	clang-tidy src/sakana.cpp

clean:
	rm -rf build

.PHONY: all build clean
