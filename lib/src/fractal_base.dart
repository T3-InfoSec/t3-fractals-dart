import 'dart:math';
import 'dart:typed_data';

import 'package:complex/complex.dart';

/// The `Fractal` class generates fractals based on a specified function type
/// (e.g., Burning Ship). It contains methods for generating and updating
/// fractals, as well as managing the image pixel data that represents the fractal.
///
/// Example usage:
/// ```dart
/// var fractal = Fractal();
/// fractal.update(funcType: Fractal.burningShip, width: 1024, height: 1024);
/// var pixels = fractal.imagePixels;
/// ```
class Fractal {
  /// The constant for the burning ship fractal type.
  static const String burningShip = 'burningship';

  // Fractal properties
  String funcType;
  double? xMin;
  double? xMax;
  double? yMin;
  double? yMax;
  double? realP;
  double? imagP;
  int? width;
  int? height;
  int? escapeRadius;
  int? maxIters;

  // Internal variable for holding image pixels
  Uint8List? _imagePixels;

  /// A getter for accessing the image pixel data.
  ///
  /// This provides the pixel data representing the generated fractal.
  ///
  /// Returns:
  /// - A [Uint8List] containing the pixel data for the fractal image.
  Uint8List? get imagePixels => _imagePixels;

  /// Constructor for initializing the fractal with optional parameters.
  /// Defaults are set for the fractal parameters.
  ///
  /// Parameters:
  /// - [funcType]: The function type for generating the fractal. Defaults to [Fractal.burningShip].
  /// - [xMin]: Minimum x-coordinate for the fractal plane.
  /// - [xMax]: Maximum x-coordinate for the fractal plane.
  /// - [yMin]: Minimum y-coordinate for the fractal plane.
  /// - [yMax]: Maximum y-coordinate for the fractal plane.
  /// - [realP]: Real component of the fractal's power function.
  /// - [imagP]: Imaginary component of the fractal's power function.
  /// - [width]: Width of the image in pixels.
  /// - [height]: Height of the image in pixels.
  /// - [escapeRadius]: Escape radius for fractal iteration.
  /// - [maxIters]: Maximum iterations for fractal generation.
  Fractal({
    this.funcType = burningShip,
    this.xMin,
    this.xMax,
    this.yMin,
    this.yMax,
    this.realP,
    this.imagP,
    this.width,
    this.height,
    this.escapeRadius,
    this.maxIters,
  });

  /// Updates the fractal parameters and regenerates the fractal image.
  ///
  /// The updated parameters are used to recreate the fractal set. If a parameter
  /// is not provided, it retains its current value.
  ///
  /// Parameters:
  /// - [funcType]: The function type for generating the fractal (optional).
  /// - [xMin], [xMax], [yMin], [yMax]: Coordinates defining the fractal's plane.
  /// - [realP], [imagP]: Real and imaginary components of the fractal's power function.
  /// - [width], [height]: The dimensions of the output fractal image.
  /// - [escapeRadius]: The escape radius used during the fractal iteration.
  /// - [maxIters]: The maximum number of iterations to compute the fractal.
  ///
  /// Throws [ArgumentError] if an unsupported fractal function is specified.
  void update({
    String? funcType,
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
    double? realP,
    double? imagP,
    int? width,
    int? height,
    int? escapeRadius,
    int? maxIters,
  }) {
    // Update parameters if provided
    this.xMin = xMin;
    this.xMax = xMax;
    this.yMin = yMin;
    this.yMax = yMax;
    this.realP = realP;
    this.imagP = imagP;
    this.width = width;
    this.height = height;
    this.escapeRadius = escapeRadius;
    this.maxIters = maxIters;
    this.funcType = funcType ?? this.funcType;

    // Generate fractal based on the selected function type
    if (this.funcType == burningShip) {
      _imagePixels = burningshipSet();
    } else {
      throw ArgumentError('$funcType is not supported.');
    }
  }

  /// Calculates a smooth stability value for the fractal rendering.
  ///
  /// This is used for anti-aliasing, which helps to generate a smoother boundary
  /// between regions of different fractal colors, resulting in a visually appealing image.
  ///
  /// Parameters:
  /// - [z]: The complex number representing the current point in the fractal.
  /// - [escapeCount]: The number of iterations before the point escapes the fractal set.
  /// - [maxIters]: The maximum number of iterations allowed.
  ///
  /// Returns:
  /// - A double representing the smooth stability value, clamped between 0.0 and 1.0.
  double _smoothStability(Complex z, int escapeCount, int maxIters) {
    var smoothValue = escapeCount + 1 - log(log(z.abs())) / log(2);
    var stability = smoothValue / maxIters;
    return stability.clamp(0.0, 1.0);
  }

  /// Generates the Burning Ship fractal set and returns the pixel data.
  ///
  /// This method calculates the fractal set for the Burning Ship function, an
  /// iterated function system known for its distinctive "ship-like" appearance.
  ///
  /// Parameters:
  /// - [xMin], [xMax], [yMin], [yMax]: Coordinates defining the fractal's plane.
  /// - [realP], [imagP]: Real and imaginary components of the fractal's power function.
  /// - [width], [height]: The dimensions of the output fractal image.
  /// - [escapeRadius]: The escape radius used during the fractal iteration.
  /// - [maxIters]: The maximum number of iterations to compute the fractal.
  ///
  /// Returns:
  /// - A [Uint8List] containing the pixel data for the generated fractal image.
  Uint8List burningshipSet({
    double xMin = -2.5,
    double xMax = 2.0,
    double yMin = -2,
    double yMax = 0.8,
    double realP = 2.0,
    double imagP = 0.0,
    int width = 1024,
    int height = 1024,
    int escapeRadius = 4,
    int maxIters = 30,
  }) {
    // Use the class's properties if they're not null
    xMin = this.xMin ?? xMin;
    xMax = this.xMax ?? xMax;
    yMin = this.yMin ?? yMin;
    yMax = this.yMax ?? yMax;
    realP = this.realP ?? realP;
    imagP = this.imagP ?? imagP;
    width = this.width ?? width;
    height = this.height ?? height;
    escapeRadius = this.escapeRadius ?? escapeRadius;
    maxIters = this.maxIters ?? maxIters;

    // Create x and y coordinates for the image plane
    final x = List.generate(
        width, (int idx) => xMin + (xMax - xMin) * idx / (width - 1));
    final y = List.generate(
        height, (int idx) => yMin + (yMax - yMin) * idx / (height - 1));

    // Initialize pixel data array
    final pixels = Uint8List(width * height);

    // Iterate through each pixel to compute the fractal
    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        // Complex number for the current point
        var c = Complex(x[j], y[i]);
        // Initial value of z
        var z = c;
        for (int escapeCount = 0; escapeCount < maxIters; escapeCount++) {
          // Check if the point has escaped the set
          if (z.abs() > escapeRadius) {
            // Assign color based on stability of the point
            pixels[i * width + j] =
                (_smoothStability(z, escapeCount, maxIters) * 255).toInt();
            break;
          }
          z = Complex(z.real.abs(), z.imaginary.abs())
                  .power(Complex(realP, imagP)) +
              c;
        }
        // Ensure the pixel value is correctly assigned
        pixels[i * width + j] = pixels[i * width + j];
      }
    }
    // Return the generated pixel data
    return pixels;
  }
}
