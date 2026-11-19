import 'dart:math' as math;
import 'dart:typed_data';

const letterFeatureCount = 21 * 2;
const letterClasses = 'ABCDEFGHIJKLMNOPQRSTUVWXY';
const letterClassCount = letterClasses.length;

const _minPalmScale = 1e-5;

/// Wrist origin, palm-scale XY, left-hand X flip. Matches
/// `normalize_landmarks()` in `tools/train_asl_classifier.py`.
Float32List? landmarkFeatures(
  List<double> xs,
  List<double> ys, {
  required bool isLeft,
}) {
  if (xs.length < 21 || ys.length < 21) return null;

  final dx = Float32List(21);
  final dy = Float32List(21);
  for (var index = 0; index < 21; index++) {
    dx[index] = xs[index] - xs[0];
    dy[index] = ys[index] - ys[0];
  }

  final palmScale = math.sqrt(dx[9] * dx[9] + dy[9] * dy[9]);
  if (!palmScale.isFinite || palmScale < _minPalmScale) return null;

  final features = Float32List(letterFeatureCount);
  for (var index = 0; index < 21; index++) {
    var x = dx[index] / palmScale;
    if (isLeft) x *= -1;
    features[index * 2] = x;
    features[index * 2 + 1] = dy[index] / palmScale;
  }
  return features;
}
