import 'package:handle_hero/models/models.dart';
import 'package:handle_hero/data/module_catalog.dart';

class Letters {
  static final List<LetterOption> all = ModuleCatalog.allLetters;

  static List<String> get names => all.map((item) => item.letter).toList();
}
