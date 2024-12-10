import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:fractal/fractal.dart';

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

// Main function to demonstrate GIF generation
void main() {
  // Create an instance of the Fractal class
  final fractal = Fractal();

  // Generate a color palette
  List<int> palette = generateGradientPalette(256);

  // Set up animation parameters
  int nFrames = 30;
  double amplitudeA = 0.5;
  double amplitudeB = 0.5;
  double phaseOffset = 0.0;
  int kOscillation = 3;
  int lOscillation = 2;
  int width = 800;
  int height = 800;

  // Start the stopwatch to measure time
  final stopwatch = Stopwatch()..start();

  // Generate the animation frames
  List<Uint8List> frames = fractal.generateAnimation(
    n: nFrames,
    A: amplitudeA,
    B: amplitudeB,
    phi: phaseOffset,
    k: kOscillation,
    l: lOscillation,
  );

  // Stop the stopwatch and print the elapsed time
  stopwatch.stop();
  print(
      'Time taken to generate animation: ${stopwatch.elapsedMilliseconds} ms');

  // Create an animated GIF
  final gifEncoder = img.GifEncoder();

  for (int i = 0; i < frames.length; i++) {
    // Create an image for the current frame
    final frameImage = img.Image(width, height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int index = y * width + x;
        int value = frames[i][index];
        int color = mapValueToColor(value, palette);
        frameImage.setPixel(x, y, color);
      }
    }

    // Add the frame to the GIF encoder
    gifEncoder.addFrame(frameImage);
  }

  // Save the GIF to a file
  final gifData = gifEncoder.finish();
  if (gifData != null) {
    final gifFile = File('fractal_animation.gif');
    gifFile.writeAsBytesSync(gifData);
    print('Animated GIF saved as fractal_animation.gif');
  }
}
