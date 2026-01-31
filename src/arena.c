#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include "SKN/arena.h"

Arena arena_create(usize size)
{
    return (Arena){.data = malloc(size), .size = size};
}

void arena_destroy(Arena *arena)
{
    free(arena->data);
}

void *arena_push(Arena *arena, usize size)
{
    usize next_position = arena->position + size;
    assert(next_position <= arena->size);
    usize position = arena->position;
    arena->position = next_position;
    return (void *)(arena->data + position);
}

void *arena_push_zero(Arena *arena, usize size)
{
    void *data = arena_push(arena, size);
    memset(data, 0, size);
    return data;
}

usize arena_quick_save(Arena *arena)
{
    return arena->position;
}

void arena_quick_load(Arena *arena, usize save)
{
    if (save == arena->position)
    {
        return;
    }
    usize diff = arena->position - save;
    arena->position = save;
    arena->size -= diff;
}
