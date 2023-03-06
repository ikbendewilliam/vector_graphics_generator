import 'package:vector_graphics_generator_annotations/vector_graphics_generator_annotations.dart';

@VectorGraphics(
  svgSources: [
    VectorGraphicsSource(
      input: 'assets/different_folder/green_rectangle.svg',
      output: 'assets/different_folder_output/green_rectangle.vec',
    ),
    VectorGraphicsSource(
      inputDir: 'assets/images',
      outputDir: 'assets/vector_graphics',
    ),
  ],
)
class VectorGraphicsAssets {}
