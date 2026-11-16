import 'package:flutter/material.dart';
import 'package:handle_hero/ui/modules/module1/Level1Screen/ex1screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

class Losescreen extends StatelessWidget {
  const Losescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              MyImages.background,
              fit: BoxFit.cover,
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: TreasureWindow(
                title: 'Try Again',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(MyImages.lose, width: 130),
                    const SizedBox(height: 16),
                    TreasureButton(
                      label: 'TRY AGAIN',
                      tone: TreasureButtonTone.red,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Ex1screen(),
                      ),
                    );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
