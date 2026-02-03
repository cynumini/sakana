#ifndef SKN_ARRAY_H
#define SKN_ARRAY_H

#include <SKN/types.h>

#define DEFINE_DYNAMIC_ARRAY(NAME, TYPE)                                                                               \
    typedef struct NAME                                                                                                \
    {                                                                                                                  \
        TYPE *items;                                                                                                   \
        usize capacity;                                                                                                \
        usize len;                                                                                                     \
    } NAME

// ARRAY must be pointer
#define DYNAMIC_ARRAY_ADD(ARENA, ARRAY, VALUE)                                                                         \
    {                                                                                                                  \
        usize index = (ARRAY)->len;                                                                                    \
        if (index >= (ARRAY)->capacity)                                                                                \
        {                                                                                                              \
            if ((ARRAY)->capacity == 0)                                                                                \
                (ARRAY)->capacity = 8;                                                                                 \
            else                                                                                                       \
                (ARRAY)->capacity *= 2;                                                                                \
            (ARRAY)->items = arena_realloc(ARRAY, (ARRAY)->items, sizeof(VALUE) * (ARRAY)->index,                      \
                                           sizeof(VALUE) * (ARRAY)->capacity);                                         \
        }                                                                                                              \
        (ARRAY)->items[index] = VALUE;                                                                                 \
        (ARRAY)->len++;                                                                                                \
    }

#define DYNAMIC_ARRAY_IMPL_STATIC(ARRAY_TYPE, TYPE, PREFIX)                                                            \
    static void PREFIX##_add(Arena *arena, ARRAY_TYPE *array, TYPE value)                                               \
    {                                                                                                                  \
        usize index = array->len;                                                                                      \
        if (index >= array->capacity)                                                                                  \
        {                                                                                                              \
            if (array->capacity == 0)                                                                                  \
                array->capacity = 8;                                                                                   \
            else                                                                                                       \
                array->capacity *= 2;                                                                                  \
            array->items =                                                                                             \
                arena_realloc(arena, array->items, sizeof(TYPE) * index, sizeof(TYPE) * array->capacity);       \
        }                                                                                                              \
        array->items[index] = value;                                                                                   \
        array->len++;                                                                                                  \
    }

#endif /* end of include guard: SKN_ARRAY_H */
