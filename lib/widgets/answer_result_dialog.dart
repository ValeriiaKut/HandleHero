import 'package:flutter/material.dart';
import 'package:handle_hero/utils/my_images.dart';

Future<void> showAnswerResultDialog({
  required BuildContext context,
  required bool isCorrect,
  required String confirmLabel,
  required VoidCallback onConfirm,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF6B3E26),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(isCorrect ? MyImages.success : MyImages.lose, width: 150),
          const SizedBox(height: 15),
          Text(
            isCorrect ? 'Correct!' : 'Wrong!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: onConfirm,
            child: Text(
              confirmLabel,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}
