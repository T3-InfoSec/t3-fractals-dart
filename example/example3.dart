import 'dart:io';
import 'dart:typed_data';
import 'package:fractal/fractal.dart';
import 'package:image/image.dart' as img;

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
  int numFrames = 15; // Total frames
  double amplitudeA = 0.25; // Amplitude for real part oscillation
  double amplitudeB = 0.25; // Amplitude for imaginary part oscillation
  double phaseOffset = 0; // Phase offset
  double frequencyK = 0.5; // Frequency multiplier for real part
  double frequencyL = 0.5; // Frequency multiplier for imaginary part
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

  // Save the frames as images
  String outputDir = 'output/frames';
  Directory(outputDir).createSync(recursive: true);

  for (int i = 0; i < frames.length; i++) {
    final image =
        img.Image.fromBytes(width, height, frames[i], format: img.Format.rgba);
    final filePath = '$outputDir/frame_${i.toString().padLeft(4, '0')}.png';
    File(filePath).writeAsBytesSync(img.encodePng(image));
  }

  print('Frames saved to $outputDir.');

  // Encode the frames into an MP4 video using FFmpeg
  String outputVideo = 'fractal_animation.mp4';
  await encodeVideo(outputDir, outputVideo, fps: 30);

  print('MP4 video saved as $outputVideo.');
}

// Function to encode frames into a video
Future<void> encodeVideo(String framesDir, String outputFile,
    {required int fps}) async {
  final result = await Process.run('ffmpeg', [
    '-framerate',
    fps.toString(),
    '-i',
    '$framesDir/frame_%04d.png',
    '-c:v',
    'libx264',
    '-preset',
    'slow',
    '-crf',
    '18',
    '-pix_fmt',
    'yuv420p',
    outputFile,
  ]);

  if (result.exitCode == 0) {
    print('Video encoding successful.');
  } else {
    print('Video encoding failed: ${result.stderr}');
  }
}
