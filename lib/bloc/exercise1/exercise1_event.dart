sealed class Exercise1Event {}

final class Exercise1Started extends Exercise1Event {}

final class Exercise1AnswerSelected extends Exercise1Event {
  final String answer;

  Exercise1AnswerSelected(this.answer);
}

final class Exercise1NextQuestion extends Exercise1Event {}

final class Exercise1FeedbackCleared extends Exercise1Event {}
