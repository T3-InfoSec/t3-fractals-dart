// import 'package:test/test.dart';
import 'package:great_wall_fractal/fractal.dart';

// void main() {
//   group('Fractal', () {
//     test('Check if burningshipSet generates correct pixels', () {
//       final fractal = Fractal();
//       final pixels = fractal.burningshipSet();
//       expect(pixels.length, equals(1024 * 1024));
//       // Add more assertions here to validate the generated pixels
//     });

//     test('Check if mandelbrotSet generates correct pixels', () {
//       final fractal = Fractal();
//       final pixels = fractal.mandelbrotSet();
//       expect(pixels.length, equals(1024 * 1024));
//       // Add more assertions here to validate the generated pixels
//     });

//     test(
//         'Check if update method updates the fractal parameters and generates correct pixels',
//         () {
//       final fractal = Fractal();
//       fractal.update(
//         xMin: -2.0,
//         xMax: 2.0,
//         yMin: -1.0,
//         yMax: 1.0,
//         width: 512,
//         height: 512,
//         maxIters: 50,
//       );
//       final pixels = fractal.imagePixels;
//       expect(pixels.length, equals(512 * 512));
//       // Add more assertions here to validate the generated pixels and updated parameters
//     });

//     test('Check if update method throws an error for unsupported function type',
//         () {
//       final fractal = Fractal();
//       expect(() => fractal.update(funcType: 'invalid'), throwsArgumentError);
//     });
//   });
// }
