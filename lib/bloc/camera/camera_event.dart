import 'package:flutter/widgets.dart';
import 'package:hand_detection/hand_detection.dart' as hand;

sealed class CameraEvent {}

final class CameraStarted extends CameraEvent {}

final class CameraChallengeRestarted extends CameraEvent {}

final class CameraRetryRequested extends CameraEvent {}

final class CameraSwitchRequested extends CameraEvent {}

final class CameraCaptureRequested extends CameraEvent {}

final class CameraRetakeRequested extends CameraEvent {}

final class CameraLifecycleChanged extends CameraEvent {
  CameraLifecycleChanged(this.state);

  final AppLifecycleState state;
}

final class CameraHandsUpdated extends CameraEvent {
  CameraHandsUpdated({
    required this.hands,
    required this.detectionSize,
    required this.predictedLetter,
  });

  final List<hand.Hand> hands;
  final Size detectionSize;
  final String? predictedLetter;
}
