import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/level/level_event.dart';
import 'package:handle_hero/bloc/level/level_state.dart';

class LevelBloc extends Bloc<LevelEvent, LevelState> {
  LevelBloc() : super(const LevelState(lives: LevelState.defaultLives)) {
    on<LevelStarted>(_onStarted);
    on<LifeLost>(_onLifeLost);
    on<LivesRestored>(_onLivesRestored);
  }

  void _onStarted(LevelStarted event, Emitter<LevelState> emit) {
    emit(const LevelState(lives: LevelState.defaultLives));
  }

  void _onLifeLost(LifeLost event, Emitter<LevelState> emit) {
    if (state.lives <= 0) return;
    emit(state.copyWith(lives: state.lives - 1));
  }

  void _onLivesRestored(LivesRestored event, Emitter<LevelState> emit) {
    emit(state.copyWith(lives: state.maxLives));
  }
}
