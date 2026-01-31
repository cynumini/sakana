#include <SKN/filesystem.h>

#include <assert.h>
#include <stdio.h>

char *read_text(Arena *arena, const char *path)
{
    FILE *file = fopen(path, "r");
    assert(file);
    assert(fseek(file, 0, SEEK_END) == 0);
    long size = ftell(file);
    assert(size != -1);
    rewind(file);
    char *buffer = arena_push(arena, size + 1);
    assert(buffer);
    assert(fread(buffer, 1, size, file) == (size_t)size);
    assert(fclose(file) == 0);
    buffer[size] = '\0';
    return buffer;
}
