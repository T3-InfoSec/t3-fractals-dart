import 'dart:math';

class Complex {
  final double real;
  final double imag;

  Complex(this.real, this.imag);

  Complex operator +(Complex other) =>
      Complex(real + other.real, imag + other.imag);
  Complex operator -(Complex other) =>
      Complex(real - other.real, imag - other.imag);
  Complex operator *(Complex other) => Complex(
      real * other.real - imag * other.imag,
      real * other.imag + imag * other.real);

  Complex operator /(Complex other) {
    final denominator = other.real * other.real + other.imag * other.imag;
    final realPart = (real * other.real + imag * other.imag) / denominator;
    final imagPart = (imag * other.real - real * other.imag) / denominator;
    return Complex(realPart, imagPart);
  }

  double abs() => sqrt(real * real + imag * imag);

  Complex pow(Complex exponent) {
    // Handle the special case where the base is zero
    if (real == 0.0 && imag == 0.0) {
      return Complex(0.0, 0.0);
    }

    // Handle the special case where the base is infinity
    if (real.isInfinite || imag.isInfinite) {
      return Complex(double.infinity, double.infinity);
    }

    final r = abs();
    final theta = atan2(imag, real);
    final logR = log(r);
    final realPart = logR * exponent.real - theta * exponent.imag;
    final imagPart = logR * exponent.imag + theta * exponent.real;
    final magnitude = exp(realPart);
    return Complex(magnitude * cos(imagPart), magnitude * sin(imagPart));
  }

  @override
  String toString() => '$real + ${imag}i';
}
