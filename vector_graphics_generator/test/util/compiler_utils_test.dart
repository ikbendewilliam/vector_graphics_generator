import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_graphics_generator/src/util/compiler_utils.dart';
import 'package:vector_graphics_generator_annotations/vector_graphics_generator_annotations.dart';

void main() {
  void _checkFile(List<String> result, String resultPath, String expectedResultPath) {
    expect(result, isNotNull);
    result.contains(resultPath);
    final File resultFile = File(resultPath);
    final File expectedResultFile = File(expectedResultPath);
    expect(listEquals(resultFile.readAsBytesSync(), expectedResultFile.readAsBytesSync()), true);
  }

  test('Check invalid input', () async {
    const VectorGraphicsSource source = VectorGraphicsSource(
      input: 'some/path/that/does/not/exist.svg',
    );
    expect(() async => await CompilerUtils.compileSvgSource(source), throwsA(isA<PathNotFoundException>()));
  });

  test('Check invalid inputDir', () async {
    const VectorGraphicsSource source = VectorGraphicsSource(
      inputDir: 'some/path/that/does/not/exist',
    );
    expect(
        () async => await CompilerUtils.compileSvgSource(source),
        throwsA(isA<Exception>().having(
          (Exception p0) => p0.toString(),
          'check invalid inputDir',
          'Exception: input-dir some/path/that/does/not/exist does not exist.',
        )));
  });

  test('Check invalid config', () async {
    expect(() => VectorGraphicsSource(), throwsAssertionError);
  });

  test('Flutter svg as input', () async {
    const VectorGraphicsSource source = VectorGraphicsSource(
      input: 'test/assets/flutter.svg',
    );
    final List<String> result = await CompilerUtils.compileSvgSource(source);
    _checkFile(result, 'test/assets/flutter.vec', 'test/assets/flutter_expected.vec');
  });

  test('Squares svg as input', () async {
    const VectorGraphicsSource source = VectorGraphicsSource(
      input: 'test/assets/squares.svg',
    );
    final List<String> result = await CompilerUtils.compileSvgSource(source);
    _checkFile(result, 'test/assets/squares.vec', 'test/assets/squares_expected.vec');
  });

  test('Flutter svg as input with output', () async {
    const VectorGraphicsSource source = VectorGraphicsSource(
      input: 'test/assets/flutter.svg',
      output: 'test/assets/flutter2.vec',
    );
    final List<String> result = await CompilerUtils.compileSvgSource(source);
    _checkFile(result, 'test/assets/flutter2.vec', 'test/assets/flutter_expected.vec');
  });

  test('Flutter svg + squares svg as inputDir', () async {
    const VectorGraphicsSource source = VectorGraphicsSource(
      inputDir: 'test/assets/',
    );
    final List<String> result = await CompilerUtils.compileSvgSource(source);
    expect(result.length, 2);
    _checkFile(result, 'test/assets/flutter.vec', 'test/assets/flutter_expected.vec');
    _checkFile(result, 'test/assets/squares.vec', 'test/assets/squares_expected.vec');
  });

  test('Flutter svg as inputDir without ending slash', () async {
    const VectorGraphicsSource source = VectorGraphicsSource(
      inputDir: 'test/assets',
      outputDir: 'test/assets/result',
    );
    final List<String> result = await CompilerUtils.compileSvgSource(source);
    expect(result.length, 2);
    _checkFile(result, 'test/assets/result/flutter.vec', 'test/assets/flutter_expected.vec');
    _checkFile(result, 'test/assets/result/squares.vec', 'test/assets/squares_expected.vec');
  });

  test('Flutter svg as inputDir with different outputDir', () async {
    const VectorGraphicsSource source = VectorGraphicsSource(
      inputDir: 'test/assets/',
      outputDir: 'test/assets/result',
    );
    final List<String> result = await CompilerUtils.compileSvgSource(source);
    expect(result.length, 2);
    _checkFile(result, 'test/assets/result/flutter.vec', 'test/assets/flutter_expected.vec');
    _checkFile(result, 'test/assets/result/squares.vec', 'test/assets/squares_expected.vec');
  });

  test('Flutter svg as inputDir with different outputDir and ending /', () async {
    const VectorGraphicsSource source = VectorGraphicsSource(
      inputDir: 'test/assets/',
      outputDir: 'test/assets/result/',
    );
    final List<String> result = await CompilerUtils.compileSvgSource(source);
    expect(result.length, 2);
    _checkFile(result, 'test/assets/result/flutter.vec', 'test/assets/flutter_expected.vec');
    _checkFile(result, 'test/assets/result/squares.vec', 'test/assets/squares_expected.vec');
  });

  test('Flutter svg as inputDir with subfolder', () async {
    const VectorGraphicsSource source = VectorGraphicsSource(
      inputDir: 'test/',
      outputDir: 'test/assets/result',
    );
    final List<String> result = await CompilerUtils.compileSvgSource(source);
    expect(result.length, 2);
    _checkFile(result, 'test/assets/result/assets/flutter.vec', 'test/assets/flutter_expected.vec');
    _checkFile(result, 'test/assets/result/assets/squares.vec', 'test/assets/squares_expected.vec');
  });
}
