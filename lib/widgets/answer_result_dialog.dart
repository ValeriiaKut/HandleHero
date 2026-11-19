import 'package:flutter/material.dart';
import 'dart:math' as math;
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
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.transparent,
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(dialogContext).height * .88,
          ),
          child: SingleChildScrollView(
            child: SizedBox(
              width: math.min(
                MediaQuery.sizeOf(dialogContext).width * .9,
                520.0,
              ),
              child: TreasureWindow(
                title: isCorrect ? 'SIGN REVEALED!' : 'SIGN STILL HIDDEN',
                titleBackgroundColor: isCorrect
                    ? const Color(0xFF637B48)
                    : const Color(0xFF8C5145),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Transform.translate(
                        offset: const Offset(5, 0),
                        child: Image.asset(
                          isCorrect ? MyImages.success : MyImages.lose,
                          width: 220,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TreasureButton(
                      label: confirmLabel,
                      onPressed: onConfirm,
                      labelColor: Colors.black,
                      labelShadow: false,
                      tone: isCorrect
                          ? TreasureButtonTone.green
                          : TreasureButtonTone.red,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

