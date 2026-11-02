import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/exercise1/exercise1_bloc.dart';
import 'package:handle_hero/bloc/exercise1/exercise1_event.dart';
import 'package:handle_hero/bloc/exercise1/exercise1_state.dart';
import 'package:handle_hero/bloc/level/level_bloc.dart';
import 'package:handle_hero/bloc/level/level_state.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/ui/modules/module1/Level1Screen/ex2screen.dart';
import 'package:handle_hero/ui/modules/module1/Level1Screen/level1screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/answer_result_dialog.dart';
import 'package:handle_hero/widgets/lives_bar.dart';
import 'package:handle_hero/widgets/letter_sign.dart';
import 'package:handle_hero/widgets/out_of_lives_dialog.dart';

class Ex1screen extends StatelessWidget {
  const Ex1screen({super.key, this.moduleIndex = 0});

  final int moduleIndex;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          Exercise1Bloc(letters: ModuleCatalog.lettersFor(moduleIndex))
            ..add(Exercise1Started()),
      child: _Ex1View(moduleIndex: moduleIndex),
    );
  }
}

class _Ex1View extends StatelessWidget {
  const _Ex1View({required this.moduleIndex});
  final int moduleIndex;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LevelBloc, LevelState>(
          listenWhen: (previous, current) =>
              previous.isOutOfLives && !current.isOutOfLives,
          listener: (context, state) {
            context.read<Exercise1Bloc>().add(Exercise1FeedbackCleared());
          },
        ),
        BlocListener<Exercise1Bloc, Exercise1State>(
          listenWhen: (previous, current) =>
              !previous.hasFeedback && current.hasFeedback,
          listener: (context, state) {
            final isCorrect = state.isCorrect ?? false;
            if (!isCorrect) {
              handleWrongAnswer(
                context: context,
                moduleIndex: moduleIndex,
                onTryAgain: () {
                  context.read<Exercise1Bloc>().add(Exercise1FeedbackCleared());
                },
              );
              return;
            }

            showAnswerResultDialog(
              context: context,
              isCorrect: true,
              confirmLabel: 'Next',
              onConfirm: () {
                Navigator.pop(context);
                context.read<Exercise1Bloc>().add(Exercise1FeedbackCleared());
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Ex2screen(moduleIndex: moduleIndex),
                  ),
                );
              },
            );
          },
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(MyImages.background, fit: BoxFit.cover),
            ),
            LevelHeader(
              onBack: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Level1screen(moduleIndex: moduleIndex),
                  ),
                );
              },
            ),
            const Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Text(
                'What letter is this?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: BlocBuilder<Exercise1Bloc, Exercise1State>(
                builder: (context, state) {
                  if (state.currentImage.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final option = ModuleCatalog.lettersFor(
                    moduleIndex,
                  ).firstWhere((item) => item.letter == state.correctAnswer);
                  return LetterSign(option: option, size: 250);
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 18,
                  runSpacing: 4,
                  children: [
                    for (final letter in ModuleCatalog.lettersFor(
                      moduleIndex,
                    ).map((item) => item.letter))
                      TextButton(
                        onPressed: () {
                          context.read<Exercise1Bloc>().add(
                            Exercise1AnswerSelected(letter),
                          );
                        },
                        child: Text(
                          letter,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
