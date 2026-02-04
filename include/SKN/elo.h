#ifndef SKN_ELO_H
#define SKN_ELO_H

#include "types.h"

typedef struct Elo
{
    f64 r1;
    f64 r2;
} Elo;

typedef enum EloResult
{
    ELO_RESULT_LOSS,
    ELO_RESULT_DRAW,
    ELO_RESULT_WIN,
} EloResult;

Elo elo_update(f64 r1, f64 r2, EloResult result, f64 k);

#endif /* end of include guard: SKN_ELO_H */
