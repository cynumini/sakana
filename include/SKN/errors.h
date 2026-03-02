#include <stdio.h>
#include <stdlib.h>

#define ERROR(FORMAT, ...)                                                                                             \
    do                                                                                                                 \
    {                                                                                                                  \
        fprintf(stderr, "%s:%i:%i: runtime error: " FORMAT, __FILE__, __LINE__, 0, __VA_ARGS__);                       \
        abort();                                                                                                       \
    } while (0)

#define UNREACHABLE()                                                                                                  \
    do                                                                                                                 \
    {                                                                                                                  \
        fprintf(stderr, "%s:%i:%i: unreachable\n", __FILE__, __LINE__, 0);                                             \
        abort();                                                                                                       \
    } while (0)
