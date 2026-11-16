import 'dart:typed_data';

import 'package:flutter_litert/native.dart'
    show Interpreter, IsolateInterpreter;
import 'package:hand_detection/hand_detection.dart' as hand;
import 'package:handle_hero/data/letter_landmark_features.dart';

/// Runs the A–Y landmark classifier exported by train_asl_classifier.py.
class LetterClassifier {
  LetterClassifier._({
    required Interpreter interpreter,
    required IsolateInterpreter isolateInterpreter,
  }) : _interpreter = interpreter,
       _isolateInterpreter = isolateInterpreter;

  static const _minConfidence = 0.35;

  final Interpreter _interpreter;
  final IsolateInterpreter _isolateInterpreter;

  static Future<LetterClassifier> load() async {
    final interpreter = await Interpreter.fromAsset('assets/model.tflite');
    try {
      final inputShape = interpreter.getInputTensor(0).shape;
      final outputTensors = interpreter.getOutputTensors();
      final outputShape = outputTensors.length == 1
          ? outputTensors.single.shape
          : const <int>[];

      final expectedInput = <int>[1, letterFeatureCount];
      final expectedOutput = <int>[1, letterClassCount];
      if (!_sameShape(inputShape, expectedInput) ||
          !_sameShape(outputShape, expectedOutput)) {
        throw StateError(
          'The A–Y landmark model must have input $expectedInput and output '
          '$expectedOutput; found input $inputShape and outputs '
          '${outputTensors.map((tensor) => tensor.shape).toList()}.',
        );
      }

      final isolate = await IsolateInterpreter.create(
        address: interpreter.address,
        debugName: 'AslLandmarkClassifier',
      );
      return LetterClassifier._(
        interpreter: interpreter,
        isolateInterpreter: isolate,
      );
    } catch (_) {
      interpreter.close();
      rethrow;
    }
  }

  Future<String?> classify(hand.Hand detectedHand) async {
    final input = featuresFor(detectedHand);
    if (input == null) return null;

    final output = [List<double>.filled(letterClassCount, 0)];
    await _isolateInterpreter.run(input, output);

    var bestIndex = 0;
    for (var index = 1; index < output.single.length; index++) {
      if (output.single[index] > output.single[bestIndex]) bestIndex = index;
    }
    if (output.single[bestIndex] < _minConfidence) return null;
    return letterClasses[bestIndex];
  }

  static Float32List? featuresFor(hand.Hand detectedHand) {
    final landmarks = detectedHand.landmarks;
    if (detectedHand.imageWidth <= 0 || detectedHand.imageHeight <= 0) {
      return null;
    }
    if (landmarks.length < 21) return null;

    final ordered = List<hand.HandLandmark?>.filled(21, null);
    for (final landmark in landmarks) {
      ordered[landmark.type.index] = landmark;
    }
    if (ordered.any((landmark) => landmark == null)) return null;

    // Must stay in sync with normalize_landmarks() in the training script.
    // MediaPipe training points are normalized to [0, 1] per image axis.
    return landmarkFeatures(
      [for (final point in ordered) point!.x / detectedHand.imageWidth],
      [for (final point in ordered) point!.y / detectedHand.imageHeight],
      isLeft: detectedHand.handedness == hand.Handedness.left,
    );
  }

  static bool _sameShape(List<int> actual, List<int> expected) {
    if (actual.length != expected.length) return false;
    for (var index = 0; index < actual.length; index++) {
      if (actual[index] != expected[index]) return false;
    }
    return true;
  }

  Future<void> dispose() async {
    await _isolateInterpreter.close();
    _interpreter.close();
  }
}
