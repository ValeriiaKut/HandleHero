import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hand_detection/hand_detection.dart' as hand;
import 'package:handle_hero/bloc/camera/camera_event.dart';
import 'package:handle_hero/bloc/camera/camera_state.dart';
import 'package:handle_hero/data/camera_service.dart';
import 'package:handle_hero/data/letter_landmark_features.dart';

class CameraBloc extends Bloc<CameraEvent, CameraState> {
  CameraBloc(
    this._cameraService, {
    required int challengeIndex,
    this.practiceMode = false,
  })
    : challengeIndex = challengeIndex.clamp(0, 2).toInt(),
      super(
        CameraState(
          challengeLetters: _makeChallengeLetters(
            challengeIndex.clamp(0, 2).toInt(),
          ),
        ),
      ) {
    on<CameraStarted>(_onStarted);
    on<CameraChallengeRestarted>(_onChallengeRestarted);
    on<CameraRetryRequested>(_onRetryRequested);
    on<CameraSwitchRequested>(_onSwitchRequested);
    on<CameraCaptureRequested>(_onCaptureRequested);
    on<CameraRetakeRequested>(_onRetakeRequested);
    on<CameraLifecycleChanged>(_onLifecycleChanged);
    on<CameraHandsUpdated>(_onHandsUpdated);
  }

  final CameraService _cameraService;
  final int challengeIndex;
  final bool practiceMode;
  String? _lastScoredPrediction;

  static const _questionsPerChallenge = 5;

  static List<String> _makeChallengeLetters(int challengeIndex) {
    final availableCount = switch (challengeIndex) {
      0 => 9,
      1 => 18,
      _ => letterClasses.length,
    };
    final available = letterClasses.substring(0, availableCount).split('')
      ..shuffle(math.Random());
    return available.take(_questionsPerChallenge).toList(growable: false);
  }

  CameraController? get cameraController => _cameraService.controller;

  Future<void> _onStarted(CameraStarted event, Emitter<CameraState> emit) =>
      _initialize(emit);

  Future<void> _onRetryRequested(
    CameraRetryRequested event,
    Emitter<CameraState> emit,
  ) => _initialize(emit);

  Future<void> _onChallengeRestarted(
    CameraChallengeRestarted event,
    Emitter<CameraState> emit,
  ) async {
    _lastScoredPrediction = null;
    emit(
      state.copyWith(
        challengeLetters: _makeChallengeLetters(challengeIndex),
        questionIndex: 0,
        isChallengeComplete: false,
        hands: const [],
        clearDetection: true,
        clearPrediction: true,
        clearFeedback: true,
        clearError: true,
      ),
    );
    if (!state.isCameraReady) {
      await _initialize(emit);
    }
  }

  Future<void> _initialize(Emitter<CameraState> emit) async {
    emit(
      state.copyWith(
        isLoading: true,
        isCameraReady: false,
        clearError: true,
        clearClassifierError: true,
        hands: const [],
        clearDetection: true,
        clearPrediction: true,
      ),
    );
    try {
      await _cameraService.pause();
      await _cameraService.initialize(onHands: _onHandsDetected);
      emit(
        state.copyWith(
          isLoading: false,
          isCameraReady: true,
          isClassifierReady: _cameraService.isClassifierReady,
          classifierError: _cameraService.classifierError,
          canSwitchCamera: _cameraService.canSwitchCamera,
          isFrontCamera: _cameraService.isFrontCamera,
          clearError: true,
        ),
      );
    } catch (error) {
      await _cameraService.pause();
      emit(
        state.copyWith(
          isLoading: false,
          isCameraReady: false,
          error: _cameraErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _onSwitchRequested(
    CameraSwitchRequested event,
    Emitter<CameraState> emit,
  ) async {
    if (state.isLoading || !state.canSwitchCamera) return;
    _lastScoredPrediction = null;
    emit(
      state.copyWith(
        isLoading: true,
        hands: const [],
        clearDetection: true,
        clearPrediction: true,
      ),
    );
    try {
      await _cameraService.switchCamera(onHands: _onHandsDetected);
      emit(
        state.copyWith(
          isLoading: false,
          isCameraReady: true,
          isClassifierReady: _cameraService.isClassifierReady,
          classifierError: _cameraService.classifierError,
          canSwitchCamera: _cameraService.canSwitchCamera,
          isFrontCamera: _cameraService.isFrontCamera,
          clearError: true,
        ),
      );
    } catch (error) {
      await _cameraService.pause();
      emit(
        state.copyWith(
          isLoading: false,
          isCameraReady: false,
          error: _cameraErrorMessage(error),
        ),
      );
    }
  }

  Future<void> _onCaptureRequested(
    CameraCaptureRequested event,
    Emitter<CameraState> emit,
  ) async {
    if (!state.isCameraReady || state.photo != null) return;
    try {
      final photo = await _cameraService.capture();
      if (photo != null) {
        emit(
          state.copyWith(
            photo: photo,
            hands: const [],
            clearDetection: true,
            clearPrediction: true,
          ),
        );
      }
    } catch (error) {
      emit(state.copyWith(error: _cameraErrorMessage(error)));
    }
  }

  Future<void> _onRetakeRequested(
    CameraRetakeRequested event,
    Emitter<CameraState> emit,
  ) async {
    emit(
      state.copyWith(
        clearPhoto: true,
        hands: const [],
        clearError: true,
        clearPrediction: true,
      ),
    );
    try {
      await _cameraService.resumeDetection(onHands: _onHandsDetected);
    } catch (error) {
      emit(state.copyWith(error: _cameraErrorMessage(error)));
    }
  }

  Future<void> _onLifecycleChanged(
    CameraLifecycleChanged event,
    Emitter<CameraState> emit,
  ) async {
    if (state.photo != null) return;
    if (event.state == AppLifecycleState.inactive ||
        event.state == AppLifecycleState.paused) {
      _lastScoredPrediction = null;
      await _cameraService.pause();
      emit(
        state.copyWith(
          isCameraReady: false,
          hands: const [],
          clearPrediction: true,
          clearFeedback: true,
        ),
      );
    } else if (event.state == AppLifecycleState.resumed &&
        !state.isCameraReady &&
        !state.isLoading) {
      await _initialize(emit);
    }
  }

  void _onHandsDetected(
    List<hand.Hand> hands,
    Size size,
    String? predictedLetter,
  ) {
    if (!isClosed) {
      add(
        CameraHandsUpdated(
          hands: hands,
          detectionSize: size,
          predictedLetter: predictedLetter,
        ),
      );
    }
  }

  void _onHandsUpdated(CameraHandsUpdated event, Emitter<CameraState> emit) {
    if (state.photo != null) return;
    final hasHand = event.hands.isNotEmpty;
    if (!hasHand) _lastScoredPrediction = null;

    var questionIndex = state.questionIndex;
    var isComplete = state.isChallengeComplete;
    var feedback = state.feedback;
    var clearFeedback = false;

    if (!hasHand) {
      feedback = null;
      clearFeedback = true;
    } else if (!practiceMode && !state.isChallengeOver &&
        event.predictedLetter != null &&
        event.predictedLetter != _lastScoredPrediction) {
      final prediction = event.predictedLetter!;
      _lastScoredPrediction = prediction;
      if (prediction == state.targetLetter) {
        questionIndex++;
        isComplete = questionIndex >= state.challengeLetters.length;
        feedback = isComplete
            ? 'ALL FIVE LETTERS FOUND!'
            : 'CORRECT! NEXT LETTER';
      } else {
        feedback = 'THAT WAS $prediction · TRY AGAIN';
      }
    }

    emit(
      state.copyWith(
        hands: event.hands,
        detectionSize: event.detectionSize,
        predictedLetter: event.predictedLetter,
        clearPrediction: event.predictedLetter == null,
        questionIndex: questionIndex,
        isChallengeComplete: isComplete,
        feedback: feedback,
        clearFeedback: clearFeedback,
      ),
    );
  }

  String _cameraErrorMessage(Object error) {
    if (error is CameraException) {
      switch (error.code) {
        case 'CameraAccessDenied':
          return 'Allow camera access to use this screen.';
        case 'CameraAccessDeniedWithoutPrompt':
          return 'Allow camera access in your device settings.';
        case 'CameraAccessRestricted':
          return 'Camera access is restricted on this device.';
        default:
          return error.description ?? 'Could not start the camera.';
      }
    }
    return 'Camera is not available on this device.';
  }

  @override
  Future<void> close() async {
    await _cameraService.dispose();
    await super.close();
  }
}
