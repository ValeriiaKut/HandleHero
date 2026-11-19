import 'package:flutter/material.dart';
import 'package:handle_hero/data/letter_finger_descriptions.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/models/models.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/letter_glyph.dart';
import 'package:handle_hero/widgets/letter_sign.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

class DictionaryTab extends StatelessWidget {
  const DictionaryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final letters = ModuleCatalog.allLetters;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(MyImages.background, fit: BoxFit.cover),
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    const TreasureBanner(title: 'Dictionary'),
                    const SizedBox(height: 10),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          const spacing = 12.0;
                          final tileSize =
                              (constraints.maxWidth - spacing * 2) / 3;
                          final glyphSize = (tileSize * .82)
                              .clamp(0.0, 180.0)
                              .toDouble();
                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: letters.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  crossAxisSpacing: spacing,
                                  mainAxisSpacing: spacing,
                                  childAspectRatio: 1,
                                ),
                            itemBuilder: (context, index) => _DictionaryLetterTile(
                              letter: letters[index].letter,
                              size: glyphSize,
                              onTap: () => _showLetter(context, letters[index]),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLetter(BuildContext context, LetterOption option) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 420,
            maxHeight: MediaQuery.sizeOf(dialogContext).height * .86,
          ),
          child: SingleChildScrollView(
            child: TreasureWindow(
              title: 'Letter ${option.letter}',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LetterSign(
                    option: option,
                    size: (MediaQuery.sizeOf(dialogContext).height * .25)
                        .clamp(120.0, 220.0)
                        .toDouble(),
                  ),
                  const SizedBox(height: 8),
                  const TreasureBanner(
                    title: 'Finger positions',
                    backgroundColor: Color(0xFF547541),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    letterFingerDescriptions[option.letter] ??
                        'Use the handshape shown above.',
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Color(0xFFFFE8B2),
                      fontSize: 11,
                      height: 1.7,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TreasureButton(
                    label: 'CLOSE',
                    tone: TreasureButtonTone.red,
                    labelColor: Colors.black,
                    labelShadow: false,
                    onPressed: () => Navigator.pop(dialogContext),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DictionaryLetterTile extends StatelessWidget {
  const _DictionaryLetterTile({
    required this.letter,
    required this.size,
    required this.onTap,
  });

  final String letter;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(child: LetterGlyph(letter: letter, size: size)),
    );
  }
}
