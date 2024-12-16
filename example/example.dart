import 'dart:io';
import 'dart:typed_data';

import 'package:fractal/fractal.dart';

import 'package:image/image.dart' as img;

void saveFractalImage(
    Uint8List pixels, int width, int height, String fileName) {
  final image = img.Image.fromBytes(width, height, pixels);
  final png = img.encodePng(image);
  File(fileName).writeAsBytesSync(png);
}

void main() {
  // Generate the fractal
  final fractal = Fractal(
    width: 800,
    height: 800,
    maxIters: 100,
  );
  Uint8List fractalPixels = fractal.burningshipSet();

  // Save the fractal as a PNG image
  saveFractalImage(fractalPixels, 800, 800, 'burningship_fire.png');
  print('Fractal saved as burningship_fire.png');
}
