#ifndef SKN_ARENA_H
#define SKN_ARENA_H

#include "types.h"

typedef struct Arena
{
    u8 *data;
    usize position;
    usize size;
} Arena;

Arena arena_create(usize size);
void arena_destroy(Arena *arena);
void *arena_push(Arena *arena, usize size);
void *arena_push_zero(Arena *arena, usize size);
usize arena_quick_save(Arena *arena);
void arena_quick_load(Arena *arena, usize save);

#define ARENA_PUSH_STRUCT(ARENA, TYPE) (TYPE *)arena_push(ARENA, sizeof(TYPE))
#define ARENA_PUSH_STRUCT_ZERO(ARENA, TYPE) (TYPE *)arena_push_zero(ARENA, sizeof(TYPE))

#define KB(VALUE) (VALUE << 10)
#define MB(VALUE) (KB(VALUE) << 10)
#define GB(VALUE) (MB(VALUE) << 10)

#endif /* end of include guard: SKN_ARENA_H */
