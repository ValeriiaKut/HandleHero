class LevelState {
  static const int defaultLives = 3;
  static const int defaultContinueCost = 20;

  final int lives;
  final int maxLives;
  final int continueCost;
  final int mistakes;

  const LevelState({
    required this.lives,
    this.maxLives = defaultLives,
    this.continueCost = defaultContinueCost,
    this.mistakes = 0,
  });

  bool get isOutOfLives => lives <= 0;

  LevelState copyWith({
    int? lives,
    int? maxLives,
    int? continueCost,
    int? mistakes,
  }) {
    return LevelState(
      lives: lives ?? this.lives,
      maxLives: maxLives ?? this.maxLives,
      continueCost: continueCost ?? this.continueCost,
      mistakes: mistakes ?? this.mistakes,
    );
  }
}
