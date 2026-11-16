import 'package:handle_hero/data/sentence_activities.dart';

class Exercise4State {
  const Exercise4State({
    required this.questions,
    required this.choices,
    this.questionIndex = 0,
    this.isCorrect,
  });

  final List<SentencePrompt> questions;
  final List<String> choices;
  final int questionIndex;
  final bool? isCorrect;

  bool get hasFeedback => isCorrect != null;
  bool get hasQuestions => questions.isNotEmpty;
  bool get isLastQuestion => questionIndex >= questions.length - 1;
  SentencePrompt? get currentQuestion =>
      hasQuestions ? questions[questionIndex] : null;

  Exercise4State copyWith({
    List<SentencePrompt>? questions,
    List<String>? choices,
    int? questionIndex,
    bool? isCorrect,
    bool clearFeedback = false,
  }) =>
      Exercise4State(
        questions: questions ?? this.questions,
        choices: choices ?? this.choices,
        questionIndex: questionIndex ?? this.questionIndex,
        isCorrect: clearFeedback ? null : (isCorrect ?? this.isCorrect),
      );
}
