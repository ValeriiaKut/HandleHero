import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/exercise3/exercise3_event.dart';
import 'package:handle_hero/bloc/exercise3/exercise3_state.dart';
import 'package:handle_hero/data/letters.dart';
import 'package:handle_hero/models/models.dart';

class Exercise3Bloc extends Bloc<Exercise3Event, Exercise3State> {
  Exercise3Bloc({List<LetterOption>? letters})
    : _letters = letters ?? Letters.all,
      super(
        const Exercise3State(
          shuffledLetters: [],
          shuffledImages: [],
          completed: {},
        ),
      ) {
    on<Exercise3Started>(_onStarted);
    on<Exercise3LetterSelected>(_onLetterSelected);
    on<Exercise3ImageTapped>(_onImageTapped);
    on<Exercise3MatchFeedbackCleared>(_onMatchFeedbackCleared);
  }

  final List<LetterOption> _letters;

  void _onStarted(Exercise3Started event, Emitter<Exercise3State> emit) {
    emit(
      Exercise3State(
        shuffledLetters: _letters.map((item) => item.letter).toList()
          ..shuffle(),
        shuffledImages: [..._letters]..shuffle(),
        completed: {},
      ),
    );
  }

  void _onLetterSelected(
    Exercise3LetterSelected event,
    Emitter<Exercise3State> emit,
  ) {
    if (state.completed.contains(event.letter)) return;
    emit(state.copyWith(selectedLetter: event.letter));
  }

  void _onImageTapped(
    Exercise3ImageTapped event,
    Emitter<Exercise3State> emit,
  ) {
    if (state.selectedLetter == null) return;

    if (state.selectedLetter == event.letter) {
      emit(
        state.copyWith(
          completed: {...state.completed, event.letter},
          clearSelectedLetter: true,
        ),
      );
      return;
    }

    emit(state.copyWith(clearSelectedLetter: true, lastMatchCorrect: false));
  }

  void _onMatchFeedbackCleared(
    Exercise3MatchFeedbackCleared event,
    Emitter<Exercise3State> emit,
  ) {
    emit(state.copyWith(clearLastMatch: true));
  }
}
