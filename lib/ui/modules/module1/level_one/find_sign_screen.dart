import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'package:handle_hero/bloc/exercise2/exercise2_bloc.dart';
import 'package:handle_hero/bloc/exercise2/exercise2_event.dart';
import 'package:handle_hero/bloc/exercise2/exercise2_state.dart';
import 'package:handle_hero/bloc/level/level_bloc.dart';
import 'package:handle_hero/bloc/level/level_state.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/ui/modules/module1/level_one/match_signs_screen.dart';
import 'package:handle_hero/ui/modules/module1/level_one/level_overview_screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/answer_result_dialog.dart';
import 'package:handle_hero/widgets/lives_bar.dart';
import 'package:handle_hero/widgets/out_of_lives_dialog.dart';
import 'package:handle_hero/widgets/letter_sign.dart';

class FindSignScreen extends StatelessWidget {
  const FindSignScreen({super.key, this.moduleIndex = 0});

  final int moduleIndex;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Exercise2Bloc(
        letters: ModuleCatalog.lettersFor(moduleIndex),
        challengeMode: ModuleCatalog.isHardLevel(moduleIndex),
      )..add(Exercise2Started()),
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
                  context.read<Exercise2Bloc>().add(Exercise2FeedbackCleared());
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MatchSignsScreen(moduleIndex: moduleIndex),
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
                    builder: (_) => LevelOverviewScreen(moduleIndex: moduleIndex),
                  ),
                );
              },
            ),
            Positioned(
              top: 132,
              left: 0,
              right: 0,
              child: BlocBuilder<Exercise2Bloc, Exercise2State>(
                builder: (context, state) {
                  return Center(
                    child: _OutlinedText(
                      text: ModuleCatalog.isHardLevel(moduleIndex)
                          ? '${state.questionIndex + 1}/${state.totalQuestions} · FIND ${state.targetLetter}'
                          : 'Find letter ${state.targetLetter}',
                      fontSize: ModuleCatalog.isHardLevel(moduleIndex) ? 22 : 28,
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
              top: 190,
              bottom: 16,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final options = ModuleCatalog.lettersFor(moduleIndex);
                    final columns = constraints.maxWidth >= 660 ? 3 : 2;
                    final rows = (options.length / columns).ceil();
                    final spacing = 10.0;
                    final tileWidth =
                        (constraints.maxWidth - spacing * (columns - 1)) /
                        columns;
                    final tileHeight = math.max(
                      140.0,
                      (constraints.maxHeight - spacing * (rows - 1)) / rows,
                    );
                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                        mainAxisExtent: tileHeight,
                      ),
                      itemBuilder: (context, index) {
                        final isSoloLast =
                            options.length.isOdd && index == options.length - 1;
                        final tile = InkWell(
                          onTap: () => context.read<Exercise2Bloc>().add(
                            Exercise2AnswerSelected(options[index].letter),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LetterSign(
                                option: options[index],
                                size: math.min(
                                  tileWidth * 1.18,
                                  tileHeight * .78,
                                ),
                              ),
                              const SizedBox(height: 3),
                              _OutlinedText(
                                text: 'SIGN ${index + 1}',
                                fontSize: 13,
                              ),
                            ],
                          ),
                        );
                        return isSoloLast
                            ? Transform.translate(
                                offset: Offset(
                                  (tileWidth + spacing) / 2,
                                  -88,
                                ),
                                child: tile,
                              )
                            : tile;
                      },
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

class _OutlinedText extends StatelessWidget {
  const _OutlinedText({required this.text, required this.fontSize});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 1.2,
      letterSpacing: .5,
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
