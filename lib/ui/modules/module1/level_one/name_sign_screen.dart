import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/exercise1/exercise1_bloc.dart';
import 'package:handle_hero/bloc/exercise1/exercise1_event.dart';
import 'package:handle_hero/bloc/exercise1/exercise1_state.dart';
import 'package:handle_hero/bloc/level/level_bloc.dart';
import 'package:handle_hero/bloc/level/level_state.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/ui/modules/module1/level_one/find_sign_screen.dart';
import 'package:handle_hero/ui/modules/module1/level_one/level_overview_screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/answer_result_dialog.dart';
import 'package:handle_hero/widgets/lives_bar.dart';
import 'package:handle_hero/widgets/letter_sign.dart';
import 'package:handle_hero/widgets/letter_glyph.dart';
import 'package:handle_hero/widgets/out_of_lives_dialog.dart';

class NameSignScreen extends StatelessWidget {
  const NameSignScreen({super.key, this.moduleIndex = 0});

  final int moduleIndex;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Exercise1Bloc(
        letters: ModuleCatalog.lettersFor(moduleIndex),
        challengeMode: ModuleCatalog.isHardLevel(moduleIndex),
      )..add(Exercise1Started()),
      child: _Ex1View(moduleIndex: moduleIndex),
    );
  }
}

class _Ex1View extends StatelessWidget {
  const _Ex1View({required this.moduleIndex});
  final int moduleIndex;

  @override
  Widget build(BuildContext context) {
    final isHardLevel = ModuleCatalog.isHardLevel(moduleIndex);

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
                  context.read<Exercise1Bloc>().add(Exercise1NextQuestion());
                } else {
                  context.read<Exercise1Bloc>().add(Exercise1FeedbackCleared());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FindSignScreen(moduleIndex: moduleIndex),
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
              top: 58,
              heartSize: 40,
              onBack: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LevelOverviewScreen(moduleIndex: moduleIndex),
                  ),
                );
              },
            ),
            Positioned(
              top: 148,
              left: 0,
              right: 0,
              child: BlocBuilder<Exercise1Bloc, Exercise1State>(
                builder: (context, state) => Center(
                  child: _OutlinedPrompt(
                    text: ModuleCatalog.isHardLevel(moduleIndex)
                        ? 'SIGN ${state.questionIndex + 1}/${state.totalQuestions} · NAME THE LETTER'
                        : 'What letter is this?',
                    fontSize: ModuleCatalog.isHardLevel(moduleIndex) ? 16 : 18,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              top: 200,
              bottom: MediaQuery.sizeOf(context).height * .34 + 20,
              child: BlocBuilder<Exercise1Bloc, Exercise1State>(
                builder: (context, state) {
                  if (state.correctAnswer.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final option = ModuleCatalog.lettersFor(
                    moduleIndex,
                  ).firstWhere((item) => item.letter == state.correctAnswer);
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final size = (constraints.maxWidth * .9)
                          .clamp(0.0, constraints.maxHeight * .92)
                          .toDouble();
                      return Center(
                        child: Transform.translate(
                          offset: Offset(0, isHardLevel ? -30 : 50),
                          child: LetterSign(option: option, size: size),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: isHardLevel ? 20 : 8,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * .34,
                ),
                child: SingleChildScrollView(
                  child: isHardLevel
                      ? Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final letter in ModuleCatalog.lettersFor(
                              moduleIndex,
                            ).map((item) => item.letter))
                              SizedBox(
                                width: 66,
                                height: 66,
                                child: InkWell(
                                  onTap: () => context
                                      .read<Exercise1Bloc>()
                                      .add(Exercise1AnswerSelected(letter)),
                                  child: Center(
                                    child: LetterGlyph(letter: letter, size: 62),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (final letter in ModuleCatalog.lettersFor(
                              moduleIndex,
                            ).map((item) => item.letter))
                              Expanded(
                                child: SizedBox(
                                  height: 96,
                                  child: InkWell(
                                    onTap: () => context
                                        .read<Exercise1Bloc>()
                                        .add(Exercise1AnswerSelected(letter)),
                                    child: Center(
                                      child: LetterGlyph(
                                        letter: letter,
                                        size: 92,
                                      ),
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
}

class _OutlinedPrompt extends StatelessWidget {
  const _OutlinedPrompt({required this.text, required this.fontSize});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      height: 1.2,
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
          style: style.copyWith(color: const Color(0xFFFFE8B2)),
        ),
      ],
    );
  }
}
