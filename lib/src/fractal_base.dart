import 'dart:math';
import 'dart:typed_data';

import 'package:complex/complex.dart';

class Fractal {
  static const String burningShip = 'burningship';

  String funcType;
  double? xMin, xMax, yMin, yMax, realP, imagP;
  int? width, height, escapeRadius, maxIters;

  Uint8List? _imagePixels;
  Uint8List? get imagePixels => _imagePixels;

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
    this.funcType = funcType ?? this.funcType;

    if (this.funcType == burningShip) {
      _imagePixels = burningshipSet();
    } else {
      throw ArgumentError('$funcType is not supported.');
    }
  }

  double _smoothStability(Complex z, int escapeCount, int maxIters) {
    var smoothValue = escapeCount + 1 - log(log(z.abs())) / log(2);
    var stability = smoothValue / maxIters;
    return stability.clamp(0.0, 1.0);
  }

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

    final x =
        List.generate(width, (idx) => xMin + (xMax - xMin) * idx / (width - 1));
    final y = List.generate(
        height, (idx) => yMin + (yMax - yMin) * idx / (height - 1));

    final pixels = Uint8List(width * height);

    for (int i = 0; i < height; i++) {
      for (int j = 0; j < width; j++) {
        var c = Complex(x[j], y[i]);
        var z = c;
        for (int escapeCount = 0; escapeCount < maxIters; escapeCount++) {
          if (z.abs() > escapeRadius) {
            pixels[i * width + j] =
                (_smoothStability(z, escapeCount, maxIters) * 255).toInt();
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

  List<Uint8List> generateAnimation({
    required int n,
    required double A,
    required double B,
    required double phi,
    required int k,
    required int l,
    int width = 800,
    int height = 800,
  }) {
    final frames = <Uint8List>[];

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
