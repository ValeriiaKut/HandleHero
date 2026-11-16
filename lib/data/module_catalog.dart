import 'package:handle_hero/models/models.dart';

class ModuleCatalog {
  static const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  static const _availableSigns = <String, String>{
    'A': 'assets/images/A.png',
    'B': 'assets/images/B.png',
    'C': 'assets/images/C.png',
  };

  static final allLetters = alphabet
      .split('')
      .map((letter) => LetterOption(letter, _availableSigns[letter]))
      .toList(growable: false);

  /// The map order is three regular levels followed by one hard level,
  /// repeated three times.
  static bool isHardLevel(int mapIndex) => mapIndex >= 0 && mapIndex < 12 && mapIndex % 4 == 3;

  static int _ordinaryModuleIndex(int mapIndex) {
    final completedGroups = mapIndex ~/ 4;
    return mapIndex - completedGroups;
  }

  static List<LetterOption> lettersFor(int mapIndex) {
    if (mapIndex < 0 || mapIndex > 11) return const [];

    final groupStart = (mapIndex ~/ 4) * 3;
    if (isHardLevel(mapIndex)) {
      return [
        for (var module = groupStart; module < groupStart + 3; module++)
          ..._ordinaryModuleLetters(module),
      ];
    }

    return _ordinaryModuleLetters(_ordinaryModuleIndex(mapIndex));
  }

  static List<LetterOption> _ordinaryModuleLetters(int moduleIndex) {
    final start = moduleIndex * 3;
    final end = (start + 3).clamp(0, allLetters.length);
    return allLetters.sublist(start, end);
  }
}
