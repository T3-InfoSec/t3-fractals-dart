import 'dart:typed_data';

import 'package:fractal/fractal.dart';

void main() {
  final fractal = Fractal(
    realP: 2.178174161131,
    imagP: 0.178174161131
  );

  fractal.update(funcType: Fractal.burningShip, width: 800, height: 800);
  Uint8List? burningShipPixels = fractal.imagePixels;
  
  if (burningShipPixels != null) {
    print('Burning Ship fractal: \n $burningShipPixels');
  }
}
