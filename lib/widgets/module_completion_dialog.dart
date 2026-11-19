import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

Future<void> showModuleCompletionDialog({
  required BuildContext context,
  required int mistakes,
  required int reward,
  required VoidCallback onConfirm,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(dialogContext).height * .88,
          maxWidth: math.min(
            MediaQuery.sizeOf(dialogContext).width - 48,
            520.0,
          ),
        ),
        child: SingleChildScrollView(
          child: TreasureWindow(
            title: 'TREASURE CHEST',
            titleBackgroundColor: const Color(0xFF547541),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'MODULE COMPLETE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFFE8B2),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Image.asset(MyImages.success, width: 180),
                const SizedBox(height: 12),
                Text(
                  'MISTAKES: $mistakes',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFE8B2),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '+$reward COINS',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFD166),
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 14),
                TreasureButton(
                  label: 'MAP',
                  onPressed: onConfirm,
                  tone: TreasureButtonTone.green,
                  labelColor: Colors.black,
                  labelShadow: false,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
