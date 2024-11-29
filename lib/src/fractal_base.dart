import 'dart:math';
import 'dart:typed_data';

import 'package:complex/complex.dart';

/// The `Fractal` class generates fractals based on different mathematical functions,
/// such as the Burning Ship fractal. It provides methods for generating and updating
/// the fractal image based on configurable parameters.
class Fractal {
  /// The constant for the Burning Ship fractal type.
  static const String burningShip = 'burningship';

  // Fractal properties
  String funcType;
  double xMin;
  double xMax;
  double yMin;
  double yMax;
  double realP;
  double imagP;
  int width;
  int height;
  int escapeRadius;
  int maxIters;

  // Internal variable for holding image pixels
  Uint8List? _imagePixels;

  /// Provides the pixel data representing the generated fractal.
  Uint8List? get imagePixels => _imagePixels;

  /// Constructs a [Fractal] with customizable parameters.
  ///
  /// The [realP] and [imagP] parameters are mandatory, as they define the
  /// real and imaginary parts of the power function used in the fractal's calculations.
  /// Other parameters, such as the boundaries of the fractal's plane ([xMin], [xMax], [yMin], [yMax]),
  /// image dimensions ([width], [height]), and computation settings ([escapeRadius], [maxIters]),
  /// have sensible defaults but can be overridden.
  Fractal({
    this.funcType = burningShip,
    this.xMin = -2.5,
    this.xMax = 2.0,
    this.yMin = -2.0,
    this.yMax = 0.8,
    required this.realP,
    required this.imagP,
    this.width = 1024,
    this.height = 1024,
    this.escapeRadius = 4,
    this.maxIters = 30,
  });

  /// Updates the fractal parameters and regenerates the fractal image.
  ///
  /// This method allows dynamic reconfiguration of the fractal's properties.
  /// If a parameter is not provided, its previous value is retained.
  /// For example, you can adjust only the image dimensions ([width], [height])
  /// while keeping the mathematical parameters unchanged.
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
    this.funcType = funcType ?? this.funcType;
    this.xMin = xMin ?? this.xMin;
    this.xMax = xMax ?? this.xMax;
    this.yMin = yMin ?? this.yMin;
    this.yMax = yMax ?? this.yMax;
    this.realP = realP ?? this.realP;
    this.imagP = imagP ?? this.imagP;
    this.width = width ?? this.width;
    this.height = height ?? this.height;
    this.escapeRadius = escapeRadius ?? this.escapeRadius;
    this.maxIters = maxIters ?? this.maxIters;

    // Generate fractal based on the selected function type
    if (this.funcType == burningShip) {
      _imagePixels = burningshipSet();
    } else {
      throw ArgumentError('$funcType is not supported.');
    }
  }

  /// Calculates a smooth stability value for improved fractal rendering.
  ///
  /// This smooth value ensures visually appealing gradients at the boundaries
  /// of the fractal's different regions.
  double _smoothStability(Complex z, int escapeCount, int maxIters) {
    var smoothValue = escapeCount + 1 - log(log(z.abs())) / log(2);
    var stability = smoothValue / maxIters;
    return stability.clamp(0.0, 1.0);
  }

  /// Generates the Burning Ship fractal set and returns the pixel data.
  ///
  /// The Burning Ship fractal is known for its unique "ship-like" appearance.
  /// This method iterates over each pixel of the image plane and determines
  /// whether the corresponding point escapes the fractal set, coloring the pixel accordingly.
  Uint8List burningshipSet() {
    // Create x and y coordinates for the image plane
    final x = List.generate(
        width, (int idx) => xMin + (xMax - xMin) * idx / (width - 1));
    final y = List.generate(
        height, (int idx) => yMin + (yMax - yMin) * idx / (height - 1));

    // Initialize pixel data array
    final pixels = Uint8List(width * height);

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        var c = Complex(x[j], y[i]);
        var z = c;
        for (int escapeCount = 0; escapeCount < maxIters; escapeCount++) {
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
    return pixels;
  }
}
