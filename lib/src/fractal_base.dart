import 'dart:ffi' as ffi;
import 'dart:io' show Platform, Directory;
import 'dart:typed_data';
import 'package:path/path.dart' as path;

class Fractal {
  static const String burningShip = 'burningship';

  // FFI-related members
  late final ffi.DynamicLibrary _dylib;
  late final ffi.Pointer<ffi.Uint8> Function(
      double xMin,
      double xMax,
      double yMin,
      double yMax,
      double realP,
      double imagP,
      int width,
      int height,
      int escapeRadius,
      int maxIters) _burningshipSet;

  late final void Function(ffi.Pointer<ffi.Uint8>) _freePixels;
  late final ffi.Pointer<ffi.Pointer<ffi.Uint8>> Function(
      int n,
      double A,
      double B,
      double phi,
      int k,
      int l,
      double xMin,
      double xMax,
      double yMin,
      double yMax,
      int width,
      int height,
      int escapeRadius,
      int maxIters) _generateAnimation;

  late final void Function(ffi.Pointer<ffi.Pointer<ffi.Uint8>>, int n)
      _freeAnimation;

  // Fractal properties
  String funcType;
  double? xMin;
  double? xMax;
  double? yMin;
  double? yMax;
  double? realP;
  double? imagP;
  int? width;
  int? height;
  int? escapeRadius;
  int? maxIters;

  Uint8List? _imagePixels;

  Uint8List? get imagePixels => _imagePixels;

  Fractal({
    this.funcType = burningShip,
    this.xMin,
    this.xMax,
    this.yMin,
    this.yMax,
    this.realP,
    this.imagP,
    this.width,
    this.height,
    this.escapeRadius,
    this.maxIters,
  }) {
    // Load the native library
    var libraryPath =
        path.join(Directory.current.path, 'lib/burningship', 'burningship.so');
    if (Platform.isMacOS) {
      libraryPath = path.join(
          Directory.current.path, 'lib/burningship', 'burningship.dylib');
    } else if (Platform.isWindows) {
      libraryPath = path.join(Directory.current.path, 'lib/burningship',
          'Build', 'libburningship.dll');
    }
    _dylib = ffi.DynamicLibrary.open(libraryPath);

    // Set up function pointers
    _burningshipSet = _dylib
        .lookup<
            ffi.NativeFunction<
                ffi.Pointer<ffi.Uint8> Function(
                    ffi.Double,
                    ffi.Double,
                    ffi.Double,
                    ffi.Double,
                    ffi.Double,
                    ffi.Double,
                    ffi.Int32,
                    ffi.Int32,
                    ffi.Int32,
                    ffi.Int32)>>('burningshipSet')
        .asFunction();
    _freePixels = _dylib
        .lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Uint8>)>>(
            'freePixels')
        .asFunction();
    _generateAnimation = _dylib
        .lookup<
            ffi.NativeFunction<
                ffi.Pointer<ffi.Pointer<ffi.Uint8>> Function(
                    ffi.Int32,
                    ffi.Double,
                    ffi.Double,
                    ffi.Double,
                    ffi.Int32,
                    ffi.Int32,
                    ffi.Double,
                    ffi.Double,
                    ffi.Double,
                    ffi.Double,
                    ffi.Int32,
                    ffi.Int32,
                    ffi.Int32,
                    ffi.Int32)>>('generateAnimation')
        .asFunction();
    _freeAnimation = _dylib
        .lookup<
            ffi.NativeFunction<
                ffi.Void Function(ffi.Pointer<ffi.Pointer<ffi.Uint8>>,
                    ffi.Int32)>>('freeAnimation')
        .asFunction();
  }

  void update({
    String? funcType,
    double? xMin,
    double? xMax,
    double? yMin,
    double? yMax,
    double? realP,
    double? imagP,
    int? width,
    int? height,
    int? escapeRadius,
    int? maxIters,
  }) {
    this.funcType = funcType ?? this.funcType;
    this.xMin = xMin ?? this.xMin;
    this.xMax = xMax ?? this.xMax;
    this.yMin = yMin ?? this.yMin;
    this.yMax = yMax ?? this.yMax;
    this.realP = realP ?? this.realP;
    this.imagP = imagP ?? this.imagP;
    this.width = width ?? this.width;
    this.height = height ?? this.height;
    this.escapeRadius = escapeRadius ?? this.escapeRadius;
    this.maxIters = maxIters ?? this.maxIters;

    if (this.funcType == burningShip) {
      _imagePixels = burningshipSet();
    } else {
      throw ArgumentError('$funcType is not supported.');
    }
  }

  Uint8List burningshipSet() {
    final pointer = _burningshipSet(
      xMin ?? -2.5,
      xMax ?? 2.0,
      yMin ?? -2.0,
      yMax ?? 0.8,
      realP ?? 2.0,
      imagP ?? 0.0,
      width ?? 1024,
      height ?? 1024,
      escapeRadius ?? 4,
      maxIters ?? 1000,
    );
    final result = pointer.asTypedList(width! * height!);
    _freePixels(pointer);
    return result;
  }

  List<Uint8List> generateAnimation({
    required int n,
    required double A,
    required double B,
    required double phi,
    required int k,
    required int l,
  }) {
    final framesPointer = _generateAnimation(
      n,
      A,
      B,
      phi,
      k,
      l,
      xMin ?? -2.5,
      xMax ?? 2.0,
      yMin ?? -2.0,
      yMax ?? 0.8,
      width ?? 1024,
      height ?? 1024,
      escapeRadius ?? 4,
      maxIters ?? 1000,
    );
    final frameSize = width! * height!;
    final totalSize = n * frameSize;

    // Manually copy the raw data into a Dart Uint8List
    final rawData = Uint8List(totalSize);
    final rawDataPointer = framesPointer.cast<ffi.Uint8>();
    for (int i = 0; i < totalSize; i++) {
      rawData[i] = (rawDataPointer + i).value; // Use pointer arithmetic
    }

    // Split the raw data into individual frames
    final frames = List<Uint8List>.generate(
      n,
      (i) => Uint8List.fromList(
        rawData.sublist(i * frameSize, (i + 1) * frameSize),
      ),
    );

    // Free the memory allocated in the native function
    _freeAnimation(framesPointer, n);

    return frames;
  }
}
