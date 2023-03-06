import 'package:example/vector_graphics_assets.vector_graphics_assets.dart';
import 'package:flutter/material.dart';
import 'package:vector_graphics/vector_graphics.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: const [
            Expanded(child: VectorGraphicFromAsset(VectorGraphicsAssets.flutter)),
            Expanded(child: VectorGraphicFromAsset(VectorGraphicsAssets.greenRectangle)),
            Expanded(child: VectorGraphicFromAsset(VectorGraphicsAssets.squares)),
          ],
        ),
      ),
    );
  }
}

class VectorGraphicFromAsset extends StatelessWidget {
  final String asset;

  const VectorGraphicFromAsset(
    this.asset, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return VectorGraphic(
      loader: AssetBytesLoader(asset),
    );
  }
}
