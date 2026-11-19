import 'package:handle_hero/models/models.dart';

class HomeState {
  final List<LevelData> levels;
  final int coins;

  const HomeState({
    required this.levels,
    required this.coins,
  });

  HomeState copyWith({
    List<LevelData>? levels,
    int? coins,
  }) {
    return HomeState(
      levels: levels ?? this.levels,
      coins: coins ?? this.coins,
    );
  }
}
