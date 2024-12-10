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

    uint8_t** generateAnimation(int n, double xMin, double xMax, double yMin, double yMax,
                            double A, double B, double phi, int k, int l,
                            int width, int height, int escapeRadius, int maxIters) {
        // Allocate memory for the animation frames
        uint8_t** frames = new uint8_t*[n];

        #pragma omp parallel for // Use OpenMP for parallelization (if supported)
        for (int i = 0; i < n; i++) {
            // Compute the oscillating real and imaginary parts for each frame
            double rpi = A * std::cos(phi + 2 * M_PI * i * k / n);
            double ipi = B * std::sin(2 * M_PI * i * l / n);

            // Generate the fractal frame with the shifted real and imaginary parts
            frames[i] = burningshipSet(xMin, xMax, yMin, yMax, rpi, ipi, width, height, escapeRadius, maxIters);
        }

        return frames;
    }

    void freeAnimation(uint8_t** frames, int n) {
        for (int i = 0; i < n; i++) {
            delete[] frames[i];
        }
        delete[] frames;
    }
}
