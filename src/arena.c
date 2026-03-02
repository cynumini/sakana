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

usize align_forward(usize ptr, usize align)
{
    // is power of two
    assert((align & (align - 1)) == 0);

    // ptr % align == ptr & (align - 1)
    usize modulo = ptr & (align - 1);

    if (modulo != 0)
    {
        ptr += align - modulo;
    }
    return ptr;
}

void *arena_push_align(Arena *arena, size_t size, size_t align)
{
    usize curr_ptr = (usize)arena->data + arena->curr_offset;
    usize offset = align_forward(curr_ptr, align);
    offset -= (usize)arena->data;
    assert(offset + size <= arena->size);
    arena->prev_offset = offset;
    arena->curr_offset = offset + size;
    return (void *)&arena->data[offset];
}

void *arena_push(Arena *arena, usize size)
{
    return arena_push_align(arena, size, 2 * sizeof(void *));
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
    else if (p == (void *)(arena->data + arena->prev_offset))
    {
        arena->curr_offset = arena->prev_offset + new_size;
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
    return (ArenaSave){arena->prev_offset, arena->curr_offset};
}

void arena_quick_load(Arena *arena, ArenaSave save)
{
    arena->prev_offset = save.prev_offset;
    arena->curr_offset = save.curr_offset;
}

char *arena_strdup(Arena *arena, const char *src)
{
    usize len = strlen(src);
    char *dest = arena_push(arena, len + 1);
    strcpy(dest, src);
    return dest;
}

char *arena_strndup(Arena *arena, const char *src, usize len)
{
    char *dest = arena_push_zero(arena, len + 1);
    memcpy(dest, src, len);
    return dest;
}
