import 'package:flutter_test/flutter_test.dart';
import 'package:handle_hero/data/letter_landmark_features.dart';

void main() {
  test('normalizes landmarks like the Python trainer', () {
    final xs = [for (var index = 0; index < 21; index++) 10.0 + index];
    final ys = List<double>.filled(21, 20);
    xs[9] = 10;
    ys[9] = 25;

    final features = landmarkFeatures(xs, ys, isLeft: false);
    expect(features, isNotNull);
    expect(features, hasLength(42));
    expect(features![0], closeTo(0, 1e-6));
    expect(features[1], closeTo(0, 1e-6));
    expect(features[18], closeTo(0, 1e-6));
    expect(features[19], closeTo(1, 1e-6));
    expect(features[2], closeTo(1 / 5, 1e-6));
    expect(features[3], closeTo(0, 1e-6));
  });

  test('mirrors X for a left hand', () {
    final xs = [for (var index = 0; index < 21; index++) 10.0 + index];
    final ys = List<double>.filled(21, 20);
    xs[9] = 10;
    ys[9] = 25;

    final right = landmarkFeatures(xs, ys, isLeft: false)!;
    final left = landmarkFeatures(xs, ys, isLeft: true)!;
    for (var index = 0; index < 21; index++) {
      expect(left[index * 2], closeTo(-right[index * 2], 1e-6));
      expect(left[index * 2 + 1], closeTo(right[index * 2 + 1], 1e-6));
    }
  });
}
