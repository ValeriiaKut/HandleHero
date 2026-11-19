import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/exercise2/exercise2_event.dart';
import 'package:handle_hero/bloc/exercise2/exercise2_state.dart';
import 'package:handle_hero/data/letters.dart';
import 'package:handle_hero/models/models.dart';

class Exercise2Bloc extends Bloc<Exercise2Event, Exercise2State> {
  Exercise2Bloc({
    Random? random,
    List<LetterOption>? letters,
    bool challengeMode = false,
  })
    : _random = random ?? Random(),
      _letters = letters ?? Letters.all,
      _challengeMode = challengeMode,
      super(const Exercise2State(targetLetter: '')) {
    on<Exercise2Started>(_onStarted);
    on<Exercise2AnswerSelected>(_onAnswerSelected);
    on<Exercise2NextQuestion>(_onNextQuestion);
    on<Exercise2FeedbackCleared>(_onFeedbackCleared);
  }

  final Random _random;
  final List<LetterOption> _letters;
  final bool _challengeMode;
  List<String> _questions = const [];
  int _questionIndex = 0;

  void _onStarted(Exercise2Started event, Emitter<Exercise2State> emit) {
    final letters = _letters.map((item) => item.letter).toList();
    if (letters.isEmpty) return;
    if (_challengeMode) {
      _questions = [...letters]..shuffle(_random);
    } else {
      _questions = [letters[_random.nextInt(letters.length)]];
    }
    _questionIndex = 0;
    _emitQuestion(emit);
  }

  void _emitQuestion(Emitter<Exercise2State> emit) {
    emit(
      Exercise2State(
        targetLetter: _questions[_questionIndex],
        questionIndex: _questionIndex,
        totalQuestions: _questions.length,
      ),
    );
  }

  void _onAnswerSelected(
    Exercise2AnswerSelected event,
    Emitter<Exercise2State> emit,
  ) {
    if (state.hasFeedback || state.targetLetter.isEmpty) return;
    emit(state.copyWith(isCorrect: event.letter == state.targetLetter));
  }

  void _onNextQuestion(
    Exercise2NextQuestion event,
    Emitter<Exercise2State> emit,
  ) {
    if (!state.hasFeedback || state.isCorrect != true) return;
    if (_questionIndex >= _questions.length - 1) return;
    _questionIndex++;
    _emitQuestion(emit);
  }

  void _onFeedbackCleared(
    Exercise2FeedbackCleared event,
    Emitter<Exercise2State> emit,
  ) {
    emit(state.copyWith(clearFeedback: true));
  }
}
