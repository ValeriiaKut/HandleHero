import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

class AccountProfilePage extends StatelessWidget {
  const AccountProfilePage({
    super.key,
    required this.email,
    required this.name,
    required this.userId,
    required this.onLogout,
  });

  final String email;
  final String name;
  final String userId;
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
                    if (name.isNotEmpty) ...[
                      Text(
                        name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    SelectableText(
                      email,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFE3D9AA),
                        fontFamily: 'Roboto',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'YOUR PLAYER ID',
                      style: TextStyle(
                        color: Color(0xFFD1C27E),
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: SelectableText(
                            userId,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'Roboto',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Copy player ID',
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.copy,
                            color: Color(0xFFD1C27E),
                            size: 18,
                          ),
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: userId));
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Player ID copied.')),
                            );
                          },
                        ),
                      ],
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
