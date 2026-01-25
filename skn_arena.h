/* skn_arena - v0.1

One of your module must have an implementation (main.c for example). The code
below show how to define implementation:

#define SKN_ARENA_IMPLEMENTATION
#include "skn_arena.h"

After that just include the header like this:

#include "skn_arena.h" */

#ifndef SKN_ARENA_H
#define SKN_ARENA_H

#include <stddef.h>
#include <stdint.h>

typedef struct Arena {
  uint8_t *data;
  size_t position;
  size_t size;
} Arena;

Arena arena_create(size_t size);
void arena_destroy(Arena *arena);
void *arena_push(Arena *arena, size_t size);
void *arena_push_zero(Arena *arena, size_t size);

#define ARENA_PUSH_STRUCT(ARENA, TYPE) (TYPE *)arena_push(ARENA, sizeof(TYPE))
#define ARENA_PUSH_STRUCT_ZERO(ARENA, TYPE)                                    \
  (TYPE *)arena_push_zero(ARENA, sizeof(TYPE))

#endif /* end of include guard: SKN_ARENA_H */

// #define SKN_ARENA_IMPLEMENTATION // for syntax highlight
#ifdef SKN_ARENA_IMPLEMENTATION

#include <assert.h>
#include <stdlib.h>
#include <string.h>

Arena arena_create(size_t size) {
  void *data = malloc(size);
  return (Arena){.data = data, .size = size};
}

void arena_destroy(Arena *arena) { free(arena->data); }

void *arena_push(Arena *arena, size_t size) {
  size_t next_position = arena->position + size;
  assert(next_position <= arena->size);
  size_t position = arena->position;
  arena->position = next_position;
  return (void *)(arena->data + position);
}

void *arena_push_zero(Arena *arena, size_t size) {
  void *data = arena_push(arena, size);
  memset(data, 0, size);
  return data;
}
#endif
