import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

import 'fractal.dart';

void saveImage(Uint8List pixels, int width, int height, String fileName) {
  // Create an image with the correct width and height
  final image = img.Image(width, height);

  // Iterate over each pixel and set the RGBA values
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      int index = y * width + x;
      int value = pixels[index];
      image.setPixel(x, y, img.getColor(value, value, value));
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

  // Generate the Mandelbrot set
  fractal.update(funcType: Fractal.MANDELBROT, width: 800, height: 800);
  Uint8List? mandelbrotPixels = fractal.imagePixels;
  if (mandelbrotPixels != null) {
    saveImage(mandelbrotPixels, 800, 800, 'mandelbrot.png');
    print('Mandelbrot fractal saved as mandelbrot.png');
  }

  // Generate the Burning Ship set
  fractal.update(funcType: Fractal.BURNING_SHIP, width: 800, height: 800);
  Uint8List? burningShipPixels = fractal.imagePixels;
  if (burningShipPixels != null) {
    saveImage(burningShipPixels, 800, 800, 'burningship.png');
    print('Burning Ship fractal saved as burningship.png');
  }
}
