import 'package:test/test.dart';
import 'complex.dart';

void main() {
  group('Complex class tests', () {
    test('Addition of complex numbers', () {
      final c1 = Complex(1.0, 2.0);
      final c2 = Complex(3.0, 4.0);
      final result = c1 + c2;
      expect(result.real, equals(4.0));
      expect(result.imag, equals(6.0));
    });

    test('Subtraction of complex numbers', () {
      final c1 = Complex(5.0, 6.0);
      final c2 = Complex(2.0, 3.0);
      final result = c1 - c2;
      expect(result.real, equals(3.0));
      expect(result.imag, equals(3.0));
    });

    test('Multiplication of complex numbers', () {
      final c1 = Complex(1.0, 2.0);
      final c2 = Complex(3.0, 4.0);
      final result = c1 * c2;
      expect(result.real, equals(-5.0));
      expect(result.imag, equals(10.0));
    });

    test('Absolute value of a complex number', () {
      final c = Complex(3.0, 4.0);
      final result = c.abs();
      expect(result, equals(5.0));
    });

    test('Power of a complex number', () {
      final base = Complex(2.0, 3.0);
      // Equivalent to raising to the power of 1
      final exponent = Complex(1.0, 0.0);
      final result = base.pow(exponent);
      expect(result.real, closeTo(2.0, 1e-9));
      expect(result.imag, closeTo(3.0, 1e-9));
    });

    test('Power of a complex number (non-trivial exponent)', () {
      final base = Complex(2.0, 3.0);
      final exponent = Complex(1.0, 2.0);
      final result = base.pow(exponent);
      final expectedReal = -0.46395650081520845;
      final expectedImag = -0.19953008533155392;
      expect(result.real, closeTo(expectedReal, 1e-5));
      expect(result.imag, closeTo(expectedImag, 1e-5));
    });
  });

  test('Division of complex numbers', () {
    final c1 = Complex(1.0, 2.0);
    final c2 = Complex(3.0, 4.0);
    final result = c1 / c2;
    final expectedReal = 0.44;
    final expectedImag = 0.08;
    expect(result.real, closeTo(expectedReal, 1e-5));
    expect(result.imag, closeTo(expectedImag, 1e-5));
  });

  test('Power of a complex number with negative real and imaginary parts', () {
    final base = Complex(-2.0, -3.0);
    final exponent = Complex(1.0, 2.0);
    final result = base.pow(exponent);
    final expectedReal = 248.44483471301263;
    final expectedImag = 106.84669572119132;
    expect(result.real, closeTo(expectedReal, 1e-5));
    expect(result.imag, closeTo(expectedImag, 1e-5));
  });

  test('Power of a complex number with a real exponent', () {
    final base = Complex(2.0, 3.0);
    final exponent = Complex(2.0, 0.0);
    final result = base.pow(exponent);
    final expectedReal = -5.0;
    final expectedImag = 12.0;
    expect(result.real, closeTo(expectedReal, 1e-5));
    expect(result.imag, closeTo(expectedImag, 1e-5));
  });

  test('Power of a complex number (zero base)', () {
    final base = Complex(0.0, 0.0);
    final exponent = Complex(1.0, 1.0);
    final result = base.pow(exponent);
    final expectedReal = 0.0;
    final expectedImag = 0.0;
    expect(result.real, closeTo(expectedReal, 1e-5));
    expect(result.imag, closeTo(expectedImag, 1e-5));
  });

  test('Power of a complex number (infinity base)', () {
    final base = Complex(double.infinity, double.infinity);
    final exponent = Complex(1.0, 1.0);
    final result = base.pow(exponent);
    final expectedReal = double.infinity;
    final expectedImag = double.infinity;
    expect(result.real, equals(expectedReal));
    expect(result.imag, equals(expectedImag));
  });
}
