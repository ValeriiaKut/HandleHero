import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/home/home_event.dart';
import 'package:handle_hero/bloc/home/home_state.dart';
import 'package:handle_hero/data/home_levels.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState(levels: [], coins: 0)) {
    on<HomeStarted>(_onStarted);
    on<CoinsSpent>(_onCoinsSpent);
    on<CoinsEarned>(_onCoinsEarned);
  }

  void _onStarted(HomeStarted event, Emitter<HomeState> emit) {
    emit(const HomeState(levels: HomeLevels.all, coins: 70));
  }

  void _onCoinsSpent(CoinsSpent event, Emitter<HomeState> emit) {
    if (event.amount <= 0 || state.coins < event.amount) return;
    emit(state.copyWith(coins: state.coins - event.amount));
  }

  void _onCoinsEarned(CoinsEarned event, Emitter<HomeState> emit) {
    if (event.amount <= 0) return;
    emit(state.copyWith(coins: state.coins + event.amount));
  }
}
