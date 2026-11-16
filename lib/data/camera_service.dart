import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:hand_detection/hand_detection.dart' as hand;
import 'package:handle_hero/data/letter_classifier.dart';

class CameraService {
  CameraController? controller;
  hand.HandDetector? _detector;
  LetterClassifier? _letterClassifier;
  String? classifierError;
  static const _predictionWindow = 7;
  static const _requiredPredictionVotes = 5;
  List<CameraDescription> _cameras = const [];
  CameraDescription? _activeCamera;
  bool _isProcessingFrame = false;
  bool _isStartingStream = false;
  final List<String> _recentPredictions = [];
  String? _stablePrediction;
  DateTime _lastProcessedAt = DateTime.fromMillisecondsSinceEpoch(0);

  bool get canSwitchCamera => _cameras.length > 1;
  bool get isClassifierReady => _letterClassifier != null;
  bool get isFrontCamera =>
      _activeCamera?.lensDirection == CameraLensDirection.front;

  Future<void> initialize({
    CameraDescription? preferredCamera,
    required void Function(List<hand.Hand> hands, Size size, String? letter)
    onHands,
  }) async {
    if (_cameras.isEmpty) _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      throw CameraException('CameraNotFound', 'No camera found.');
    }

    final camera =
        preferredCamera ??
        _activeCamera ??
        _cameras.firstWhere(
          (item) => item.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first,
        );
    _activeCamera = camera;

    final nextController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    controller = nextController;
    await nextController.initialize();

    try {
      _detector ??= await hand.HandDetector.create(
        maxDetections: 1,
        enableTracking: true,
      );
    } catch (_) {
      // The preview and capture remain usable if the optional model fails.
    }
    classifierError = null;
    try {
      _letterClassifier ??= await LetterClassifier.load();
    } catch (error, stackTrace) {
      classifierError = error.toString();
      debugPrint('Letter classifier failed to load: $error');
      debugPrintStack(stackTrace: stackTrace);
      // Keep the hand landmark overlay available if letter recognition fails.
    }
    await _startHandDetection(onHands);
  }

  Future<void> switchCamera({
    required void Function(List<hand.Hand> hands, Size size, String? letter)
    onHands,
  }) async {
    if (!canSwitchCamera) return;
    final currentName = _activeCamera?.name;
    final next = _cameras.firstWhere(
      (camera) => camera.name != currentName,
      orElse: () => _cameras.first,
    );
    _clearPredictionHistory();
    await _disposeController();
    await initialize(preferredCamera: next, onHands: onHands);
  }

  Future<XFile?> capture() async {
    final activeController = controller;
    if (activeController == null || !activeController.value.isInitialized) {
      return null;
    }
    if (activeController.value.isStreamingImages) {
      await activeController.stopImageStream();
    }
    return activeController.takePicture();
  }

  Future<void> resumeDetection({
    required void Function(List<hand.Hand> hands, Size size, String? letter)
    onHands,
  }) => _startHandDetection(onHands);

  Future<void> pause() => _disposeController();

  Future<void> dispose() async {
    try {
      await _disposeController();
    } finally {
      await _detector?.dispose();
      _detector = null;
      await _letterClassifier?.dispose();
      _letterClassifier = null;
      _clearPredictionHistory();
    }
  }

  Future<void> _disposeController() async {
    final activeController = controller;
    controller = null;
    if (activeController == null) return;
    try {
      if (activeController.value.isStreamingImages) {
        await activeController.stopImageStream();
      }
    } finally {
      await activeController.dispose();
    }
  }

  Future<void> _startHandDetection(
    void Function(List<hand.Hand> hands, Size size, String? letter) onHands,
  ) async {
    final activeController = controller;
    final detector = _detector;
    if (detector == null ||
        activeController == null ||
        !activeController.value.isInitialized ||
        activeController.value.isStreamingImages ||
        _isStartingStream) {
      return;
    }

    _isStartingStream = true;
    try {
      await activeController.startImageStream((image) async {
        final now = DateTime.now();
        if (_isProcessingFrame ||
            now.difference(_lastProcessedAt).inMilliseconds < 140) {
          return;
        }
        _isProcessingFrame = true;
        _lastProcessedAt = now;
        try {
          final rotation = hand.rotationForFrame(
            width: image.width,
            height: image.height,
            sensorOrientation: activeController.description.sensorOrientation,
            isFrontCamera:
                activeController.description.lensDirection ==
                CameraLensDirection.front,
            deviceOrientation: activeController.value.deviceOrientation,
          );
          final size = hand.detectionSize(
            width: image.width,
            height: image.height,
            rotation: rotation,
            maxDim: 640,
          );
          final results = await detector.detectFromCameraImage(
            image,
            rotation: rotation,
            maxDim: 640,
          );
          String? letter;
          if (results.isNotEmpty && _letterClassifier != null) {
            try {
              letter = await _letterClassifier!.classify(results.first);
            } catch (_) {
              letter = null;
            }
          }
          onHands(
            results,
            size,
            _stabilizePrediction(letter, handDetected: results.isNotEmpty),
          );
        } catch (_) {
          // Ignore bad frames so they do not interrupt the preview.
        } finally {
          _isProcessingFrame = false;
        }
      });
    } finally {
      _isStartingStream = false;
    }
  }

  String? _stabilizePrediction(
    String? prediction, {
    required bool handDetected,
  }) {
    if (!handDetected) {
      _clearPredictionHistory();
      return null;
    }
    if (prediction == null) return _stablePrediction;

    _recentPredictions.add(prediction);
    if (_recentPredictions.length > _predictionWindow) {
      _recentPredictions.removeAt(0);
    }
    final counts = <String, int>{};
    for (final item in _recentPredictions) {
      counts.update(item, (count) => count + 1, ifAbsent: () => 1);
    }
    for (final entry in counts.entries) {
      if (entry.value >= _requiredPredictionVotes) {
        _stablePrediction = entry.key;
        break;
      }
    }
    return _stablePrediction;
  }

  void _clearPredictionHistory() {
    _recentPredictions.clear();
    _stablePrediction = null;
  }
}
