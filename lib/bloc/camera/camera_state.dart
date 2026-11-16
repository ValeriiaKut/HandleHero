import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:hand_detection/hand_detection.dart' as hand;

class CameraState {
  const CameraState({
    this.challengeLetters = const [],
    this.questionIndex = 0,
    this.isChallengeComplete = false,
    this.feedback,
    this.isLoading = true,
    this.isCameraReady = false,
    this.isClassifierReady = false,
    this.canSwitchCamera = false,
    this.isFrontCamera = false,
    this.hands = const [],
    this.predictedLetter,
    this.photo,
    this.error,
    this.classifierError,
    this.detectionSize,
  });

  final List<String> challengeLetters;
  final int questionIndex;
  final bool isChallengeComplete;
  final String? feedback;

  String? get targetLetter => questionIndex < challengeLetters.length
      ? challengeLetters[questionIndex]
      : null;

  bool get isChallengeOver => isChallengeComplete;

  final bool isLoading;
  final bool isCameraReady;
  final bool isClassifierReady;
  final bool canSwitchCamera;
  final bool isFrontCamera;
  final List<hand.Hand> hands;
  final String? predictedLetter;
  final XFile? photo;
  final String? error;
  final String? classifierError;
  final Size? detectionSize;

  CameraState copyWith({
    List<String>? challengeLetters,
    int? questionIndex,
    bool? isChallengeComplete,
    String? feedback,
    bool? isLoading,
    bool? isCameraReady,
    bool? isClassifierReady,
    bool? canSwitchCamera,
    bool? isFrontCamera,
    List<hand.Hand>? hands,
    String? predictedLetter,
    XFile? photo,
    String? error,
    String? classifierError,
    Size? detectionSize,
    bool clearPhoto = false,
    bool clearError = false,
    bool clearClassifierError = false,
    bool clearDetection = false,
    bool clearPrediction = false,
    bool clearFeedback = false,
  }) {
    return CameraState(
      challengeLetters: challengeLetters ?? this.challengeLetters,
      questionIndex: questionIndex ?? this.questionIndex,
      isChallengeComplete: isChallengeComplete ?? this.isChallengeComplete,
      feedback: clearFeedback ? null : (feedback ?? this.feedback),
      isLoading: isLoading ?? this.isLoading,
      isCameraReady: isCameraReady ?? this.isCameraReady,
      isClassifierReady: isClassifierReady ?? this.isClassifierReady,
      canSwitchCamera: canSwitchCamera ?? this.canSwitchCamera,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      hands: hands ?? this.hands,
      predictedLetter: clearPrediction
          ? null
          : (predictedLetter ?? this.predictedLetter),
      photo: clearPhoto ? null : (photo ?? this.photo),
      error: clearError ? null : (error ?? this.error),
      classifierError: clearClassifierError
          ? null
          : (classifierError ?? this.classifierError),
      detectionSize: clearDetection
          ? null
          : (detectionSize ?? this.detectionSize),
    );
  }
}
