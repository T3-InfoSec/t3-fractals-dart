import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'fractal.dart';

import 'dart:math';

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

void main() {
  // Create an instance of the Fractal class
  final fractal = Fractal();

  // Generate a color palette
  List<int> palette = generateGradientPalette(256);

  // Generate the Mandelbrot set
  fractal.update(funcType: Fractal.MANDELBROT, width: 800, height: 800);
  Uint8List? mandelbrotPixels = fractal.imagePixels;
  if (mandelbrotPixels != null) {
    saveImage(mandelbrotPixels, 800, 800, 'mandelbrot.png', palette);
    print('Mandelbrot fractal saved as mandelbrot.png');
  }

  // Generate the Burning Ship set
  fractal.update(funcType: Fractal.BURNING_SHIP, width: 800, height: 800);
  Uint8List? burningShipPixels = fractal.imagePixels;
  if (burningShipPixels != null) {
    saveImage(burningShipPixels, 800, 800, 'burningship.png', palette);
    print('Burning Ship fractal saved as burningship.png');
  }
}
