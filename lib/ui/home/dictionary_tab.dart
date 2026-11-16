import 'package:flutter/material.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/models/models.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/letter_sign.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

class DictionaryTab extends StatefulWidget {
  const DictionaryTab({super.key});

  @override
  State<DictionaryTab> createState() => _DictionaryTabState();
}

class _DictionaryTabState extends State<DictionaryTab> {
  int _cardIndex = 0;
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final letters = ModuleCatalog.allLetters;
    final letter = letters[_cardIndex];

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(MyImages.background, fit: BoxFit.cover),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
          child: Column(
            children: [
              const Text(
                'СЛОВНИК',
                style: TextStyle(
                  color: Color(0xFFFFE3A3),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(color: Color(0xFF3D2117), offset: Offset(2, 3)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'КАРТКА ${_cardIndex + 1} З ${letters.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: (_cardIndex + 1) / letters.length,
                  backgroundColor: const Color(0xFF6B3E26),
                  color: const Color(0xFFFFD166),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showAnswer = !_showAnswer),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    child: _showAnswer
                        ? _answerCard(letter)
                        : _questionCard(letter),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _showAnswer
                    ? 'ЗАПАМ’ЯТАЙ БУКВУ ТА ЖЕСТ'
                    : 'НАТИСНИ НА КАРТКУ, ЩОБ ПОБАЧИТИ БУКВУ',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _pixelButton(
                      label: 'НАЗАД',
                      onPressed: _cardIndex == 0 ? null : _previous,
                      secondary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _pixelButton(
                      label: _showAnswer ? 'НАСТУПНА БУКВА' : 'ПОКАЗАТИ БУКВУ',
                      onPressed: _showAnswer
                          ? (_cardIndex == letters.length - 1 ? null : _next)
                          : () => setState(() => _showAnswer = true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _questionCard(LetterOption letter) {
    return _cardShell(
      key: ValueKey('question-${letter.letter}'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'ЯКА ЦЕ БУКВА?',
            style: TextStyle(
              color: Color(0xFFFFD55A),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          if (letter.image != null)
            Flexible(child: LetterSign(option: letter, size: 210))
          else
            _missingSignCard(),
          const SizedBox(height: 12),
          const Text(
            'НАТИСНИ, ЩОБ ВІДКРИТИ',
            style: TextStyle(
              color: Color(0xFFFFE8B2),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _answerCard(LetterOption letter) {
    return _cardShell(
      key: ValueKey('answer-${letter.letter}'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'БУКВА ${letter.letter}',
            style: const TextStyle(
              color: Color(0xFFFFD55A),
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          if (letter.image != null)
            LetterSign(option: letter, size: 120)
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Ілюстрацію жесту для цієї букви ще не додано.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFFFFE8B2)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _missingSignCard() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: const Color(0xFF382630),
        border: Border.all(color: const Color(0xFF817B6B), width: 4),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pan_tool_alt, size: 54, color: Color(0xFFFFD55A)),
          SizedBox(height: 8),
          Text(
            'ЖЕСТ ДОДАЄТЬСЯ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF382630),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardShell({required Key key, required Widget child}) {
    return TreasureWindow(key: key, child: child);
  }

  Widget _pixelButton({
    required String label,
    required VoidCallback? onPressed,
    bool secondary = false,
  }) {
    return SizedBox(
      height: 48,
      child: TreasureButton(
        label: label,
        onPressed: onPressed,
        tone: secondary ? TreasureButtonTone.red : TreasureButtonTone.green,
      ),
    );
  }

  void _previous() => setState(() {
    _cardIndex--;
    _showAnswer = false;
  });

  void _next() => setState(() {
    _cardIndex++;
    _showAnswer = true;
  });
}
