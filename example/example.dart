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

Future<void> main() async {
  // Generate the fractal

  final fractal = Fractal(
    width: 500,
    height: 500,
    maxIters: 100,
  );
  Stopwatch timer = Stopwatch()..start();

  Uint8List fractalPixels = await fractal.burningshipSet();
  // Stop the timer after generating frames
  timer.stop();
  print('Animation frames generated in ${timer.elapsedMilliseconds} ms.');

  // Save the fractal as a PNG image
  saveFractalImage(fractalPixels, 500, 500, 'burningship_fire.png');
  print('Fractal saved as burningship_fire.png');
}
