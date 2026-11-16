sealed class Exercise3Event {}

final class Exercise3Started extends Exercise3Event {}

final class Exercise3LetterSelected extends Exercise3Event {
  final String letter;

  Exercise3LetterSelected(this.letter);
}

final class Exercise3ImageTapped extends Exercise3Event {
  final String letter;

  Exercise3ImageTapped(this.letter);
}

final class Exercise3MatchFeedbackCleared extends Exercise3Event {}
