import 'dart:typed_data';
import 'package:fractal/fractal.dart';
import 'package:test/test.dart';

void main() {
  group('Fractal Tests', () {
    test('Default initialization', () {
      final fractal = Fractal(
        realP: 2.178174161131,
        imagP: 0.178174161131
      );
      expect(fractal.funcType, equals(Fractal.burningShip));
      expect(fractal.imagePixels, isNull);
    });

    test('Update method', () {
      final fractal = Fractal(
        realP: 2.178174161131,
        imagP: 0.178174161131
      );
      fractal.update(
        xMin: -2.0,
        xMax: 2.0,
        yMin: -1.0,
        yMax: 1.0,
        width: 800,
        height: 600,
        escapeRadius: 5,
        maxIters: 50,
      );

      expect(fractal.xMin, equals(-2.0));
      expect(fractal.xMax, equals(2.0));
      expect(fractal.yMin, equals(-1.0));
      expect(fractal.yMax, equals(1.0));
      expect(fractal.width, equals(800));
      expect(fractal.height, equals(600));
      expect(fractal.escapeRadius, equals(5));
      expect(fractal.maxIters, equals(50));
      expect(fractal.imagePixels, isNotNull);
    });

    test('Unsupported funcType in update', () {
      final fractal = Fractal(
        realP: 2.178174161131,
        imagP: 0.178174161131
      );
      expect(
        () => fractal.update(funcType: 'unsupported'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('burningshipSet generates pixel data', () {
      final fractal = Fractal(
        xMin: -2.5,
        xMax: 2.0,
        yMin: -2.0,
        yMax: 0.8,
        width: 100,
        height: 100,
        realP: 2.178174161131,
        imagP: 0.178174161131,
        escapeRadius: 4,
        maxIters: 30,
      );

      final pixels = fractal.burningshipSet();
      expect(pixels, isA<Uint8List>());
      expect(pixels.length, equals(100 * 100));
    });

    test('burningshipSet respects bounds', () {
      final fractal = Fractal(
        xMin: -1.0,
        xMax: 1.0,
        yMin: -1.0,
        yMax: 1.0,
        width: 10,
        height: 10,
        realP: 2.178174161131,
        imagP: 0.178174161131,
      );

      final pixels = fractal.burningshipSet();
      expect(pixels.length, equals(10 * 10));
    });
  });
}
