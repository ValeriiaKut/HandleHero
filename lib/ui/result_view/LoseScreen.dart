import 'package:flutter/material.dart';
import 'package:handle_hero/ui/modules/module1/Level1Screen/ex1screen.dart';
import 'package:handle_hero/utils/my_images.dart';

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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  MyImages.lose,
                  width: 200,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Wrong!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Ex1screen(),
                      ),
                    );
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}