#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include "SKN/arena.h"

Arena arena_create(size_t size)
{
    return (Arena){.data = malloc(size), .size = size};
}

void arena_destroy(Arena *arena)
{
    free(arena->data);
}

void *arena_push(Arena *arena, size_t size)
{
    size_t next_position = arena->position + size;
    assert(next_position <= arena->size);
    size_t position = arena->position;
    arena->position = next_position;
    return (void *)(arena->data + position);
}

void *arena_push_zero(Arena *arena, size_t size)
{
    void *data = arena_push(arena, size);
    memset(data, 0, size);
    return data;
}
