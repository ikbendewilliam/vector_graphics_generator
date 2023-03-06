import 'dart:io' hide ProcessResult;
import 'dart:typed_data';

import 'package:vector_graphics_compiler/vector_graphics_compiler.dart';
import 'package:vector_graphics_generator/src/util/colors.dart';
import 'package:vector_graphics_generator_annotations/vector_graphics_generator_annotations.dart';

class CompilerUtils {
  static bool _isLibpathopsSet = false;
  static bool _isLibTessellatorSet = false;

  static SvgTheme _parseTheme(VectorGraphicsSource source) {
    Color? currentColor = namedColors[source.currentColor];
    if (currentColor == null) {
      final int? argbValue = int.tryParse(source.currentColor);
      currentColor = Color(argbValue ?? 0xFF000000);
    }
    return SvgTheme(
      currentColor: currentColor,
      fontSize: source.fontSize,
      xHeight: source.xHeight,
    );
  }

  /// A function that compiles a VectorGraphicsSource to vector graphics.
  static Future<List<String>> compileSvgSource(VectorGraphicsSource source) async {
    final List<Pair> pairs = <Pair>[];
    if (source.inputDir != null) {
      final Directory directory = Directory(source.inputDir!);
      if (!directory.existsSync()) {
        throw Exception('input-dir ${directory.path} does not exist.');
      }
      final String? outputDir = source.outputDir;
      for (final File file in directory.listSync(recursive: true).whereType<File>()) {
        if (!file.path.endsWith('.svg')) {
          continue;
        }
        String folder;
        if (outputDir == null) {
          folder = file.parent.path;
        } else {
          folder = outputDir;
          String parentPath = file.parent.absolute.path;
          if (!parentPath.endsWith('/')) parentPath += '/';
          String directoryPath = directory.absolute.path;
          if (!directoryPath.endsWith('/')) directoryPath += '/';

          if (parentPath != directoryPath) {
            folder = '$folder/${file.parent.path.substring(directory.path.length + (directory.path.endsWith('/') ? 0 : 1), file.parent.path.length)}';
          }
          Directory(folder).createSync(recursive: true);
        }
        final String outputPath = '$folder/${file.path.substring(file.parent.path.length + 1, file.path.length - 4)}.vec';
        pairs.add(Pair(file.path, outputPath));
      }
    } else {
      if (source.input == null) {
        throw Exception('One of input or inputDir must be specified. $source');
      }
      final String inputFilePath = source.input!;
      final String outputFilePath = source.output ?? '${inputFilePath.substring(0, inputFilePath.length - 4)}.vec';
      Directory(outputFilePath).parent.createSync(recursive: true);
      pairs.add(Pair(inputFilePath, outputFilePath));
    }

    final bool maskingOptimizerEnabled = source.optimizeMasks;
    final bool clippingOptimizerEnabled = source.optimizeClips;
    final bool overdrawOptimizerEnabled = source.optimizeOverdraw;

    if (maskingOptimizerEnabled || clippingOptimizerEnabled || overdrawOptimizerEnabled) {
      _loadPathOps(source.libpathops);
    }
    if (source.tessellate) {
      _loadTessellator(source.libtessellator);
    }

    for (final Pair pair in pairs) {
      if (File(pair.outputPath).existsSync()) continue;
      await _process(
        pair,
        theme: _parseTheme(source),
        maskingOptimizerEnabled: maskingOptimizerEnabled,
        clippingOptimizerEnabled: clippingOptimizerEnabled,
        overdrawOptimizerEnabled: overdrawOptimizerEnabled,
        dumpDebug: source.dumpDebug,
      );
    }
    return pairs.map((Pair e) => e.outputPath).toList();
  }

  static void _loadPathOps(String? libpathops) {
    if (_isLibpathopsSet) return;
    _isLibpathopsSet = true;
    if (libpathops != null && libpathops.isNotEmpty) {
      initializeLibPathOps(libpathops);
    } else if (!initializePathOpsFromFlutterCache()) {
      throw StateError('Could not find libpathops binary');
    }
  }

  static void _loadTessellator(String? libtessellator) {
    if (_isLibTessellatorSet) return;
    _isLibTessellatorSet = true;
    if (libtessellator != null && libtessellator.isNotEmpty) {
      initializeLibTesselator(libtessellator);
    } else if (!initializeTessellatorFromFlutterCache()) {
      throw StateError('Could not find libtessellator binary');
    }
  }

  static Future<void> _process(
    Pair pair, {
    required bool maskingOptimizerEnabled,
    required bool clippingOptimizerEnabled,
    required bool overdrawOptimizerEnabled,
    required bool dumpDebug,
    SvgTheme theme = const SvgTheme(),
  }) async {
    final Uint8List bytes = encodeSvg(
      xml: File(pair.inputPath).readAsStringSync(),
      debugName: pair.inputPath,
      theme: theme,
      enableMaskingOptimizer: maskingOptimizerEnabled,
      enableClippingOptimizer: clippingOptimizerEnabled,
      enableOverdrawOptimizer: overdrawOptimizerEnabled,
    );
    File(pair.outputPath).writeAsBytesSync(bytes);
  }
}

/// A pair of input and output paths.
class Pair {
  /// Create a new [Pair].
  const Pair(this.inputPath, this.outputPath);

  /// The path the SVG should be read from.
  final String inputPath;

  /// The path the vector graphic will be written to.
  final String outputPath;
}
