import 'dart:io';
import 'dart:typed_data';
import 'package:fractal/fractal.dart';
import 'package:image/image.dart' as img;
import 'dart:math';

void main() async {
  // Initialize the fractal generator
  var fractal = Fractal(
    funcType: Fractal.burningShip,
    width: 500,
    height: 500,
    xMin: -2.5,
    xMax: 2.0,
    yMin: -2,
    yMax: 0.8,
    escapeRadius: 3,
    maxIters: 100,
  );

  // Parameters for the animation
  int numFrames = 120; // Total frames
  double amplitudeA = 1; // Amplitude for real part oscillation
  double amplitudeB = 0.8; // Amplitude for imaginary part oscillation
  double phaseOffset = pi / 4; // Phase offset
  double frequencyK = 2; // Frequency multiplier for real part
  double frequencyL = 3; // Frequency multiplier for imaginary part
  int width = 500; // Frame width
  int height = 500; // Frame height

  // Generate the animation frames
  Stopwatch timer = Stopwatch()..start();

  List<Uint8List> frames = await fractal.generateAnimation(
    n: numFrames,
    A: amplitudeA,
    B: amplitudeB,
    phi: phaseOffset,
    k: frequencyK,
    l: frequencyL,
    width: width,
    height: height,
  );

  // Stop the timer after generating frames
  timer.stop();
  print('Animation frames generated in ${timer.elapsedMilliseconds} ms.');

  // Create an animated GIF
  final gifEncoder = img.GifEncoder();

  for (int i = 0; i < frames.length; i++) {
    final image = img.Image.fromBytes(
      width,
      height,
      frames[i],
      format: img.Format.rgba,
    );

    // Add the frame to the GIF encoder
    gifEncoder.addFrame(image, duration: 17); // Duration in milliseconds
  }

  // Save the animated GIF to a file
  final gifFile = File('fractal_animation-1.gif');
  gifFile.writeAsBytesSync(gifEncoder.finish()!);

  print('GIF animation saved as fractal_animation.gif');
}
