import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/exercise1/exercise1_event.dart';
import 'package:handle_hero/bloc/exercise1/exercise1_state.dart';
import 'package:handle_hero/data/letters.dart';
import 'package:handle_hero/models/models.dart';

class Exercise1Bloc extends Bloc<Exercise1Event, Exercise1State> {
  Exercise1Bloc({
    Random? random,
    List<LetterOption>? letters,
    bool challengeMode = false,
  })
    : _random = random ?? Random(),
      _letters = letters ?? Letters.all,
      _challengeMode = challengeMode,
      super(const Exercise1State(correctAnswer: '', currentImage: '')) {
    on<Exercise1Started>(_onStarted);
    on<Exercise1AnswerSelected>(_onAnswerSelected);
    on<Exercise1NextQuestion>(_onNextQuestion);
    on<Exercise1FeedbackCleared>(_onFeedbackCleared);
  }

  final Random _random;
  final List<LetterOption> _letters;
  final bool _challengeMode;
  List<LetterOption> _questions = const [];
  int _questionIndex = 0;

  void _onStarted(Exercise1Started event, Emitter<Exercise1State> emit) {
    if (_letters.isEmpty) return;
    if (_challengeMode) {
      _questions = [..._letters]..shuffle(_random);
    } else {
      _questions = [_letters[_random.nextInt(_letters.length)]];
    }
    _questionIndex = 0;
    _emitQuestion(emit);
  }

  void _emitQuestion(Emitter<Exercise1State> emit) {
    final selected = _questions[_questionIndex];
    emit(
      Exercise1State(
        correctAnswer: selected.letter,
        currentImage: selected.image ?? '',
        questionIndex: _questionIndex,
        totalQuestions: _questions.length,
      ),
    );
  }

  void _onAnswerSelected(
    Exercise1AnswerSelected event,
    Emitter<Exercise1State> emit,
  ) {
    if (state.hasFeedback || state.correctAnswer.isEmpty) return;
    emit(state.copyWith(isCorrect: event.answer == state.correctAnswer));
  }

  void _onNextQuestion(
    Exercise1NextQuestion event,
    Emitter<Exercise1State> emit,
  ) {
    if (!state.hasFeedback || state.isCorrect != true) return;
    if (_questionIndex >= _questions.length - 1) return;
    _questionIndex++;
    _emitQuestion(emit);
  }

  void _onFeedbackCleared(
    Exercise1FeedbackCleared event,
    Emitter<Exercise1State> emit,
  ) {
    emit(state.copyWith(clearFeedback: true));
  }
}
