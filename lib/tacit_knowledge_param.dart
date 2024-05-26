import 'dart:typed_data';

class TacitKnowledgeParam {
  Map<String, dynamic> adjustmentParams = {};

  Uint8List computeValue() {
    // Placeholder for the actual implementation in the parent class.
    return Uint8List(0);
  }
}

class FractalTacitKnowledgeParam extends TacitKnowledgeParam {
  // Convert bytes to real_p value
  double _computeRealPValue(Uint8List value) {
    var bigIntValue = BigInt.parse(value.fold<String>(
        '', (previous, element) => previous + element.toRadixString(16)));
    String reversedDigits = bigIntValue.toString().split('').reversed.join('');
    return double.parse("2." + reversedDigits);
  }

  // Convert bytes to imag_p value
  double _computeImagPValue(Uint8List value) {
    var bigIntValue = BigInt.parse(value.fold<String>(
        '', (previous, element) => previous + element.toRadixString(16)));
    String reversedDigits = bigIntValue.toString().split('').reversed.join('');
    return double.parse("0." + reversedDigits);
  }

  // Convert double to Uint8List
  Uint8List _doubleToUint8List(double value) {
    final byteData = ByteData(8);
    byteData.setFloat64(0, value);
    return byteData.buffer.asUint8List();
  }

  // Compute value based on adjustmentParams
  @override
  Uint8List computeValue() {
    if (adjustmentParams.containsKey('real_p')) {
      double realPValue = _computeRealPValue(super.computeValue());
      return _doubleToUint8List(realPValue);
    } else if (adjustmentParams.containsKey('imag_p')) {
      double imagPValue = _computeImagPValue(super.computeValue());
      return _doubleToUint8List(imagPValue);
    } else {
      return super.computeValue();
    }
  }
}
