import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/exercise2/exercise2_bloc.dart';
import 'package:handle_hero/bloc/exercise2/exercise2_event.dart';
import 'package:handle_hero/bloc/exercise2/exercise2_state.dart';
import 'package:handle_hero/bloc/level/level_bloc.dart';
import 'package:handle_hero/bloc/level/level_state.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/ui/modules/module1/Level1Screen/ex3screen.dart';
import 'package:handle_hero/ui/modules/module1/Level1Screen/level1screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/answer_result_dialog.dart';
import 'package:handle_hero/widgets/lives_bar.dart';
import 'package:handle_hero/widgets/out_of_lives_dialog.dart';
import 'package:handle_hero/widgets/letter_sign.dart';

class Ex2screen extends StatelessWidget {
  const Ex2screen({super.key, this.moduleIndex = 0});

  final int moduleIndex;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          Exercise2Bloc(
              letters: ModuleCatalog.lettersFor(moduleIndex),
              challengeMode: ModuleCatalog.isHardLevel(moduleIndex),
            )
            ..add(Exercise2Started()),
      child: _Ex2View(moduleIndex: moduleIndex),
    );
  }
}

class _Ex2View extends StatelessWidget {
  const _Ex2View({required this.moduleIndex});
  final int moduleIndex;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LevelBloc, LevelState>(
          listenWhen: (previous, current) =>
              previous.isOutOfLives && !current.isOutOfLives,
          listener: (context, state) {
            context.read<Exercise2Bloc>().add(Exercise2FeedbackCleared());
          },
        ),
        BlocListener<Exercise2Bloc, Exercise2State>(
          listenWhen: (previous, current) =>
              !previous.hasFeedback && current.hasFeedback,
          listener: (context, state) {
            final isCorrect = state.isCorrect ?? false;
            if (!isCorrect) {
              handleWrongAnswer(
                context: context,
                moduleIndex: moduleIndex,
                onTryAgain: () {
                  context.read<Exercise2Bloc>().add(Exercise2FeedbackCleared());
                },
              );
              return;
            }

            final isHard = ModuleCatalog.isHardLevel(moduleIndex);
            final hasMoreQuestions =
                isHard && state.questionIndex < state.totalQuestions - 1;
            showAnswerResultDialog(
              context: context,
              isCorrect: true,
              confirmLabel: hasMoreQuestions
                  ? 'Next'
                  : isHard
                  ? 'Finish'
                  : 'Next',
              onConfirm: () {
                Navigator.pop(context);
                if (hasMoreQuestions) {
                  context.read<Exercise2Bloc>().add(Exercise2NextQuestion());
                } else {
                  context.read<Exercise2Bloc>().add(
                    Exercise2FeedbackCleared(),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Ex3screen(moduleIndex: moduleIndex),
                    ),
                  );
                }
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
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: BlocBuilder<Exercise2Bloc, Exercise2State>(
                builder: (context, state) {
                  return Text(
                    ModuleCatalog.isHardLevel(moduleIndex)
                        ? '${state.questionIndex + 1}/${state.totalQuestions} · FIND ${state.targetLetter}'
                        : 'Find letter ${state.targetLetter}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ModuleCatalog.isHardLevel(moduleIndex)
                          ? 22
                          : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlueAccent,
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
              top: 158,
              bottom: 32,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: ModuleCatalog.lettersFor(moduleIndex).length,
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 180,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.92,
                      ),
                  itemBuilder: (context, index) {
                    final option = ModuleCatalog.lettersFor(
                      moduleIndex,
                    )[index];
                    return Material(
                      color: const Color(0xFFFFE9A8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFF6B3E26),
                          width: 4,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => context.read<Exercise2Bloc>().add(
                          Exercise2AnswerSelected(option.letter),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LetterSign(
                                option: option,
                                size: constraints.maxWidth * 0.68,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'SIGN ${index + 1}',
                                style: const TextStyle(
                                  color: Color(0xFF6B3E26),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
