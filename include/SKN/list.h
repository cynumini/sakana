#ifndef SKN_LIST_H
#define SKN_LIST_H

#include "arena.h"

#define LIST_DEFINE(TYPE, NAME)                                                                                        \
    typedef struct NAME##Element                                                                                       \
    {                                                                                                                  \
        TYPE value;                                                                                                    \
        struct NAME##Element *next;                                                                                    \
    } NAME##Element;                                                                                                   \
                                                                                                                       \
    typedef struct NAME                                                                                                \
    {                                                                                                                  \
        NAME##Element *item;                                                                                           \
        size_t len;                                                                                                    \
    } NAME

#define LIST_APPEND(TYPE, ARENA, LIST, VALUE)                                                                          \
    do                                                                                                                 \
    {                                                                                                                  \
        if ((LIST)->item == NULL)                                                                                      \
        {                                                                                                              \
            (LIST)->item = ARENA_PUSH_STRUCT_ZERO(ARENA, TYPE##Element);                                               \
            (LIST)->item->value = VALUE;                                                                               \
        }                                                                                                              \
        else                                                                                                           \
        {                                                                                                              \
            TYPE##Element *next_child = (LIST)->item;                                                                  \
            while (next_child->next != NULL)                                                                           \
            {                                                                                                          \
                next_child = next_child->next;                                                                         \
            }                                                                                                          \
            next_child->next = ARENA_PUSH_STRUCT_ZERO(ARENA, TYPE##Element);                                           \
            next_child->next->value = VALUE;                                                                           \
        }                                                                                                              \
        (LIST)->len++;                                                                                                 \
    } while (0)

#define LIST_FOREACH(TYPE, ITEM, LIST) for (TYPE##Element *ITEM = LIST.item; ITEM != NULL; ITEM = ITEM->next)

#endif /* end of include guard: SKN_LIST_H */
