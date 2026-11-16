import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/exercise4/exercise4_event.dart';
import 'package:handle_hero/bloc/exercise4/exercise4_state.dart';
import 'package:handle_hero/data/sentence_activities.dart';
import 'package:handle_hero/models/models.dart';

class Exercise4Bloc extends Bloc<Exercise4Event, Exercise4State> {
  Exercise4Bloc({required List<LetterOption> letters, Random? random})
    : _letters = letters.map((item) => item.letter).toList(growable: false),
      _random = random ?? Random(),
      super(const Exercise4State(questions: [], choices: [])) {
    on<Exercise4Started>(_onStarted);
    on<Exercise4AnswerSelected>(_onAnswerSelected);
    on<Exercise4NextQuestion>(_onNextQuestion);
    on<Exercise4FeedbackCleared>(_onFeedbackCleared);
  }

  final List<String> _letters;
  final Random _random;

  void _onStarted(Exercise4Started event, Emitter<Exercise4State> emit) {
    final questions = SentenceActivities.forLetters(
      _letters.map((letter) => LetterOption(letter, null)).toList(),
    )..shuffle(_random);
    emit(
      Exercise4State(
        questions: questions,
        choices: _shuffledChoices(),
      ),
    );
  }

  void _onAnswerSelected(
    Exercise4AnswerSelected event,
    Emitter<Exercise4State> emit,
  ) {
    final question = state.currentQuestion;
    if (question == null || state.hasFeedback) return;
    emit(state.copyWith(isCorrect: event.letter == question.letter));
  }

  void _onNextQuestion(
    Exercise4NextQuestion event,
    Emitter<Exercise4State> emit,
  ) {
    if (!state.hasFeedback || !state.isCorrect! || state.isLastQuestion) return;
    emit(
      state.copyWith(
        questionIndex: state.questionIndex + 1,
        choices: _shuffledChoices(),
        clearFeedback: true,
      ),
    );
  }

  void _onFeedbackCleared(
    Exercise4FeedbackCleared event,
    Emitter<Exercise4State> emit,
  ) {
    emit(state.copyWith(clearFeedback: true));
  }

  List<String> _shuffledChoices() => [..._letters]..shuffle(_random);
}
