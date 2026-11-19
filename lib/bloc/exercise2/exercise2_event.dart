sealed class Exercise2Event {}

final class Exercise2Started extends Exercise2Event {}

final class Exercise2AnswerSelected extends Exercise2Event {
  final String letter;

  Exercise2AnswerSelected(this.letter);
}

final class Exercise2NextQuestion extends Exercise2Event {}

final class Exercise2FeedbackCleared extends Exercise2Event {}
