import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:fractal/fractal.dart';
import 'package:image/image.dart' as img;

// Function to generate a gradient color palette
List<int> generateGradientPalette(int length) {
  List<int> palette = [];
  for (int i = 0; i < length; i++) {
    double ratio = i / (length - 1);
    int red = (255 * ratio).toInt();
    int blue = 255 - red;
    palette.add(img.getColor(red, 0, blue));
  }
  return palette;
}

// Mapping fractal values to colors
int mapValueToColor(int value, List<int> palette) {
  int index = min(value, palette.length - 1);
  return palette[index];
}

void saveImage(Uint8List pixels, int width, int height, String fileName,
    List<int> palette) {
  // Create an image with the correct width and height
  final image = img.Image(width, height);

  // Iterate over each pixel and set the RGBA values using the color palette
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int index = y * width + x;
      int value = pixels[index];
      int color = mapValueToColor(value, palette);
      image.setPixel(x, y, color);
    }
  }

  // Save the image as PNG
  final png = img.encodePng(image);
  final file = File(fileName);
  file.writeAsBytesSync(png);
}

Future<void> main() async {
  // Generate the fractal
  // Create an instance of the Fractal class

  final fractal = Fractal(
    width: 400,
    height: 400,
    maxIters: 100,
    realP: 2,
    imagP: 1,
  );
  // Generate a color palette
  List<int> palette = generateGradientPalette(256);

  Stopwatch timer = Stopwatch()..start();
  // Generate the Burning Ship set
  fractal.update(funcType: Fractal.burningShip, width: 400, height: 400);
  Uint8List burningShipPixels = await fractal.burningshipSet();
  // print(burningShipPixels);

  saveImage(burningShipPixels, 400, 400, 'burningship.png', palette);
  print('Burning Ship fractal saved as burningship.png');

  // Stop the timer after generating frames
  timer.stop();
  print('Animation frames generated in ${timer.elapsedMilliseconds} ms.');

  // Save the fractal as a PNG image
  print('Fractal saved as burningship_fire.png');
}
