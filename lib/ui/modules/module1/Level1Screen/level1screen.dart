import 'package:flutter/material.dart';
import 'package:handle_hero/ui/home/home_page.dart';
import 'package:handle_hero/ui/modules/module1/Level1Screen/ex1screen.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/letter_sign.dart';
import 'package:handle_hero/widgets/lives_bar.dart';

class Level1screen extends StatelessWidget {
  const Level1screen({super.key, this.moduleIndex = 0});

  final int moduleIndex;

  @override
  Widget build(BuildContext context) {
    final letters = ModuleCatalog.lettersFor(moduleIndex);
    final isHard = ModuleCatalog.isHardLevel(moduleIndex);
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
              style: TextStyle(
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
                  ? 'Review modules ${((moduleIndex ~/ 4) * 3) + 1}–${((moduleIndex ~/ 4) * 3) + 3}'
                  : 'Learn these ASL letters',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned.fill(
            top: isHard ? 246 : 160,
            bottom: 90,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: letters.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 8),
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
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Ex1screen(moduleIndex: moduleIndex),
                    ),
                  );
                },
                child: const Text('Start', style: TextStyle(fontSize: 22)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
