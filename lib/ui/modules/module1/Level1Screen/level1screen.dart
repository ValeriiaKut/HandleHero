import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/models/models.dart';
import 'package:handle_hero/ui/home/home_page.dart';
import 'package:handle_hero/ui/modules/module1/Level1Screen/ex1screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/letter_sign.dart';
import 'package:handle_hero/widgets/lives_bar.dart';

class Level1screen extends StatefulWidget {
  const Level1screen({super.key, this.moduleIndex = 0});

  final int moduleIndex;

  @override
  State<Level1screen> createState() => _Level1screenState();
}

class _Level1screenState extends State<Level1screen> {
  int _cardIndex = 0;
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final letters = ModuleCatalog.lettersFor(widget.moduleIndex);
    final isHard = ModuleCatalog.isHardLevel(widget.moduleIndex);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(MyImages.background, fit: BoxFit.cover),
          ),
          LevelHeader(
            onBack: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          ),
          if (isHard)
            Positioned(
              top: 96,
              left: 0,
              right: 0,
              child: Image.asset(
                MyImages.hardLevel,
                height: 82,
                fit: BoxFit.contain,
              ),
            ),
          Positioned(
            top: isHard ? 184 : 100,
            left: 0,
            right: 0,
            child: Text(
              letters.map((item) => item.letter).join(' - '),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.lightBlueAccent,
              ),
            ),
          ),
          Positioned(
            top: isHard ? 218 : 132,
            left: 16,
            right: 16,
            child: Text(
              isHard
                  ? 'Review modules ${((widget.moduleIndex ~/ 4) * 3) + 1}–${((widget.moduleIndex ~/ 4) * 3) + 3}'
                  : 'Study each sign, then try the activities',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (isHard)
            _hardReviewList(letters)
          else if (letters.isNotEmpty)
            _flashcards(context, letters),
          if (isHard)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: _pixelButton(
                  label: 'START REVIEW',
                  onPressed: () => _startPractice(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _hardReviewList(List<LetterOption> letters) {
    return Positioned.fill(
      top: 246,
      bottom: 90,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: letters.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final letter = letters[index];
            return SizedBox(
              height: 130,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LetterSign(option: letter, size: 115),
                  const SizedBox(width: 24),
                  Text(
                    letter.letter,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _flashcards(BuildContext context, List<LetterOption> letters) {
    final letter = letters[_cardIndex.clamp(0, letters.length - 1)];
    return Positioned.fill(
      top: 164,
      bottom: 24,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
        child: Column(
          children: [
            Text(
              'CARD ${_cardIndex + 1} OF ${letters.length}',
              style: const TextStyle(
                color: Color(0xFFFFE9A8),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 9),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: (_cardIndex + 1) / letters.length,
                backgroundColor: const Color(0xFF6B3E26),
                color: const Color(0xFFFFD166),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showAnswer = !_showAnswer),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: _showAnswer
                      ? _answerCard(letter)
                      : _questionCard(letter),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _showAnswer
                  ? 'Remember the letter and handshape'
                  : 'Look at the sign, then tap the card to reveal the letter',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _pixelButton(
                    label: 'BACK',
                    onPressed: _cardIndex == 0
                        ? null
                        : () => setState(() {
                            _cardIndex--;
                            _showAnswer = false;
                          }),
                    secondary: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: _pixelButton(
                    label: !_showAnswer
                        ? 'REVEAL LETTER'
                        : _cardIndex == letters.length - 1
                        ? 'START PRACTICE'
                        : 'NEXT LETTER',
                    onPressed: () {
                      if (!_showAnswer) {
                        setState(() => _showAnswer = true);
                      } else if (_cardIndex < letters.length - 1) {
                        setState(() {
                          _cardIndex++;
                          _showAnswer = false;
                        });
                      } else {
                        _startPractice(context);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _questionCard(LetterOption letter) {
    return _cardShell(
      key: ValueKey('question-${letter.letter}'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'WHAT LETTER IS THIS?',
            style: TextStyle(
              color: Color(0xFF6B3E26),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 16),
          if (letter.image != null)
            LayoutBuilder(
              builder: (context, constraints) {
                final size = math.min(205.0, constraints.maxHeight * .52);
                return LetterSign(option: letter, size: size);
              },
            )
          else
            _missingSignCard(),
          const SizedBox(height: 12),
          const Text(
            'Tap to reveal',
            style: TextStyle(
              color: Color(0xFF6B3E26),
              fontWeight: FontWeight.bold,
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
            'LETTER ${letter.letter}',
            style: const TextStyle(
              color: Color(0xFF6B3E26),
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (letter.image != null)
            LetterSign(option: letter, size: 112)
          else
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18),
              child: Text(
                'The sign illustration for this letter has not been added yet.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF6B3E26)),
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
        color: const Color(0xFFFFF8E5),
        border: Border.all(color: const Color(0xFF6B3E26), width: 4),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pan_tool_alt, size: 54, color: Color(0xFF6B3E26)),
          SizedBox(height: 8),
          Text(
            'SIGN IMAGE\nCOMING SOON',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B3E26),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardShell({required Key key, required Widget child}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9A8),
        border: Border.all(color: const Color(0xFF6B3E26), width: 6),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x88000000), offset: Offset(0, 7), blurRadius: 0),
        ],
      ),
      child: child,
    );
  }

  Widget _pixelButton({
    required String label,
    required VoidCallback? onPressed,
    bool secondary = false,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary
              ? const Color(0xFF6B3E26)
              : const Color(0xFFFFD166),
          foregroundColor: secondary ? Colors.white : const Color(0xFF4A291B),
          disabledBackgroundColor: const Color(0xFF765949),
          disabledForegroundColor: Colors.white54,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: Color(0xFF4A291B), width: 3),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          ),
        ),
      ),
    );
  }

  void _startPractice(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Ex1screen(moduleIndex: widget.moduleIndex),
      ),
    );
  }
}
