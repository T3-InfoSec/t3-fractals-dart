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

  double abs() => sqrt(real * real + imag * imag);

  Complex pow(Complex exponent) {
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
