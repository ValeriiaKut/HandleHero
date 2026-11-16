import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/exercise4/exercise4_bloc.dart';
import 'package:handle_hero/bloc/exercise4/exercise4_event.dart';
import 'package:handle_hero/bloc/exercise4/exercise4_state.dart';
import 'package:handle_hero/bloc/level/level_bloc.dart';
import 'package:handle_hero/bloc/level/level_state.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/data/sentence_activities.dart';
import 'package:handle_hero/models/models.dart';
import 'package:handle_hero/ui/modules/module1/Level1Screen/level1screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/answer_result_dialog.dart';
import 'package:handle_hero/widgets/letter_sign.dart';
import 'package:handle_hero/widgets/lives_bar.dart';
import 'package:handle_hero/widgets/out_of_lives_dialog.dart';

class Ex4screen extends StatelessWidget {
  const Ex4screen({super.key, required this.moduleIndex});

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
              !previous.hasFeedback && current.hasFeedback,
          listener: (context, state) {
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

            showAnswerResultDialog(
              context: context,
              isCorrect: true,
              confirmLabel: state.isLastQuestion ? 'Map' : 'Next',
              onConfirm: () {
                Navigator.pop(context);
                if (state.isLastQuestion) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                } else {
                  context.read<Exercise4Bloc>().add(Exercise4NextQuestion());
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Level1screen(moduleIndex: moduleIndex),
                  ),
                );
              },
            ),
            const Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Text(
                    'COMPLETE THE SENTENCE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Choose the missing letter from this level',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              top: 174,
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
                        Text(
                          'SENTENCE ${state.questionIndex + 1} OF ${state.questions.length}',
                          style: const TextStyle(
                            color: const Color(0xFFFFE9A8),
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 9),
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
                            child: SizedBox(
                              width: double.infinity,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 28,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFE9A8),
                                  border: Border.all(
                                    color: const Color(0xFF6B3E26),
                                    width: 6,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x77000000),
                                      offset: Offset(0, 7),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: _sentenceText(
                                  question,
                                  revealAnswer: state.isCorrect == true,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'PICK A LETTER',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 14,
                          runSpacing: 10,
                          children: [
                            for (final choice in state.choices)
                              _LetterChoice(
                                option: ModuleCatalog.allLetters.firstWhere(
                                  (item) => item.letter == choice,
                                ),
                                onTap: () => context.read<Exercise4Bloc>().add(
                                  Exercise4AnswerSelected(choice),
                                ),
                              ),
                          ],
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

  Widget _sentenceText(SentencePrompt question, {required bool revealAnswer}) {
    final parts = question.sentence.split('_');
    final blank = Container(
      width: 42,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD166),
        border: Border.all(color: const Color(0xFF6B3E26), width: 4),
        boxShadow: const [BoxShadow(color: Color(0x667A3A1C), blurRadius: 4)],
      ),
      child: Text(
        revealAnswer ? question.letter.toLowerCase() : '?',
        style: const TextStyle(
          color: const Color(0xFF4A291B),
          fontSize: 28,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          color: const Color(0xFF4A291B),
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
  const _LetterChoice({required this.option, required this.onTap});

  final LetterOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFD166),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFF4A291B), width: 4),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 76,
          height: 76,
          child: Center(child: LetterSign(option: option, size: 64)),
        ),
      ),
    );
  }
}
