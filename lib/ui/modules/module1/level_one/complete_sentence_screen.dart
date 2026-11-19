import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/home/home_bloc.dart';
import 'package:handle_hero/bloc/home/home_event.dart';
import 'package:handle_hero/bloc/exercise4/exercise4_bloc.dart';
import 'package:handle_hero/bloc/exercise4/exercise4_event.dart';
import 'package:handle_hero/bloc/exercise4/exercise4_state.dart';
import 'package:handle_hero/bloc/level/level_bloc.dart';
import 'package:handle_hero/bloc/level/level_state.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/data/sentence_activities.dart';
import 'package:handle_hero/models/models.dart';
import 'package:handle_hero/ui/modules/module1/level_one/level_overview_screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/answer_result_dialog.dart';
import 'package:handle_hero/widgets/letter_sign.dart';
import 'package:handle_hero/widgets/lives_bar.dart';
import 'package:handle_hero/widgets/module_completion_dialog.dart';
import 'package:handle_hero/widgets/out_of_lives_dialog.dart';

class CompleteSentenceScreen extends StatelessWidget {
  const CompleteSentenceScreen({super.key, required this.moduleIndex});

  final int moduleIndex;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          Exercise4Bloc(letters: ModuleCatalog.lettersFor(moduleIndex))
            ..add(Exercise4Started()),
      child: _Ex4View(moduleIndex: moduleIndex),
    );
  }
}

class _Ex4View extends StatelessWidget {
  const _Ex4View({required this.moduleIndex});

  final int moduleIndex;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LevelBloc, LevelState>(
          listenWhen: (previous, current) =>
              previous.isOutOfLives && !current.isOutOfLives,
          listener: (context, state) {
            context.read<Exercise4Bloc>().add(Exercise4FeedbackCleared());
          },
        ),
        BlocListener<Exercise4Bloc, Exercise4State>(
          listenWhen: (previous, current) =>
              previous.isCorrect != current.isCorrect,
          listener: (context, state) {
            if (!state.hasFeedback) return;
            if (state.isCorrect != true) {
              handleWrongAnswer(
                context: context,
                moduleIndex: moduleIndex,
                onTryAgain: () {
                  context.read<Exercise4Bloc>().add(Exercise4FeedbackCleared());
                },
              );
              return;
            }

            if (state.isLastQuestion) {
              _showModuleRewardDialog(context);
              return;
            }

            showAnswerResultDialog(
              context: context,
              isCorrect: true,
              confirmLabel: 'Next',
              onConfirm: () {
                Navigator.pop(context);
                context.read<Exercise4Bloc>().add(Exercise4NextQuestion());
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
              top: 0,
              onBack: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LevelOverviewScreen(moduleIndex: moduleIndex),
                  ),
                );
              },
            ),
            const Positioned(
              top: 55,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  _OutlinedText(
                    text: 'COMPLETE THE SENTENCE',
                    fontSize: 18,
                  ),
                  SizedBox(height: 10),
                  _OutlinedText(
                    text: 'Choose the missing letter from this level',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            Positioned.fill(
              top: 198,
              bottom: 30,
              child: BlocBuilder<Exercise4Bloc, Exercise4State>(
                builder: (context, state) {
                  final question = state.currentQuestion;
                  if (question == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: const Color(0xFFFFE9A8),
                      ),
                    );
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _OutlinedText(
                          text:
                              'SENTENCE ${state.questionIndex + 1} OF ${state.questions.length}',
                          fontSize: 14,
                        ),
                        const SizedBox(height: 15),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            value:
                                (state.questionIndex + 1) /
                                state.questions.length,
                            backgroundColor: const Color(0xFF6B3E26),
                            color: const Color(0xFFFFD166),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Transform.translate(
                              offset: const Offset(0, -55),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 560),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 28,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF382630),
                                    border: Border.all(
                                      color: const Color(0xFF817B6B),
                                      width: 4,
                                    ),
                                  ),
                                    child: _sentenceText(
                                      question,
                                      revealAnswer: state.isCorrect == true,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        const _OutlinedText(
                          text: 'PICK A LETTER',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 15),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final choiceSize = ((constraints.maxWidth - 15) / 2)
                                .clamp(120.0, 175.0)
                                .toDouble();
                            return Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 15,
                              runSpacing: 15,
                              children: [
                                for (final choice in state.choices)
                                  _LetterChoice(
                                    size: choiceSize,
                                    option: ModuleCatalog.allLetters.firstWhere(
                                      (item) => item.letter == choice,
                                    ),
                                    onTap: () => context
                                        .read<Exercise4Bloc>()
                                        .add(Exercise4AnswerSelected(choice)),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModuleRewardDialog(BuildContext context) {
    final mistakes = context.read<LevelBloc>().state.mistakes;
    final reward = switch (mistakes) {
      0 => 20,
      1 => 10,
      2 => 15,
      _ => 0,
    };
    context.read<HomeBloc>().add(CoinsEarned(reward));
    showModuleCompletionDialog(
      context: context,
      mistakes: mistakes,
      reward: reward,
      onConfirm: () {
        Navigator.pop(context);
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  Widget _sentenceText(SentencePrompt question, {required bool revealAnswer}) {
    final parts = question.sentence.split('_');
    final blank = Container(
      width: 42,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF9A5737),
        border: Border.all(color: const Color(0xFF28202A), width: 4),
      ),
      child: Text(
        revealAnswer ? question.letter.toLowerCase() : '?',
        style: const TextStyle(
          color: const Color(0xFFFFE8B2),
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          color: const Color(0xFFFFE8B2),
          fontSize: 24,
          fontWeight: FontWeight.w800,
          height: 1.45,
        ),
        children: [
          TextSpan(text: parts.first),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: blank,
            ),
          ),
          if (parts.length > 1) TextSpan(text: parts.last),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _LetterChoice extends StatelessWidget {
  const _LetterChoice({
    required this.option,
    required this.onTap,
    required this.size,
  });

  final LetterOption option;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: LetterSign(option: option, size: size)),
        ),
      ),
    );
  }
}

class _OutlinedText extends StatelessWidget {
  const _OutlinedText({
    required this.text,
    required this.fontSize,
    this.color = const Color(0xFFFFE8B2),
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
          style: style.copyWith(color: color),
        ),
      ],
    );
  }
}
