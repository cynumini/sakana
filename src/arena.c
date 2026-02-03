#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

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
    arena->position = arena->next_position;
    arena->next_position = arena->position + size;
    assert(arena->next_position <= arena->size);
    return (void *)(arena->data + arena->position);
}

void *arena_push_zero(Arena *arena, usize size)
{
    void *data = arena_push(arena, size);
    memset(data, 0, size);
    return data;
}

void *arena_realloc(Arena *arena, void *p, usize old_size, usize new_size)
{
    if (p == NULL)
    {
        return arena_push(arena, new_size);
    }
    else if (p == (void *)(arena->data + arena->position))
    {
        arena->next_position = arena->position + new_size;
        return p;
    }
    else
    {
        void *new_p = arena_push(arena, new_size);
        memcpy(new_p, p, old_size);
        return new_p;
    }
}

ArenaSave arena_quick_save(Arena *arena)
{
    return (ArenaSave){arena->position, arena->next_position};
}

void arena_quick_load(Arena *arena, ArenaSave save)
{
    arena->position = save.position;
    arena->next_position = save.next_position;
}

char *arena_strdup(Arena *arena, const char *src)
{
    usize size = strlen(src);
    char *dest = arena_push(arena, size);
    strcpy(dest, src);
    return dest;
}
