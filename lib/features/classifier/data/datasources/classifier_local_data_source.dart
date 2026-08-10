import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:ink_mind/core/errors/exceptions.dart';
import 'package:ink_mind/features/classifier/domain/entities/classification_result.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

abstract interface class ClassifierLocalDataSource {
  Future<ClassificationResult> classifyImage(String imagePath);
}

/// On-device local data source performing TFLite image inference via [tflite_flutter].
class ClassifierLocalDataSourceImpl implements ClassifierLocalDataSource {
  Interpreter? _interpreter;
  IsolateInterpreter? _isolateInterpreter;
  List<String>? _labels;

  Future<void> _initIfNeeded() async {
    if (_isolateInterpreter != null && _labels != null) return;

    try {
      debugPrint('[ClassifierLocalDataSource] Loading TFLite model and labels...');
      _interpreter ??= await Interpreter.fromAsset('assets/models/mobilenet_v1_1.0_224_quant.tflite');
      _isolateInterpreter ??= await IsolateInterpreter.create(address: _interpreter!.address);

      final labelsString = await rootBundle.loadString('assets/models/labels.txt');
      _labels ??= labelsString
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      debugPrint('[ClassifierLocalDataSource] Loaded ${_labels?.length} labels.');
    } catch (e) {
      debugPrint('[ClassifierLocalDataSource] Failed to initialize TFLite: $e');
      throw ModelException('Failed to load TFLite model or labels: $e');
    }
  }

  @override
  Future<ClassificationResult> classifyImage(String imagePath) async {
    await _initIfNeeded();

    final file = File(imagePath);
    if (!file.existsSync()) {
      throw const ModelException('Selected image file does not exist.');
    }

    try {
      debugPrint('[ClassifierLocalDataSource] Preprocessing image: $imagePath');
      final imageBytes = file.readAsBytesSync();
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        throw const ModelException('Could not decode image bytes.');
      }

      // Resize image to 224x224 RGB as required by MobileNet
      final resizedImage = img.copyResize(decodedImage, width: 224, height: 224);

      // Input tensor [1, 224, 224, 3] uint8
      final input = List.generate(
        1,
        (_) => List.generate(
          224,
          (y) => List.generate(
            224,
            (x) {
              final pixel = resizedImage.getPixel(x, y);
              return [pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
            },
          ),
        ),
      );

      // Output probabilities buffer [1, 1001]
      final output = List.generate(1, (_) => List<int>.filled(1001, 0));

      debugPrint('[ClassifierLocalDataSource] Running on-device TFLite inference...');
      await _isolateInterpreter!.run(input, output);

      final probabilities = output[0];
      var maxIndex = 0;
      var maxConfidence = probabilities[0];

      for (var i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxConfidence) {
          maxConfidence = probabilities[i];
          maxIndex = i;
        }
      }

      final label = (maxIndex < (_labels?.length ?? 0))
          ? _labels![maxIndex]
          : 'Unknown';
      final confidenceScore = (maxConfidence / 255.0).clamp(0.0, 1.0);

      debugPrint('[ClassifierLocalDataSource] 🎯 Classification: "$label" (${(confidenceScore * 100).toStringAsFixed(1)}%)');
      return ClassificationResult(
        label: label,
        confidence: confidenceScore,
      );
    } catch (e) {
      debugPrint('[ClassifierLocalDataSource] Inference error: $e');
      if (e is ModelException) rethrow;
      throw ModelException(e.toString());
    }
  }
}
