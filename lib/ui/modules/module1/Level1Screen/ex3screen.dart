import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/exercise3/exercise3_bloc.dart';
import 'package:handle_hero/bloc/exercise3/exercise3_event.dart';
import 'package:handle_hero/bloc/exercise3/exercise3_state.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/models/models.dart';
import 'package:handle_hero/ui/modules/module1/Level1Screen/ex4screen.dart';
import 'package:handle_hero/utils/LinePainter.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/answer_result_dialog.dart';
import 'package:handle_hero/widgets/letter_sign.dart';
import 'package:handle_hero/widgets/lives_bar.dart';
import 'package:handle_hero/widgets/out_of_lives_dialog.dart';

class Ex3screen extends StatelessWidget {
  const Ex3screen({super.key, this.moduleIndex = 0});

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

  static const _rowHeight = 96.0;
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
          final isHard = ModuleCatalog.isHardLevel(moduleIndex);
          showAnswerResultDialog(
            context: context,
            isCorrect: true,
            confirmLabel: isHard ? 'Map' : 'Next',
            onConfirm: () {
              Navigator.pop(context);
              if (isHard) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Ex4screen(moduleIndex: moduleIndex),
                  ),
                );
              }
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
                      const Text(
                        'MATCH THE PAIRS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Tap a letter, then tap its ASL handshape',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                'LETTER',
                                style: TextStyle(
                                  color: Color(0xFFFFE9A8),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'HANDSHAPE',
                                style: TextStyle(
                                  color: Color(0xFFFFE9A8),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          child: _matchingBoard(context, state),
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
    return SizedBox(
      height: rowCount * _rowHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: LinePainter(
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
                            isSelected: state.selectedLetter == letter,
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
                            isDone: state.completed.contains(option.letter),
                            onTap: () => context.read<Exercise3Bloc>().add(
                              Exercise3ImageTapped(option.letter),
                            ),
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
  }

  Widget _letterTile(
    String letter, {
    required bool isSelected,
    required bool isDone,
    required VoidCallback onTap,
  }) {
    final color = isDone
        ? const Color(0xFF5FA56C)
        : isSelected
        ? const Color(0xFFE6A23C)
        : const Color(0xFF6B3E26);
    return _matchingTile(
      width: 70,
      height: 70,
      color: color,
      isDone: isDone,
      onTap: onTap,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 30,
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _signTile(
    LetterOption option, {
    required bool isDone,
    required VoidCallback onTap,
  }) {
    return _matchingTile(
      width: 82,
      height: 82,
      color: isDone ? const Color(0xFFB8D8A8) : const Color(0xFFFFF1C7),
      isDone: isDone,
      onTap: onTap,
      child: LetterSign(option: option, size: 72),
    );
  }

  Widget _matchingTile({
    required double width,
    required double height,
    required Color color,
    required bool isDone,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Opacity(
      opacity: isDone ? 0.72 : 1,
      child: Material(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFF4A291B), width: 4),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isDone ? null : onTap,
          child: SizedBox(
            width: width,
            height: height,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
