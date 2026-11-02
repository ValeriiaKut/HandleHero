class LevelData {
  final double left;
  final double top;
  final String bg;
  final String? number;
  final String title;

  const LevelData({
    required this.left,
    required this.top,
    required this.bg,
    required this.number,
    required this.title,
  });
}

class LetterOption {
  final String letter;
  final String? image;

  const LetterOption(this.letter, this.image);
}
