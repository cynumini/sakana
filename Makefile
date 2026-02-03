warnings = -Wall -Wpedantic -Wextra -Werror

objects = $(addprefix ./out/,filesystem.o arena.o)

./out/libsakana.a: $(objects)
	$(AR) -rc $@ $^

./out/%.o: ./src/%.c
	-mkdir -p ./out
	$(CC) -g -c -Iinclude $< -o $@

.PHONY: clean

clean:
	rm -rf ./out

