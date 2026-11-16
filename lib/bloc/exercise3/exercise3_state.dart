import 'package:handle_hero/models/models.dart';

class Exercise3State {
  final List<String> shuffledLetters;
  final List<LetterOption> shuffledImages;
  final String? selectedLetter;
  final Set<String> completed;
  final bool? lastMatchCorrect;

  const Exercise3State({
    required this.shuffledLetters,
    required this.shuffledImages,
    required this.completed,
    this.selectedLetter,
    this.lastMatchCorrect,
  });

  Exercise3State copyWith({
    List<String>? shuffledLetters,
    List<LetterOption>? shuffledImages,
    String? selectedLetter,
    Set<String>? completed,
    bool? lastMatchCorrect,
    bool clearSelectedLetter = false,
    bool clearLastMatch = false,
  }) {
    return Exercise3State(
      shuffledLetters: shuffledLetters ?? this.shuffledLetters,
      shuffledImages: shuffledImages ?? this.shuffledImages,
      selectedLetter:
          clearSelectedLetter ? null : (selectedLetter ?? this.selectedLetter),
      completed: completed ?? this.completed,
      lastMatchCorrect: clearLastMatch
          ? null
          : (lastMatchCorrect ?? this.lastMatchCorrect),
    );
  }
}
