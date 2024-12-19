import 'dart:math';
import 'dart:typed_data';

import 'package:complex/complex.dart';
import 'dart:isolate';
import 'package:image/image.dart' as img;

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
  Future<Uint8List>? _imagePixels;

  /// A getter for accessing the image pixel data.
  ///
  /// This provides the pixel data representing the generated fractal.
  ///
  /// Returns:
  /// - A [Uint8List] containing the pixel data for the fractal image.
  Future<Uint8List>? get imagePixels => _imagePixels;

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
  /// Smooth stability value for anti-aliasing and smooth coloring.
  double _smoothStability(Complex z, int escapeCount, int maxIters) {
    var logZn = log(z.abs());
    var nu = log(logZn) / log(2);
    var smoothValue = escapeCount + 1 - nu;
    return smoothValue / maxIters;
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
  /// Smooth stability calculation for anti-aliasing

  /// Map stability to fire-like colors
  int _fireToWhiteColor(double stability) {
    int red = 0;
    int green = 0;
    int blue = 0;
    if (stability < 0.4) {
      // Fire glow: Black -> Red -> Orange
      red = (255 * pow(stability / 0.4, 1.0)).toInt();
      green = (127 * pow(stability / 0.4, 1.5)).toInt();
      blue = 0;
    } else if (stability < 0.8) {
      // Transition: Orange -> Yellow -> Light pastel
      red = 255;
      green = (255 * (stability - 0.4) / 0.4).toInt();
      blue = (200 * (stability - 0.4) / 0.4).toInt();
    } else {
      // Outside: Light pastel -> White
      double fadeToWhite = (stability - 0.8) / 0.2;
      red = 255;
      green = 255 - ((255 - green) * fadeToWhite).toInt();
      blue = 255 - ((255 - blue) * fadeToWhite).toInt();
    }

    return img.getColor(red, green, blue);
  }

  /// Generate the Burning Ship fractal image
  Future<Uint8List> _processSegment(Map<String, dynamic> args) async {
    final int startRow = args['startRow'];
    final int endRow = args['endRow'];
    final int width = args['width'];
    final int height = args['height'];
    final double xMin = args['xMin'];
    final double xMax = args['xMax'];
    final double yMin = args['yMin'];
    final double yMax = args['yMax'];
    final double realP = args['realP'];
    final double imagP = args['imagP'];
    final int escapeRadius = args['escapeRadius'];
    final int maxIters = args['maxIters'];

    final pixels = Uint8List(width * (endRow - startRow) * 4); // RGBA output

    for (int i = startRow; i < endRow; i++) {
      for (int j = 0; j < width; j++) {
        double x = xMin + (xMax - xMin) * j / (width - 1);
        double y = yMin + (yMax - yMin) * i / (height - 1);
        var c = Complex(x, y);
        var z = c;

        int color = 0xFF000000; // Default black for non-escaped
        for (int escapeCount = 0; escapeCount < maxIters; escapeCount++) {
          if (z.abs() > escapeRadius) {
            double stability =
                _smoothStability(z, escapeCount, maxIters).clamp(0.0, 1.0);
            color = _fireToWhiteColor(stability);
            break;
          }
          z = Complex(z.real.abs(), z.imaginary.abs())
                  .power(Complex(realP, imagP)) +
              c;
        }

        int pixelIndex = ((i - startRow) * width + j) * 4;
        pixels[pixelIndex] = (color >> 16) & 0xFF; // Red
        pixels[pixelIndex + 1] = (color >> 8) & 0xFF; // Green
        pixels[pixelIndex + 2] = color & 0xFF; // Blue
        pixels[pixelIndex + 3] = 255; // Alpha
      }
    }

    return pixels;
  }

  Future<Uint8List> burningshipSet({
    double xMin = -2.5,
    double xMax = 2.0,
    double yMin = -2,
    double yMax = 0.8,
    double realP = 2.0,
    double imagP = 0.0,
    int width = 500,
    int height = 500,
    int escapeRadius = 3,
    int maxIters = 100,
  }) async {
    const int numIsolates = 4; // Number of isolates to use
    int rowsPerIsolate = height ~/ numIsolates;
    List<Future<Uint8List>> futures = [];

    for (int i = 0; i < numIsolates; i++) {
      int startRow = i * rowsPerIsolate;
      int endRow = (i == numIsolates - 1) ? height : startRow + rowsPerIsolate;

      futures.add(Isolate.run(() => _processSegment({
            'startRow': startRow,
            'endRow': endRow,
            'width': width,
            'height': height,
            'xMin': xMin,
            'xMax': xMax,
            'yMin': yMin,
            'yMax': yMax,
            'realP': realP,
            'imagP': imagP,
            'escapeRadius': escapeRadius,
            'maxIters': maxIters,
          })));
    }

    List<Uint8List> results = await Future.wait(futures);
    final pixels = Uint8List(width * height * 4);

    for (int i = 0; i < numIsolates; i++) {
      pixels.setRange(
          i * rowsPerIsolate * width * 4,
          (i == numIsolates - 1 ? height : (i + 1) * rowsPerIsolate) *
              width *
              4,
          results[i]);
    }

    return pixels;
  }

  /// Generates an animation of fractals.
  ///
  /// Parameters:
  /// - [n]: Number of frames.
  /// - [A]: Amplitude for the real parameter shift.
  /// - [B]: Amplitude for the imaginary parameter shift.
  /// - [phi]: Phase offset.
  /// - [k], [l]: Integers controlling oscillation patterns.
  ///
  /// Returns:
  /// - A list of `Uint8List` objects representing the animation frames.

  List<Future<Uint8List>> generateAnimation({
    required int n,
    required double A,
    required double B,
    required double phi,
    required int k,
    required int l,
    int width = 500,
    int height = 500,
  }) {
    final frames = <Future<Uint8List>>[];

    for (int i = 0; i < n; i++) {
      final rpi = A * cos(phi + 2 * pi * i * k / n);
      final ipi = B * sin(2 * pi * i * l / n);

      final currentRealP = (realP ?? 2.0) + rpi;
      final currentImagP = (imagP ?? 0.0) + ipi;

      final frame = burningshipSet(
        realP: currentRealP,
        imagP: currentImagP,
        width: width,
        height: height,
      );
      frames.add(frame);
    }
    return frames;
  }
}
