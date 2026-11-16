class Exercise2State {
  final String targetLetter;
  final int questionIndex;
  final int totalQuestions;
  final bool? isCorrect;

  const Exercise2State({
    required this.targetLetter,
    this.questionIndex = 0,
    this.totalQuestions = 1,
    this.isCorrect,
  });

  bool get hasFeedback => isCorrect != null;

  Exercise2State copyWith({
    String? targetLetter,
    int? questionIndex,
    int? totalQuestions,
    bool? isCorrect,
    bool clearFeedback = false,
  }) {
    return Exercise2State(
      targetLetter: targetLetter ?? this.targetLetter,
      questionIndex: questionIndex ?? this.questionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      isCorrect: clearFeedback ? null : (isCorrect ?? this.isCorrect),
    );
  }
}
