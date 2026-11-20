sealed class HomeEvent {}

final class HomeStarted extends HomeEvent {
  final String userId;

  HomeStarted(this.userId);
}

final class CoinsSpent extends HomeEvent {
  final int amount;

  CoinsSpent(this.amount);
}

final class CoinsEarned extends HomeEvent {
  final int amount;

  CoinsEarned(this.amount);
}

final class CoinsBalanceSynced extends HomeEvent {
  final String userId;
  final int coins;

  CoinsBalanceSynced(this.userId, this.coins);
}
