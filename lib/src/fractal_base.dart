import 'dart:math';
import 'dart:typed_data';
import 'dart:isolate';

import 'package:complex/complex.dart';

/// The `Fractal` class generates fractals based on different mathematical functions,
/// such as the Burning Ship fractal. It provides methods for generating and updating
/// the fractal image based on configurable parameters, with parallelization and animation capabilities.
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
  Fractal({
    this.funcType = burningShip,
    this.xMin = -2.5,
    this.xMax = 2.0,
    this.yMin = -2.0,
    this.yMax = 0.8,
    this.realP = 2.0,
    this.imagP = 0.0,
    this.width = 1024,
    this.height = 1024,
    this.escapeRadius = 4,
    this.maxIters = 30,
  });

  /// Updates the fractal parameters and regenerates the fractal image.
  Future<void> update({
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
  }) async {
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

    if (this.funcType == burningShip) {
      _imagePixels = await burningshipSet();
    } else {
      throw ArgumentError('$funcType is not supported.');
    }
  }

  /// Calculates a smooth stability value for improved fractal rendering.
  double _smoothStability(Complex z, int escapeCount, int maxIters) {
    var smoothValue = escapeCount + 1 - log(log(z.abs())) / log(2);
    var stability = smoothValue / maxIters;
    return stability.clamp(0.0, 1.0);
  }

  /// Parallel processing for generating fractal segments.
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

    final pixels = Uint8List(width * (endRow - startRow));

    for (int i = startRow; i < endRow; i++) {
      for (int j = 0; j < width; j++) {
        double x = xMin + (xMax - xMin) * j / (width - 1);
        double y = yMin + (yMax - yMin) * i / (height - 1);
        var c = Complex(x, y);
        var z = c;

        for (int escapeCount = 0; escapeCount < maxIters; escapeCount++) {
          if (z.abs() > escapeRadius) {
            double stability =
                _smoothStability(z, escapeCount, maxIters).clamp(0.0, 1.0);
            pixels[(i - startRow) * width + j] = (stability * 255).toInt();
            break;
          }
          z = Complex(z.real.abs(), z.imaginary.abs())
                  .power(Complex(realP, imagP)) +
              c;
        }
      }
    }

    return pixels;
  }

  /// Generates the Burning Ship fractal using parallelization.
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
    const int numIsolates = 4;
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
    final pixels = Uint8List(width * height);

    for (int i = 0; i < numIsolates; i++) {
      pixels.setRange(
          i * rowsPerIsolate * width,
          (i == numIsolates - 1 ? height : (i + 1) * rowsPerIsolate) * width,
          results[i]);
    }

    return pixels;
  }

  /// Generates an animation of fractals.
  Future<List<Uint8List>> generateAnimation({
    required int n,
    required double A,
    required double B,
    required double phi,
    required double k,
    required double l,
  }) async {
    final frames = <Future<Uint8List>>[];

    for (int i = 0; i < n; i++) {
      final rpi = A * cos(phi + 2 * pi * i * k / n);
      final ipi = B * sin(2 * pi * i * l / n);

      final currentRealP = (realP) + rpi;
      final currentImagP = (imagP) + ipi;

      final frame = burningshipSet(
        realP: currentRealP,
        imagP: currentImagP,
        width: width,
        height: height,
      );
      frames.add(frame);
    }
    List<Uint8List> framesV = await Future.wait(frames);
    return framesV;
  }
}
