import 'package:flutter/material.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

Future<void> showAnswerResultDialog({
  required BuildContext context,
  required bool isCorrect,
  required String confirmLabel,
  required VoidCallback onConfirm,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: TreasureWindow(
        title: isCorrect ? 'Correct!' : 'Wrong!',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(isCorrect ? MyImages.success : MyImages.lose, width: 120),
            const SizedBox(height: 12),
            TreasureButton(
              label: confirmLabel,
              onPressed: onConfirm,
              tone: isCorrect ? TreasureButtonTone.green : TreasureButtonTone.red,
            ),
          ],
        ),
      ),
    ),
  );
}
