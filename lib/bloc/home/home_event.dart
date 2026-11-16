sealed class HomeEvent {}

final class HomeStarted extends HomeEvent {}

final class CoinsSpent extends HomeEvent {
  final int amount;

  CoinsSpent(this.amount);
}
