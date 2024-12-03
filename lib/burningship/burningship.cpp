#include "burningship.h"
#include <vector>
#include <cmath>
#include <cstdint>
#include <algorithm>

extern "C" {

    uint8_t* burningshipSet(double xMin, double xMax, double yMin, double yMax,
                            double realP, double imagP, int width, int height,
                            int escapeRadius, int maxIters) {
        double dx = (xMax - xMin) / (width - 1);
        double dy = (yMax - yMin) / (height - 1);

        // Allocate memory for the result
        uint8_t* pixels = new uint8_t[width * height];

        #pragma omp parallel for // Use OpenMP for parallelization (if supported)
        for (int i = 0; i < height; i++) {
            for (int j = 0; j < width; j++) {
                double cx = xMin + j * dx;
                double cy = yMin + i * dy;
                double zx = cx, zy = cy;

                int escapeCount;
                for (escapeCount = 0; escapeCount < maxIters; escapeCount++) {
                    if (zx * zx + zy * zy > escapeRadius * escapeRadius) break;

                    // Burning Ship fractal logic
                    double absZx = std::abs(zx);
                    double absZy = std::abs(zy);
                    double xtemp = absZx * absZx - absZy * absZy + cx;
                    zy = 2 * absZx * absZy + cy;
                    zx = xtemp;
                }

                // Smooth coloring
                double smoothValue = escapeCount;
                if (zx * zx + zy * zy > 1.0) {
                    smoothValue += 1 - std::log(std::log(std::sqrt(zx * zx + zy * zy))) / std::log(2);
                }

                // Normalize to [0, 255] range
                double stability = std::clamp(smoothValue / maxIters, 0.0, 1.0);
                pixels[i * width + j] = static_cast<uint8_t>(stability * 255);
            }
        }

        // Return the pointer to the allocated array
        return pixels;
    }

    void freePixels(uint8_t* pixels) {
        delete[] pixels;
    }
}
