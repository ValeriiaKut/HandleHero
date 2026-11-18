import 'package:flutter/material.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/models/models.dart';
import 'package:handle_hero/utils/my_images.dart';
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
                          final columns = (constraints.maxWidth / 68)
                              .floor()
                              .clamp(4, 8);
                          final spacing = constraints.maxWidth < 360
                              ? 7.0
                              : 10.0;
                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: letters.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: spacing,
                                  mainAxisSpacing: spacing,
                                  childAspectRatio: 1,
                                ),
                            itemBuilder: (context, index) =>
                                _DictionaryLetterTile(
                                  option: letters[index],
                                  onTap: () =>
                                      _showLetter(context, letters[index]),
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
              showFrame: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Builder(
                    builder: (context) {
                      final size = (MediaQuery.sizeOf(context).height * .26)
                          .clamp(100.0, 220.0);
                      return LetterSign(option: option, size: size);
                    },
                  ),
                  const SizedBox(height: 14),
                  TreasureButton(
                    label: 'CLOSE',
                    tone: TreasureButtonTone.red,
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
  const _DictionaryLetterTile({required this.option, required this.onTap});

  final LetterOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF382630),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(color: Color(0xFF28202A), offset: Offset(3, 3)),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final signSize = (constraints.maxHeight * .5).clamp(22.0, 48.0);
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LetterSign(option: option, size: signSize),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      option.letter,
                      style: const TextStyle(
                        color: Color(0xFFFFD55A),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
