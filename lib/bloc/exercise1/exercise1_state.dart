class Exercise1State {
  final String correctAnswer;
  final String currentImage;
  final int questionIndex;
  final int totalQuestions;
  final bool? isCorrect;

  const Exercise1State({
    required this.correctAnswer,
    required this.currentImage,
    this.questionIndex = 0,
    this.totalQuestions = 1,
    this.isCorrect,
  });

  bool get hasFeedback => isCorrect != null;

  Exercise1State copyWith({
    String? correctAnswer,
    String? currentImage,
    int? questionIndex,
    int? totalQuestions,
    bool? isCorrect,
    bool clearFeedback = false,
  }) {
    return Exercise1State(
      correctAnswer: correctAnswer ?? this.correctAnswer,
      currentImage: currentImage ?? this.currentImage,
      questionIndex: questionIndex ?? this.questionIndex,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      isCorrect: clearFeedback ? null : (isCorrect ?? this.isCorrect),
    );
  }
}
