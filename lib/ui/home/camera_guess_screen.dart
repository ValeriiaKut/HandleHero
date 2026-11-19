import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hand_detection/hand_detection.dart' as hand;
import 'package:handle_hero/bloc/camera/camera_bloc.dart';
import 'package:handle_hero/bloc/camera/camera_event.dart';
import 'package:handle_hero/bloc/camera/camera_state.dart';
import 'package:handle_hero/bloc/home/home_bloc.dart';
import 'package:handle_hero/bloc/home/home_event.dart';
import 'package:handle_hero/data/camera_service.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/lives_bar.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

class CameraGuessScreen extends StatelessWidget {
  const CameraGuessScreen({
    super.key,
    required this.challengeIndex,
    this.practiceMode = false,
  });

  final int challengeIndex;
  final bool practiceMode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CameraBloc(
        CameraService(),
        challengeIndex: challengeIndex,
        practiceMode: practiceMode,
      )..add(CameraStarted()),
      child: _CameraGuessView(
        challengeIndex: challengeIndex,
        practiceMode: practiceMode,
      ),
    );
  }
}

class _CameraGuessView extends StatefulWidget {
  const _CameraGuessView({
    required this.challengeIndex,
    required this.practiceMode,
  });

  final int challengeIndex;
  final bool practiceMode;

  @override
  State<_CameraGuessView> createState() => _CameraGuessViewState();
}

class _CameraGuessViewState extends State<_CameraGuessView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    context.read<CameraBloc>().add(CameraLifecycleChanged(state));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<CameraBloc, CameraState>(
    listenWhen: (previous, current) =>
        !previous.isChallengeComplete && current.isChallengeComplete,
    listener: (context, state) {
      if (!widget.practiceMode && state.isChallengeComplete) {
        context.read<HomeBloc>().add(CoinsEarned(50));
      }
    },
    builder: _buildCameraScreen,
  );

  Widget _buildCameraScreen(BuildContext context, CameraState state) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(MyImages.backStone, fit: BoxFit.cover),
          ),
          SafeArea(
            child: Column(
              children: [
                _challengeHeader(context, state),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 12),
                  child: widget.practiceMode
                      ? const _FreePracticePanel()
                      : _ChallengeTargetPanel(state: state),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: LayoutBuilder(
                      builder: (context, constraints) => Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            child: _PixelCameraFrame(
                              child: _cameraContent(context, state),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                  child: _PixelLetterResult(state: state),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PixelCameraButton(
                        icon: Icons.cameraswitch,
                        label: 'SWITCH CAMERA',
                        onPressed: state.canSwitchCamera
                            ? () => context.read<CameraBloc>().add(
                                CameraSwitchRequested(),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (state.isChallengeOver)
            _ChallengeEndOverlay(
              isSuccess: state.isChallengeComplete,
              challengeIndex: widget.challengeIndex,
              onRetry: () =>
                  context.read<CameraBloc>().add(CameraChallengeRestarted()),
              onExit: () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }

  Widget _challengeHeader(BuildContext context, CameraState state) {
    final letterRange = switch (widget.challengeIndex) {
      0 => 'A–I',
      1 => 'A–R',
      _ => 'A–Y',
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 14, 6),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            if (widget.practiceMode)
              const SizedBox(width: 52, height: 48)
            else
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const SizedBox(
                  width: 52,
                  height: 48,
                  child: Center(child: PixelBackArrow(size: 28)),
                ),
              ),
            Expanded(
              child: widget.practiceMode
                  ? const SizedBox.shrink()
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          "GODS' TRIAL ${widget.challengeIndex + 1} · $letterRange",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 3
                              ..color = Color(0xFF286D91),
                          ),
                        ),
                        Text(
                          "GODS' TRIAL ${widget.challengeIndex + 1} · $letterRange",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF65C8E8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 52),
          ],
        ),
      ),
    );
  }

  Widget _cameraContent(BuildContext context, CameraState state) {
    if (state.photo != null) {
      return Image.file(File(state.photo!.path), fit: BoxFit.cover);
    }
    final controller = context.read<CameraBloc>().cameraController;
    if (state.isLoading ||
        !state.isCameraReady ||
        controller == null ||
        !controller.value.isInitialized) {
      return Center(
        child: state.error == null
            ? const CircularProgressIndicator(color: Color(0xFF414536))
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF414536)),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.read<CameraBloc>().add(
                        CameraRetryRequested(),
                      ),
                      child: const Text('Retry the rite'),
                    ),
                  ],
                ),
              ),
      );
    }

    final previewSize = controller.value.previewSize!;
    final previewWidth = previewSize.height;
    final previewHeight = previewSize.width;
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: previewWidth,
          height: previewHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CameraPreview(controller),
              if (state.hands.isNotEmpty && state.detectionSize != null)
                CustomPaint(
                  painter: _PixelHandLandmarksPainter(
                    hands: state.hands,
                    isFrontCamera: state.isFrontCamera,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FreePracticePanel extends StatelessWidget {
  const _FreePracticePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 440),
      child: TreasureWindow(
        title: 'SPIRIT STRENGTHENING',
        child: const Row(
          children: [
            Expanded(
              child: Text(
                'SHOW ANY LETTER SIGN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFE3D9AA),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeTargetPanel extends StatelessWidget {
  const _ChallengeTargetPanel({required this.state});

  final CameraState state;

  @override
  Widget build(BuildContext context) {
    final total = state.challengeLetters.length;
    final displayedQuestion = total == 0
        ? 0
        : (state.questionIndex + 1).clamp(1, total).toInt();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 440),
      child: TreasureWindow(
        title: 'CURRENT LETTER',
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Row(
            children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'SHOW THE SIGN FOR',
                    style: TextStyle(
                      color: Color(0xFFE3D9AA),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    state.targetLetter ?? '✓',
                    style: const TextStyle(
                      color: Color(0xFFD1C27E),
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'LETTER $displayedQuestion / $total',
                  style: const TextStyle(
                    color: Color(0xFFE3D9AA),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var index = 0; index < total; index++)
                      Container(
                        width: 20,
                        height: 8,
                        margin: const EdgeInsets.only(left: 3),
                        color: index < state.questionIndex
                            ? const Color(0xFFD1C27E)
                            : const Color(0xFF7C806C),
                      ),
                  ],
                ),
              ],
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChallengeEndOverlay extends StatelessWidget {
  const _ChallengeEndOverlay({
    required this.isSuccess,
    required this.challengeIndex,
    required this.onRetry,
    required this.onExit,
  });

  final bool isSuccess;
  final int challengeIndex;
  final VoidCallback onRetry;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: const Color(0xAA25291F),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: TreasureWindow(
                title: isSuccess ? 'Trial Complete' : 'Trial Failed',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      isSuccess ? MyImages.success : MyImages.lose,
                      width: 90,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isSuccess
                          ? 'ALL FIVE SIGNS MASTERED!'
                          : 'THE GODS DEMAND ANOTHER ATTEMPT',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE3D9AA),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSuccess
                          ? 'You mastered all 5 signs. +50 COINS!'
                          : 'The trial awaits your return.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE3D9AA),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        TreasureButton(
                          label: 'RETRY THE TRIAL',
                          onPressed: onRetry,
                          tone: TreasureButtonTone.green,
                          icon: Icons.replay,
                          labelColor: Colors.black,
                          labelShadow: false,
                        ),
                        TreasureButton(
                          label: 'BACK TO MAP',
                          onPressed: onExit,
                          tone: TreasureButtonTone.red,
                          icon: Icons.map,
                          labelColor: Colors.black,
                          labelShadow: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PixelLetterResult extends StatelessWidget {
  const _PixelLetterResult({required this.state});

  final CameraState state;

  @override
  Widget build(BuildContext context) {
    final status = !state.isClassifierReady
        ? 'MODEL FAILED TO LOAD'
        : state.feedback != null
        ? state.feedback!
        : state.predictedLetter != null
        ? 'THIS LETTER IS '
        : state.hands.isNotEmpty
        ? 'RECOGNIZING...'
        : 'SHOW YOUR HAND';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 440),
      child: TreasureWindow(
        title: 'LETTER RECOGNITION',
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    status,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Color(0xFFE3D9AA),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!state.isClassifierReady &&
                      state.classifierError != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      state.classifierError!,
                      maxLines: 6,
                      overflow: TextOverflow.clip,
                      style: const TextStyle(
                        color: Color(0xFFC78B6D),
                        fontFamily: null,
                        fontSize: 10,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              state.predictedLetter ?? (state.isClassifierReady ? '—' : '!'),
              style: TextStyle(
                color: state.isClassifierReady
                    ? const Color(0xFFD1C27E)
                    : const Color(0xFFC78B6D),
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PixelHandLandmarksPainter extends CustomPainter {
  const _PixelHandLandmarksPainter({
    required this.hands,
    required this.isFrontCamera,
  });

  final List<hand.Hand> hands;
  final bool isFrontCamera;

  @override
  void paint(Canvas canvas, Size size) {
    if (hands.isEmpty) return;
    final first = hands.first;
    final sourceWidth = first.imageWidth.toDouble();
    final sourceHeight = first.imageHeight.toDouble();
    if (sourceWidth <= 0 || sourceHeight <= 0) return;

    final scale = math.max(
      size.width / sourceWidth,
      size.height / sourceHeight,
    );
    final offsetX = (size.width - sourceWidth * scale) / 2;
    final offsetY = (size.height - sourceHeight * scale) / 2;
    Offset map(hand.HandLandmark point) {
      final x = point.x * scale + offsetX;
      return Offset(
        isFrontCamera ? size.width - x : x,
        point.y * scale + offsetY,
      );
    }

    final linePaint = Paint()
      ..color = const Color(0xFFE3D9AA)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.square
      ..isAntiAlias = false;
    final shadowPaint = Paint()
      ..color = const Color(0xFF25291F)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.square
      ..isAntiAlias = false;
    final pointPaint = Paint()
      ..color = const Color(0xFFD1C27E)
      ..isAntiAlias = false;
    final pointBorderPaint = Paint()
      ..color = const Color(0xFF25291F)
      ..isAntiAlias = false;

    for (final detectedHand in hands) {
      for (final connection in hand.handLandmarkConnections) {
        final start = detectedHand.getLandmark(connection[0]);
        final end = detectedHand.getLandmark(connection[1]);
        if (start == null || end == null) continue;
        canvas.drawLine(map(start), map(end), shadowPaint);
        canvas.drawLine(map(start), map(end), linePaint);
      }
      for (final landmark in detectedHand.landmarks) {
        if (landmark.visibility < 0.4) continue;
        final center = map(landmark);
        final rect = Rect.fromCenter(center: center, width: 13, height: 13);
        canvas.drawRect(rect, pointBorderPaint);
        canvas.drawRect(rect.deflate(3), pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelHandLandmarksPainter oldDelegate) =>
      oldDelegate.hands != hands || oldDelegate.isFrontCamera != isFrontCamera;
}

class _PixelCameraFrame extends StatelessWidget {
  const _PixelCameraFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF7C806C),
        boxShadow: [BoxShadow(color: Color(0xFF25291F), offset: Offset(0, 8))],
      ),
      padding: const EdgeInsets.all(8),
      child: CustomPaint(
        foregroundPainter: _SciFiCameraFramePainter(),
        child: Container(
          color: const Color(0xFF34382D),
          padding: const EdgeInsets.all(5),
          child: ClipRect(child: child),
        ),
      ),
    );
  }
}

class _SciFiCameraFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dark = Color(0xFF25291F);
    const gold = Color(0xFFE3D9AA);
    final darkLine = Paint()
      ..color = dark
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    final goldLine = Paint()
      ..color = gold
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    const inset = 12.0;
    const arm = 28.0;
    const cut = 9.0;
    final corners = <Path>[
      Path()
        ..moveTo(inset, inset + arm)
        ..lineTo(inset, inset + cut)
        ..lineTo(inset + cut, inset)
        ..lineTo(inset + arm, inset),
      Path()
        ..moveTo(size.width - inset - arm, inset)
        ..lineTo(size.width - inset - cut, inset)
        ..lineTo(size.width - inset, inset + cut)
        ..lineTo(size.width - inset, inset + arm),
      Path()
        ..moveTo(inset, size.height - inset - arm)
        ..lineTo(inset, size.height - inset - cut)
        ..lineTo(inset + cut, size.height - inset)
        ..lineTo(inset + arm, size.height - inset),
      Path()
        ..moveTo(size.width - inset - arm, size.height - inset)
        ..lineTo(size.width - inset - cut, size.height - inset)
        ..lineTo(size.width - inset, size.height - inset - cut)
        ..lineTo(size.width - inset, size.height - inset - arm),
    ];

    for (final path in corners) {
      canvas.drawPath(path, darkLine);
      canvas.drawPath(path, goldLine);
    }

    final markerPaint = Paint()..color = dark;
    for (final point in <Offset>[
      const Offset(inset + 5, inset + 5),
      Offset(size.width - inset - 5, inset + 5),
      Offset(inset + 5, size.height - inset - 5),
      Offset(size.width - inset - 5, size.height - inset - 5),
    ]) {
      canvas.drawRect(Rect.fromLTWH(point.dx, point.dy, 4, 4), markerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SciFiCameraFramePainter oldDelegate) => false;
}

class _PixelCameraButton extends StatelessWidget {
  const _PixelCameraButton({
    required this.icon,
    required this.onPressed,
    this.label,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF414536),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE3D9AA), width: 3),
            boxShadow: const [
              BoxShadow(color: Color(0xFF25291F), offset: Offset(0, 5)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              if (label != null) ...[
                const SizedBox(width: 8),
                Text(
                  label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
