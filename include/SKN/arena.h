#ifndef SKN_ARENA_H
#define SKN_ARENA_H

#include "types.h"


typedef struct Arena
{
    u8 *data;
    usize prev_offset;
    usize curr_offset;
    usize size;
} Arena;

typedef struct ArenaSave
{
    usize prev_offset;
    usize curr_offset;
} ArenaSave;

Arena arena_create(usize size);
void arena_destroy(Arena *arena);
void *arena_push_align(Arena *arena, size_t size, size_t align);
void *arena_push(Arena *arena, usize size);
void *arena_push_zero(Arena *arena, usize size);
void *arena_realloc(Arena *arena, void *p, usize old_size, usize new_size);
ArenaSave arena_quick_save(Arena *arena);
void arena_quick_load(Arena *arena, ArenaSave save);
char *arena_strdup(Arena *arena, const char *src);
char *arena_strndup(Arena *arena, const char *src, usize len);

#define ARENA_PUSH_STRUCT(ARENA, TYPE) (TYPE *)arena_push(ARENA, sizeof(TYPE))
#define ARENA_PUSH_STRUCT_ZERO(ARENA, TYPE) (TYPE *)arena_push_zero(ARENA, sizeof(TYPE))

#define KB(VALUE) (VALUE << 10)
#define MB(VALUE) (KB(VALUE) << 10)
#define GB(VALUE) (MB(VALUE) << 10)

#endif /* end of include guard: SKN_ARENA_H */
