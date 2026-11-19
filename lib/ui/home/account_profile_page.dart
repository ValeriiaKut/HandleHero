import 'package:flutter/material.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

class AccountProfilePage extends StatelessWidget {
  const AccountProfilePage({
    super.key,
    required this.email,
    required this.onLogout,
  });

  final String email;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(MyImages.background, fit: BoxFit.cover),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: TreasureWindow(
                title: 'MY ACCOUNT',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 64,
                      color: Color(0xFFD1C27E),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE3D9AA),
                        fontFamily: 'Roboto',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TreasureButton(
                      label: 'LOG OUT',
                      tone: TreasureButtonTone.red,
                      labelColor: Colors.black,
                      labelShadow: false,
                      onPressed: onLogout,
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
}
