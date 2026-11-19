import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/models/models.dart';
import 'package:handle_hero/ui/modules/module1/level_one/mixed_challenge_screen.dart';
import 'package:handle_hero/ui/modules/module1/level_one/name_sign_screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/letter_sign.dart';
import 'package:handle_hero/widgets/letter_glyph.dart';
import 'package:handle_hero/widgets/lives_bar.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

class LevelOverviewScreen extends StatefulWidget {
  const LevelOverviewScreen({super.key, this.moduleIndex = 0});

  final int moduleIndex;

  @override
  State<LevelOverviewScreen> createState() => _LevelOverviewScreenState();
}

class _LevelOverviewScreenState extends State<LevelOverviewScreen> {
  int _cardIndex = 0;
  bool _showAnswer = false;

  @override
  Widget build(BuildContext context) {
    final letters = ModuleCatalog.lettersFor(widget.moduleIndex);
    final isHard = ModuleCatalog.isHardLevel(widget.moduleIndex);
    final moduleNumber = widget.moduleIndex - widget.moduleIndex ~/ 4 + 1;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(MyImages.background, fit: BoxFit.cover),
          ),
          LevelHeader(
            top: 50,
            onBack: () => Navigator.pop(context),
          ),
          if (!isHard)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: _outlinedModuleLabel(moduleNumber),
            ),
          Positioned(
            top: isHard ? 110 : 140,
            left: 0,
            right: 0,
            child: _outlinedText(
              isHard
                  ? "GODS' TRIAL ${widget.moduleIndex ~/ 4 + 1}"
                  : letters.map((item) => item.letter).join(' - '),
              fontSize: 28,
              color: const Color(0xFF65C8E8),
              outlineColor: const Color(0xFF286D91),
            ),
          ),
          Positioned(
            top: isHard ? 178 : 188,
            left: 16,
            right: 16,
            child: _outlinedText(
              isHard
                  ? 'Letters: ${letters.map((item) => item.letter).join(' - ')}'
                  : 'Learn each sigil, then begin your rites',
              fontSize: 14,
              color: Colors.white,
            ),
          ),
          if (isHard)
            _hardChallengeOverview()
          else if (letters.isNotEmpty)
            _flashcards(context, letters),
          if (isHard)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: _pixelButton(
                  label: 'BEGIN THE TRIAL',
                  onPressed: () => _startPractice(context),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _outlinedText(
    String text, {
    required double fontSize,
    required Color color,
    Color outlineColor = Colors.black,
    TextAlign textAlign = TextAlign.center,
  }) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 1.2,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: textAlign,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = outlineColor,
          ),
        ),
        Text(
          text,
          textAlign: textAlign,
          style: style.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _outlinedModuleLabel(int moduleNumber) {
    const label = 'SHRINE';
    const textStyle = TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.4,
    );
    return SizedBox(
      height: 26,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '$label $moduleNumber',
            style: textStyle.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 3.5
                ..color = Colors.black,
            ),
          ),
          Text(
            '$label $moduleNumber',
            style: textStyle.copyWith(color: const Color(0xFFFFFFFF)),
          ),
        ],
      ),
    );
  }

  Widget _hardChallengeOverview() {
    final steps = [
      (
        'DECODE THE SIGNS',
        'Identify handshapes in shuffled order.',
      ),
      ('FIND THE SIGIL', 'Find the handshape linked to each letter.'),
      ('BIND THE PAIRS', 'Connect each matching pair.'),
      (
        'RESTORE THE INSCRIPTION',
        'Fill the missing letter to restore each inscription.',
      ),
    ];
    return Positioned.fill(
      top: 230,
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
          color: const Color(0xFF34382D),
          border: Border.all(color: const Color(0xFF7C806C), width: 4),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFF617347),
                shape: BoxShape.circle,
              ),
              child: _outlinedText(
                number,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _outlinedText(
                    title,
                    fontSize: 12,
                    color: const Color(0xFFD1C27E),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 3),
                  _outlinedText(
                    description,
                    fontSize: 11,
                    color: const Color(0xFFE3D9AA),
                    textAlign: TextAlign.left,
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
      top: screenHeight * .25,
      bottom: compact ? 10 : 40,
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

                  _outlinedText(
                    'SIGN ${_cardIndex + 1} OF ${letters.length}',
                    fontSize: 13,
                    color: const Color(0xFFE3D9AA),
                  ),

                SizedBox(height: compact ? 5 : 15),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: (_cardIndex + 1) / letters.length,
                    backgroundColor: const Color(0xFF414536),
                    color: const Color(0xFFD1C27E),
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
                            ? 'STRENGTHEN YOUR SPIRIT'
                            : 'NEXT SIGN',
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

          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final size = math.min(340.0, constraints.maxHeight * .84);
              return Transform.translate(
                offset: const Offset(0, -45),
                child: LetterSign(option: letter, size: size),
              );
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

          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final size = math.min(340.0, constraints.maxHeight * .84);
              return Transform.translate(
                offset: const Offset(0, -45),
                child: LetterGlyph(letter: letter.letter, size: size),
              );
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
      labelColor: Colors.black,
      labelShadow: false,
    );
  }

  void _startPractice(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ModuleCatalog.isHardLevel(widget.moduleIndex)
            ? MixedChallengeScreen(moduleIndex: widget.moduleIndex)
            : NameSignScreen(moduleIndex: widget.moduleIndex),
      ),
    );
  }
}
