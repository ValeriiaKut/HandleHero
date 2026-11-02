import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/exercise3/exercise3_bloc.dart';
import 'package:handle_hero/bloc/exercise3/exercise3_event.dart';
import 'package:handle_hero/bloc/exercise3/exercise3_state.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/utils/LinePainter.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/lives_bar.dart';
import 'package:handle_hero/widgets/out_of_lives_dialog.dart';
import 'package:handle_hero/widgets/letter_sign.dart';
import 'package:handle_hero/widgets/answer_result_dialog.dart';

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
  final int moduleIndex;

  @override
  Widget build(BuildContext context) {
    return BlocListener<Exercise3Bloc, Exercise3State>(
      listenWhen: (previous, current) {
        final wrongMatch =
            previous.lastMatchCorrect != false &&
            current.lastMatchCorrect == false;
        final completed =
            previous.completed.length <
                ModuleCatalog.lettersFor(moduleIndex).length &&
            current.completed.length ==
                ModuleCatalog.lettersFor(moduleIndex).length;
        return wrongMatch || completed;
      },
      listener: (context, state) {
        if (state.completed.length ==
            ModuleCatalog.lettersFor(moduleIndex).length) {
          showAnswerResultDialog(
            context: context,
            isCorrect: true,
            confirmLabel: 'Map',
            onConfirm: () {
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
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
            Positioned.fill(
              child: BlocBuilder<Exercise3Bloc, Exercise3State>(
                builder: (context, state) {
                  return CustomPaint(
                    painter: LinePainter(
                      state.completed,
                      ModuleCatalog.lettersFor(
                        moduleIndex,
                      ).map((item) => item.letter).toList(),
                    ),
                    child: Container(),
                  );
                },
              ),
            ),
            LevelHeader(
              onBack: () {
                Navigator.pop(context);
              },
            ),
            SafeArea(
              child: BlocBuilder<Exercise3Bloc, Exercise3State>(
                builder: (context, state) {
                  return Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: state.shuffledLetters.map((letter) {
                              final isDone = state.completed.contains(letter);
                              final isSelected = state.selectedLetter == letter;

                              return GestureDetector(
                                onTap: isDone
                                    ? null
                                    : () {
                                        context.read<Exercise3Bloc>().add(
                                          Exercise3LetterSelected(letter),
                                        );
                                      },
                                child: Container(
                                  margin: const EdgeInsets.all(10),
                                  width: 80,
                                  height: 80,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.orange
                                        : Colors.brown,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    letter,
                                    style: const TextStyle(
                                      fontSize: 32,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: state.shuffledImages.map((item) {
                              final isDone = state.completed.contains(
                                item.letter,
                              );

                              return GestureDetector(
                                onTap: isDone
                                    ? null
                                    : () {
                                        context.read<Exercise3Bloc>().add(
                                          Exercise3ImageTapped(item.letter),
                                        );
                                      },
                                child: Container(
                                  margin: const EdgeInsets.all(10),
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: LetterSign(option: item, size: 82),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
