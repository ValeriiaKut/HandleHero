import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/exercise3/exercise3_bloc.dart';
import 'package:handle_hero/bloc/exercise3/exercise3_event.dart';
import 'package:handle_hero/bloc/exercise3/exercise3_state.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/models/models.dart';
import 'package:handle_hero/ui/modules/module1/level_one/complete_sentence_screen.dart';
import 'package:handle_hero/utils/connection_line_painter.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/answer_result_dialog.dart';
import 'package:handle_hero/widgets/letter_sign.dart';
import 'package:handle_hero/widgets/letter_glyph.dart';
import 'package:handle_hero/widgets/lives_bar.dart';
import 'package:handle_hero/widgets/out_of_lives_dialog.dart';

class MatchSignsScreen extends StatelessWidget {
  const MatchSignsScreen({super.key, this.moduleIndex = 0});

  final int moduleIndex;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          Exercise3Bloc(letters: ModuleCatalog.lettersFor(moduleIndex))
            ..add(Exercise3Started()),
      child: _Ex3View(moduleIndex: moduleIndex),
    );
  }
}

class _Ex3View extends StatelessWidget {
  const _Ex3View({required this.moduleIndex});

  static const _rowHeight = 224.0;
  final int moduleIndex;

  @override
  Widget build(BuildContext context) {
    final totalPairs = ModuleCatalog.lettersFor(moduleIndex).length;

    return BlocListener<Exercise3Bloc, Exercise3State>(
      listenWhen: (previous, current) {
        final wrongMatch =
            previous.lastMatchCorrect != false &&
            current.lastMatchCorrect == false;
        final completed =
            previous.completed.length < totalPairs &&
            current.completed.length == totalPairs;
        return wrongMatch || completed;
      },
      listener: (context, state) {
        if (state.completed.length == totalPairs) {
          showAnswerResultDialog(
            context: context,
            isCorrect: true,
            confirmLabel: 'Next',
            onConfirm: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => CompleteSentenceScreen(moduleIndex: moduleIndex),
                ),
              );
            },
          );
          return;
        }
        context.read<Exercise3Bloc>().add(Exercise3MatchFeedbackCleared());
        handleWrongAnswer(
          context: context,
          moduleIndex: moduleIndex,
          onTryAgain: () {},
        );
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(MyImages.background, fit: BoxFit.cover),
            ),
            LevelHeader(onBack: () => Navigator.pop(context)),
            Positioned.fill(
              top: 104,
              bottom: 12,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                child: BlocBuilder<Exercise3Bloc, Exercise3State>(
                  builder: (context, state) => Column(
                    children: [
                      const _OutlinedText(
                        text: 'BIND THE PAIRS',
                        fontSize: 20,
                      ),
                      const SizedBox(height: 7),
                      const _OutlinedText(
                        text: 'Tap a letter, then tap its ASL handshape',
                        fontSize: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 18),
                      const Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: _OutlinedText(
                                text: 'LETTER',
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: _OutlinedText(
                                text: 'HANDSHAPE',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 560),
                              child: _matchingBoard(context, state),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _matchingBoard(BuildContext context, Exercise3State state) {
    final rowCount = state.shuffledLetters.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = math.min(
          180.0,
          math.min(constraints.maxWidth / 2.15, _rowHeight * 1.06),
        );
        return SizedBox(
          height: rowCount * _rowHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: ConnectionLinePainter(
                    completed: state.completed,
                    letterOrder: state.shuffledLetters,
                    imageOrder: state.shuffledImages,
                    rowHeight: _rowHeight,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        for (final letter in state.shuffledLetters)
                          SizedBox(
                            height: _rowHeight,
                            child: Center(
                              child: _letterTile(
                                letter,
                                size: imageSize,
                                isDone: state.completed.contains(letter),
                                onTap: () => context.read<Exercise3Bloc>().add(
                                  Exercise3LetterSelected(letter),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        for (final option in state.shuffledImages)
                          SizedBox(
                            height: _rowHeight,
                            child: Center(
                              child: _signTile(
                                option,
                                size: imageSize,
                                isDone: state.completed.contains(
                                  option.letter,
                                ),
                                onTap: () => context
                                    .read<Exercise3Bloc>()
                                    .add(Exercise3ImageTapped(option.letter)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _letterTile(
    String letter, {
    required double size,
    required bool isDone,
    required VoidCallback onTap,
  }) {
    return _matchingTile(
      width: size,
      height: size,
      color: Colors.transparent,
      isDone: isDone,
      onTap: onTap,
      showBorder: false,
      child: LetterGlyph(letter: letter, size: size),
    );
  }

  Widget _signTile(
    LetterOption option, {
    required double size,
    required bool isDone,
    required VoidCallback onTap,
  }) {
    return _matchingTile(
      width: size,
      height: size,
      color: Colors.transparent,
      isDone: isDone,
      onTap: onTap,
      child: LetterSign(option: option, size: size),
      showBorder: false,
    );
  }

  Widget _matchingTile({
    required double width,
    required double height,
    required Color color,
    required bool isDone,
    required VoidCallback onTap,
    required Widget child,
    bool showBorder = true,
  }) {
    return Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: showBorder
            ? const BorderSide(color: Color(0xFF7C806C), width: 4)
            : BorderSide.none,
      ),
      clipBehavior: showBorder ? Clip.antiAlias : Clip.none,
      child: InkWell(
        onTap: isDone ? null : onTap,
        child: SizedBox(
          width: width,
          height: height,
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _OutlinedText extends StatelessWidget {
  const _OutlinedText({
    required this.text,
    required this.fontSize,
    this.color = const Color(0xFFE3D9AA),
  });

  final String text;
  final double fontSize;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      letterSpacing: .6,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Colors.black,
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: style.copyWith(color: color),
        ),
      ],
    );
  }
}
