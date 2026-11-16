class LevelState {
  static const int defaultLives = 3;
  static const int defaultContinueCost = 20;

  final int lives;
  final int maxLives;
  final int continueCost;

  const LevelState({
    required this.lives,
    this.maxLives = defaultLives,
    this.continueCost = defaultContinueCost,
  });

  bool get isOutOfLives => lives <= 0;

  LevelState copyWith({
    int? lives,
    int? maxLives,
    int? continueCost,
  }) {
    return LevelState(
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
      continueCost: continueCost ?? this.continueCost,
    );
  }
}
