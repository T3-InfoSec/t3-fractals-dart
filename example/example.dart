import 'dart:typed_data';

import 'package:fractal/fractal.dart';

void main() {
  // Create an instance of the Fractal class
  final fractal = Fractal();

  // Generate the Burning Ship set
  fractal.update(funcType: Fractal.burningShip, width: 800, height: 800);
  Uint8List? burningShipPixels = fractal.imagePixels;
  if (burningShipPixels != null) {
    print('Burning Ship fractal: \n $burningShipPixels');
  }
}
