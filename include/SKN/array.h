#ifndef SKN_ARRAY_H
#define SKN_ARRAY_H

#include <SKN/types.h>
#include <assert.h>

#ifdef __cplusplus
#define DEFINE_DYNAMIC_ARRAY(NAME, TYPE)                                                                               \
    typedef struct NAME                                                                                                \
    {                                                                                                                  \
        TYPE *items{};                                                                                                 \
        usize capacity{};                                                                                              \
        usize len{};                                                                                                   \
    } NAME
#else
#define DEFINE_DYNAMIC_ARRAY(NAME, TYPE)                                                                               \
    typedef struct NAME                                                                                                \
    {                                                                                                                  \
        TYPE *items;                                                                                                   \
        usize capacity;                                                                                                \
        usize len;                                                                                                     \
    } NAME
#endif

// ARRAY must be pointer
#define DYNAMIC_ARRAY_ADD(ARENA, ARRAY, VALUE)                                                                         \
    do                                                                                                                 \
    {                                                                                                                  \
        usize index = (ARRAY)->len;                                                                                    \
        if (index >= (ARRAY)->capacity)                                                                                \
        {                                                                                                              \
            if ((ARRAY)->capacity == 0)                                                                                \
            {                                                                                                          \
                (ARRAY)->capacity = 8;                                                                                 \
            }                                                                                                          \
            else                                                                                                       \
            {                                                                                                          \
                (ARRAY)->capacity *= 2;                                                                                \
            }                                                                                                          \
            (ARRAY)->items = arena_realloc(ARRAY, (ARRAY)->items, sizeof(VALUE) * (ARRAY)->index,                      \
                                           sizeof(VALUE) * (ARRAY)->capacity);                                         \
        }                                                                                                              \
        (ARRAY)->items[index] = VALUE;                                                                                 \
        (ARRAY)->len++;                                                                                                \
    } while (0)

#define DYNAMIC_ARRAY_IMPL_ADD(ARRAY_TYPE, TYPE, NAME)                                                                 \
    static void NAME(Arena *arena, ARRAY_TYPE *array, TYPE value)                                                      \
    {                                                                                                                  \
        usize index = array->len;                                                                                      \
        if (index >= array->capacity)                                                                                  \
        {                                                                                                              \
            if (array->capacity == 0)                                                                                  \
                array->capacity = 8;                                                                                   \
            else                                                                                                       \
                array->capacity *= 2;                                                                                  \
            array->items =                                                                                             \
                (TYPE *)arena_realloc(arena, array->items, sizeof(TYPE) * index, sizeof(TYPE) * array->capacity);      \
        }                                                                                                              \
        array->items[index] = value;                                                                                   \
        array->len++;                                                                                                  \
    }

#define DYNAMIC_ARRAY_IMPL_SWAP_REMOVE(ARRAY_TYPE, NAME)                                                               \
    /* Replace element at index with last element and reduce size */                                                   \
    static void NAME(ARRAY_TYPE *array, usize index)                                                                   \
    {                                                                                                                  \
        usize last_index = array->len - 1;                                                                             \
        assert(index <= last_index);                                                                                   \
        if (last_index != index)                                                                                       \
        {                                                                                                              \
            array->items[index] = array->items[last_index];                                                            \
        }                                                                                                              \
        array->len -= 1;                                                                                               \
    }

#endif /* end of include guard: SKN_ARRAY_H */
