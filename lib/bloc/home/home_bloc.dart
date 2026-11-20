import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/home/home_event.dart';
import 'package:handle_hero/bloc/home/home_state.dart';
import 'package:handle_hero/data/home_levels.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeState(levels: [], coins: 0)) {
    on<HomeStarted>(_onStarted);
    on<CoinsSpent>(_onCoinsSpent);
    on<CoinsEarned>(_onCoinsEarned);
  }

  String? _activeUserId;

  String _coinKey(String userId) => 'coins_$userId';

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    if (_activeUserId == event.userId) return;
    _activeUserId = event.userId;
    emit(const HomeState(levels: HomeLevels.all, coins: 0));
    final preferences = await SharedPreferences.getInstance();
    var coins = preferences.getInt(_coinKey(event.userId));
    if (coins == null) {
      coins = 100;
      await preferences.setInt(_coinKey(event.userId), coins);
    }
    if (_activeUserId != event.userId) return;
    emit(HomeState(levels: HomeLevels.all, coins: coins));
  }

  Future<void> _onCoinsSpent(CoinsSpent event, Emitter<HomeState> emit) async {
    if (event.amount <= 0 || state.coins < event.amount) return;
    final coins = state.coins - event.amount;
    emit(state.copyWith(coins: coins));
    final userId = _activeUserId;
    if (userId != null) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt(_coinKey(userId), coins);
    }
  }

  Future<void> _onCoinsEarned(CoinsEarned event, Emitter<HomeState> emit) async {
    if (event.amount <= 0) return;
    final coins = state.coins + event.amount;
    emit(state.copyWith(coins: coins));
    final userId = _activeUserId;
    if (userId != null) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setInt(_coinKey(userId), coins);
    }
  }
}
