import 'package:handle_hero/models/models.dart';

class SentencePrompt {
  const SentencePrompt({required this.letter, required this.sentence});

  final String letter;
  /// The underscore marks the one missing letter.
  final String sentence;
}

class SentenceActivities {
  static const _sentenceByLetter = <String, String>{
    'A': 'The c_t slept on the sofa.',
    'B': 'A _ird can fly.',
    'C': 'The _up is full of tea.',
    'D': 'The _og runs in the park.',
    'E': 'The r_d ball is on the floor.',
    'F': 'A _ox lives in the forest.',
    'G': 'The _irl is reading a book.',
    'H': 'A _en is sitting on a branch.',
    'I': 'The p_g is rolling in the mud.',
    'J': 'I drink _uice at breakfast.',
    'K': 'A _ite flew above the field.',
    'L': 'The _amp is next to the bed.',
    'M': 'The _oon is bright tonight.',
    'N': 'A _est is in the tree.',
    'O': 'The _wl sleeps during the day.',
    'P': 'A _anda eats bamboo.',
    'Q': 'The _ueen wears a crown.',
    'R': 'A _abbit is hiding in the grass.',
    'S': 'The _un is shining.',
    'T': 'A _iger has stripes.',
    'U': 'The _mbrella is by the door.',
    'V': 'The _an is parked outside.',
    'W': 'The _ater is cold.',
    'X': 'The bo_ is on the table.',
    'Y': 'A bo_ is playing outside.',
    'Z': 'A _ebra has stripes.',
  };

  static List<SentencePrompt> forLetters(List<LetterOption> letters) => [
    for (final item in letters)
      if (_sentenceByLetter[item.letter] case final sentence?)
        SentencePrompt(letter: item.letter, sentence: sentence),
  ];
}
