#ifndef FRACTAL_H
#define FRACTAL_H

#include <cstdint> // For uint8_t

#ifdef __cplusplus
extern "C" {
#endif

// Declaration of the function to generate the Burning Ship fractal
uint8_t* burningshipSet(double xMin, double xMax, double yMin, double yMax,
                           double realP, double imagP, int width, int height,
                           int escapeRadius, int maxIters);

// Declaration of the function to free allocated memory
void freePixels(uint8_t* pixels);

#ifdef __cplusplus
}
#endif

#endif // FRACTAL_H
