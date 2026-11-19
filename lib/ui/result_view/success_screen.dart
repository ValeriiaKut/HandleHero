import 'package:flutter/material.dart';
import 'package:handle_hero/ui/modules/module1/level_one/find_sign_screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

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
                title: 'Victory',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(MyImages.success, width: 130),
                    const SizedBox(height: 16),
                    TreasureButton(
                      label: 'NEXT',
                      tone: TreasureButtonTone.green,
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => FindSignScreen()),
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
