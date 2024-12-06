import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:fractal/fractal.dart';

List<int> generateGradientPalette(int length) {
  List<int> palette = [];
  for (int i = 0; i < length; i++) {
    double ratio = i / (length - 1);
    int red = (255 * pow(ratio, 2)).toInt();
    int blue = (255 * pow(1 - ratio, 2)).toInt();
    palette.add(img.getColor(red, 0, blue));
  }
  return palette;
}

int mapValueToColor(int value, List<int> palette) {
  value = value.clamp(0, 255); // Ensure within bounds
  return palette[value];
}

void main() {
  final fractal = Fractal();

  List<int> palette = generateGradientPalette(256);

  int nFrames = 30;
  double amplitudeA = 0.5;
  double amplitudeB = 0.5;
  double phaseOffset = 0.0;
  int kOscillation = 3;
  int lOscillation = 2;
  int width = 800;
  int height = 800;

  List<Uint8List> frames = fractal.generateAnimation(
    n: nFrames,
    A: amplitudeA,
    B: amplitudeB,
    phi: phaseOffset,
    k: kOscillation,
    l: lOscillation,
    width: width,
    height: height,
  );

  final gifEncoder = img.GifEncoder();

  for (int i = 0; i < frames.length; i++) {
    final frameImage = img.Image(width, height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        int index = y * width + x;
        int value = frames[i][index];
        int color = mapValueToColor(value, palette);
        frameImage.setPixel(x, y, color);
      }
    }
    gifEncoder.addFrame(frameImage);
  }

  final gifData = gifEncoder.finish();
  if (gifData != null) {
    final gifFile = File('fractal_animation.gif');
    gifFile.writeAsBytesSync(gifData);
    print('Animated GIF saved as fractal_animation.gif');
  }
}
