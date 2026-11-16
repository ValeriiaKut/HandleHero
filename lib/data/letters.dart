import 'package:handle_hero/models/models.dart';
import 'package:handle_hero/utils/my_images.dart';

class Letters {
  static const List<LetterOption> all = [
    LetterOption('A', MyImages.A),
    LetterOption('B', MyImages.B),
    LetterOption('C', MyImages.C),
  ];

  static List<String> get names => all.map((item) => item.letter).toList();
}
