sealed class Exercise4Event {}

final class Exercise4Started extends Exercise4Event {}

final class Exercise4AnswerSelected extends Exercise4Event {
  Exercise4AnswerSelected(this.letter);

  final String letter;
}

final class Exercise4NextQuestion extends Exercise4Event {}

final class Exercise4FeedbackCleared extends Exercise4Event {}
