#ifndef SKN_FILESYSTEM_H
#define SKN_FILESYSTEM_H

#include "SKN/arena.h"

char *read_text(Arena *arena, const char *path);
void write_text(const char *path, const char *text);

#endif /* end of include guard: SKN_FILESYSTEM_H */
