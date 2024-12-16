import 'dart:io';
import 'dart:typed_data';
import 'package:fractal/fractal.dart';
import 'package:image/image.dart' as img;

void main() async {
  // Initialize the fractal generator
  var fractal = Fractal(
    funcType: Fractal.burningShip,
    width: 800,
    height: 800,
    xMin: -2.5,
    xMax: 2.0,
    yMin: -2,
    yMax: 0.8,
    escapeRadius: 4,
    maxIters: 100,
  );

  // Parameters for the animation
  int numFrames = 60; // Total frames
  double amplitudeA = 0.5; // Amplitude for real part oscillation
  double amplitudeB = 0.5; // Amplitude for imaginary part oscillation
  double phaseOffset = 0; // Phase offset
  int frequencyK = 1; // Frequency multiplier for real part
  int frequencyL = 1; // Frequency multiplier for imaginary part
  int width = 800; // Frame width
  int height = 800; // Frame height

  // Generate the animation frames
  List<Uint8List> frames = fractal.generateAnimation(
    n: numFrames,
    A: amplitudeA,
    B: amplitudeB,
    phi: phaseOffset,
    k: frequencyK,
    l: frequencyL,
    width: width,
    height: height,
  );

  // Save each frame as a PNG file
  for (int i = 0; i < frames.length; i++) {
    final image = img.Image.fromBytes(
      width,
      height,
      frames[i],
      format: img.Format.rgba,
    );
    File('frame_$i.png').writeAsBytesSync(img.encodePng(image));
  }

  print('Animation frames saved as PNG files!');
}
