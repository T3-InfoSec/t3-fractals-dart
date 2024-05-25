import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:great_wall_fractal/fractal.dart';

void main() {
  group('Fractal class tests', () {
    test('Default initialization', () {
      final fractal = Fractal();
      expect(fractal.funcType, Fractal.BURNING_SHIP);
      expect(fractal.width, isNull);
      expect(fractal.height, isNull);
    });

    test('Update parameters', () {
      final fractal = Fractal();
      fractal.update(
        funcType: Fractal.MANDELBROT,
        xMin: -2.0,
        xMax: 2.0,
        yMin: -2.0,
        yMax: 2.0,
        width: 800,
        height: 800,
        escapeRadius: 2,
        maxIters: 100,
      );

      expect(fractal.funcType, Fractal.MANDELBROT);
      expect(fractal.xMin, -2.0);
      expect(fractal.xMax, 2.0);
      expect(fractal.yMin, -2.0);
      expect(fractal.yMax, 2.0);
      expect(fractal.width, 800);
      expect(fractal.height, 800);
      expect(fractal.escapeRadius, 2);
      expect(fractal.maxIters, 100);
    });

    test('Generate Mandelbrot set', () {
      final fractal = Fractal();
      fractal.update(funcType: Fractal.MANDELBROT, width: 100, height: 100);
      Uint8List? pixels = fractal.imagePixels;
      expect(pixels, isNotNull);
      expect(pixels!.length, 100 * 100);
    });

    test('Generate Burning Ship set', () {
      final fractal = Fractal();
      fractal.update(funcType: Fractal.BURNING_SHIP, width: 100, height: 100);
      Uint8List? pixels = fractal.imagePixels;
      expect(pixels, isNotNull);
      expect(pixels!.length, 100 * 100);
    });

    test('Invalid fractal type', () {
      final fractal = Fractal();
      expect(
        () => fractal.update(funcType: 'invalid_type'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Smooth stability calculation', () {
      final fractal = Fractal();
      final complex = Complex(1.0, 1.0);
      final stability = fractal.smoothStability(complex, 10, 100);
      expect(stability, greaterThanOrEqualTo(0.0));
      expect(stability, lessThanOrEqualTo(1.0));
    });
  });
}
