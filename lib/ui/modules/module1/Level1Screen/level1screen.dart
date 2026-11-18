import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/models/models.dart';
import 'package:handle_hero/ui/home/home_page.dart';
import 'package:handle_hero/ui/modules/module1/Level1Screen/ex1screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/letter_sign.dart';
import 'package:handle_hero/widgets/lives_bar.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

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
              isHard
                  ? 'CHALLENGE ${widget.moduleIndex ~/ 4 + 1}'
                  : letters.map((item) => item.letter).join(' - '),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
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
                  ? 'Recall ${letters.length} letters from modules ${((widget.moduleIndex ~/ 4) * 3) + 1}–${((widget.moduleIndex ~/ 4) * 3) + 3}'
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
            _hardChallengeOverview(letters.length)
          else if (letters.isNotEmpty)
            _flashcards(context, letters),
          if (isHard)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: _pixelButton(
                  label: 'START CHALLENGE',
                  onPressed: () => _startPractice(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _hardChallengeOverview(int letterCount) {
    final steps = [
      (
        'SIGN RECOGNITION',
        'Identify $letterCount handshapes in shuffled order.',
      ),
      ('LETTER TO HANDSHAPE', 'Find the matching sign for each target letter.'),
      ('MATCH ALL PAIRS', 'Connect all $letterCount signs and letters.'),
      (
        'SENTENCE CHALLENGE',
        'Fill the missing letter in $letterCount sentences.',
      ),
    ];
    return Positioned.fill(
      top: 256,
      bottom: 92,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 8),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView.separated(
              itemCount: steps.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) => _challengeStep(
                number: '${index + 1}',
                title: steps[index].$1,
                description: steps[index].$2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _challengeStep({
    required String number,
    required String title,
    required String description,
  }) {
    return SizedBox(
      height: 86,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF382630),
          border: Border.all(color: const Color(0xFF817B6B), width: 4),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF9A5737),
                shape: BoxShape.circle,
              ),
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFFFD55A),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFFFFE8B2),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _flashcards(BuildContext context, List<LetterOption> letters) {
    final letter = letters[_cardIndex.clamp(0, letters.length - 1)];
    final screenHeight = MediaQuery.sizeOf(context).height;
    final compact = screenHeight < 700;
    return Positioned.fill(
      top: screenHeight * .20,
      bottom: compact ? 12 : 24,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          (MediaQuery.sizeOf(context).width * .06).clamp(18.0, 32.0),
          4,
          (MediaQuery.sizeOf(context).width * .06).clamp(18.0, 32.0),
          8,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: [
                TreasureLabel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  child: Text(
                    'CARD ${_cardIndex + 1} OF ${letters.length}',
                    style: const TextStyle(
                      color: Color(0xFFFFE8B2),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 5 : 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: (_cardIndex + 1) / letters.length,
                    backgroundColor: const Color(0xFF6B3E26),
                    color: const Color(0xFFFFD166),
                  ),
                ),
                SizedBox(height: compact ? 8 : 14),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
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
                SizedBox(height: compact ? 6 : 12),
                TreasureLabel(
                  child: Text(
                    _showAnswer
                        ? 'LETTER AND HANDSHAPE'
                        : 'STUDY THE HANDSHAPE',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFFFE8B2),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 6 : 12),
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
                        label: _cardIndex == letters.length - 1
                            ? 'START PRACTICE'
                            : 'NEXT LETTER',
                        onPressed: () {
                          if (_cardIndex < letters.length - 1) {
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
          TreasureLabel(
            child: Text(
              'SIGN FOR LETTER ${letter.letter}',
              style: const TextStyle(
                color: Color(0xFFFFE8B2),
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.7,
              ),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final size = math.min(275.0, constraints.maxHeight * .68);
              return LetterSign(option: letter, size: size);
            },
          ),
          const SizedBox(height: 12),
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
          TreasureLabel(
            child: Text(
              'LETTER ${letter.letter}',
              style: const TextStyle(
                color: Color(0xFFFFE8B2),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final size = math.min(210.0, constraints.maxHeight * .65);
              return LetterSign(option: letter, size: size);
            },
          ),
        ],
      ),
    );
  }

  Widget _cardShell({required Key key, required Widget child}) {
    return KeyedSubtree(key: key, child: child);
  }

  Widget _pixelButton({
    required String label,
    required VoidCallback? onPressed,
    bool secondary = false,
  }) {
    return TreasureButton(
      label: label,
      onPressed: onPressed,
      tone: secondary ? TreasureButtonTone.red : TreasureButtonTone.green,
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
