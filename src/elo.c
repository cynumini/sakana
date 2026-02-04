#include <SKN/elo.h>

#include <math.h>

Elo elo_update(f64 r1, f64 r2, EloResult result, f64 k)
{
    f64 r = (f64)result * 0.5;
    f64 expected1 = 1.0 / (1.0 + pow(10.0, (r2 - r1) / 400.0));
    f64 expected2 = 1.0 - expected1;
    return (Elo){
        .r1 = r1 + k * (r - expected1),
        .r2 = r2 + k * ((1 - r) - expected2),
    };
}
