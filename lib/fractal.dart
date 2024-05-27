import 'dart:math';
import 'dart:typed_data';

import './src/complex.dart';

class Fractal {
  static const String BURNING_SHIP = 'burningship';
  static const String MANDELBROT = 'mandelbrot';

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

  Uint8List? _imagePixels;

  Fractal({
    this.funcType = BURNING_SHIP,
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

  Uint8List? get imagePixels => _imagePixels;
  set imagePixels(Uint8List? pixels) => _imagePixels = pixels;

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

    if (this.funcType == BURNING_SHIP) {
      _imagePixels = burningshipSet();
    } else if (this.funcType == MANDELBROT) {
      _imagePixels = mandelbrotSet();
    } else {
      throw ArgumentError('$funcType is not supported.');
    }
  }

  double _smoothStability(Complex z, int escapeCount, int maxIters) {
    final smoothValue = escapeCount + 1 - log(log(z.abs())) / log(2);
    final stability = smoothValue / maxIters;
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
        List.generate(width, (i) => xMin + (xMax - xMin) * i / (width - 1));
    final y =
        List.generate(height, (i) => yMin + (yMax - yMin) * i / (height - 1));

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
          z = Complex(z.real.abs(), z.imag.abs()).pow(Complex(realP, imagP)) +
              c;
        }
        pixels[i * width + j] = pixels[i * width + j] ?? 255;
      }
    }
    return pixels;
  }

  Uint8List mandelbrotSet({
    double xMin = -2.2,
    double xMax = 1,
    double yMin = -1.2,
    double yMax = 1.2,
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
        List.generate(width, (i) => xMin + (xMax - xMin) * i / (width - 1));
    final y =
        List.generate(height, (i) => yMin + (yMax - yMin) * i / (height - 1));

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
          z = z.pow(Complex(realP, imagP)) + c;
        }
        pixels[i * width + j] = pixels[i * width + j] ?? 255;
      }
    }
    return pixels;
  }
}
