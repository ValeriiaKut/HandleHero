import 'package:flutter/material.dart';
import 'package:handle_hero/ui/modules/module1/level_one/name_sign_screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

class LoseScreen extends StatelessWidget {
  const LoseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(MyImages.background, fit: BoxFit.cover),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: TreasureWindow(
                title: 'The Trial Continues',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(MyImages.lose, width: 130),
                    const SizedBox(height: 16),
                    TreasureButton(
                      label: 'RETRY THE TRIAL',
                      tone: TreasureButtonTone.red,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const NameSignScreen()),
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
