import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
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
    on<CoinsBalanceSynced>(_onCoinsBalanceSynced);
  }

  String? _activeUserId;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _coinsSubscription;

  String _coinKey(String userId) => 'coins_$userId';

  DocumentReference<Map<String, dynamic>> _userRef(String userId) =>
      FirebaseFirestore.instance.collection('users').doc(userId);

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    if (_activeUserId == event.userId) return;
    _activeUserId = event.userId;
    await _coinsSubscription?.cancel();
    emit(const HomeState(levels: HomeLevels.all, coins: 0));

    final preferences = await SharedPreferences.getInstance();
    final cachedCoins = preferences.getInt(_coinKey(event.userId)) ?? 100;
    final reference = _userRef(event.userId);
    final snapshot = await reference.get();
    final storedCoins = (snapshot.data()?['coins'] as num?)?.toInt();
    final coins = storedCoins ?? cachedCoins;
    if (!snapshot.exists) {
      await reference.set({
        'id': event.userId,
        'name': '',
        'createdAt': FieldValue.serverTimestamp(),
        'coins': coins,
      });
    } else if (storedCoins == null) {
      await reference.set({'coins': coins}, SetOptions(merge: true));
    }
    if (_activeUserId != event.userId) return;
    await preferences.setInt(_coinKey(event.userId), coins);
    emit(HomeState(levels: HomeLevels.all, coins: coins));
    _coinsSubscription = reference.snapshots().listen((document) {
      final current = (document.data()?['coins'] as num?)?.toInt();
      if (current != null) add(CoinsBalanceSynced(event.userId, current));
    });
  }

  Future<void> _onCoinsSpent(CoinsSpent event, Emitter<HomeState> emit) async {
    if (event.amount <= 0) return;
    await _changeCoins(event.amount, spend: true, emit: emit);
  }

  Future<void> _onCoinsEarned(CoinsEarned event, Emitter<HomeState> emit) async {
    if (event.amount <= 0) return;
    await _changeCoins(event.amount, spend: false, emit: emit);
  }

  Future<void> _changeCoins(
    int amount, {
    required bool spend,
    required Emitter<HomeState> emit,
  }) async {
    final userId = _activeUserId;
    if (userId == null) return;
    final reference = _userRef(userId);
    final newBalance = await FirebaseFirestore.instance.runTransaction<int?>(
      (transaction) async {
        final document = await transaction.get(reference);
        final current = (document.data()?['coins'] as num?)?.toInt() ?? state.coins;
        if (spend && current < amount) return null;
        final updated = spend ? current - amount : current + amount;
        transaction.set(reference, {'coins': updated}, SetOptions(merge: true));
        return updated;
      },
    );
    if (newBalance == null || _activeUserId != userId) return;
    emit(state.copyWith(coins: newBalance));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_coinKey(userId), newBalance);
  }

  Future<void> _onCoinsBalanceSynced(
    CoinsBalanceSynced event,
    Emitter<HomeState> emit,
  ) async {
    if (_activeUserId != event.userId) return;
    emit(state.copyWith(coins: event.coins));
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_coinKey(event.userId), event.coins);
  }

  @override
  Future<void> close() async {
    await _coinsSubscription?.cancel();
    return super.close();
  }
}
