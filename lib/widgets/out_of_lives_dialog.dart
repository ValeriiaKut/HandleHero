import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/home/home_bloc.dart';
import 'package:handle_hero/bloc/home/home_event.dart';
import 'package:handle_hero/bloc/home/home_state.dart';
import 'package:handle_hero/bloc/level/level_bloc.dart';
import 'package:handle_hero/bloc/level/level_event.dart';
import 'package:handle_hero/ui/modules/module1/Level1Screen/level1screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

Future<void> showOutOfLivesDialog(BuildContext context, {int moduleIndex = 0}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          final levelState = context.read<LevelBloc>().state;
          final canAfford = homeState.coins >= levelState.continueCost;

          return Dialog(
            backgroundColor: Colors.transparent,
            child: TreasureWindow(
              title: 'Treasure Chest',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(MyImages.lose, width: 110),
                  const SizedBox(height: 8),
                  const Text(
                    'NO LIVES LEFT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFFD55A),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'COINS: ${homeState.coins}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFFFFE8B2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TreasureButton(
                    label: 'RESTART',
                    tone: TreasureButtonTone.green,
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      context.read<LevelBloc>().add(LevelStarted());
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) =>
                              Level1screen(moduleIndex: moduleIndex),
                        ),
                        (route) => route.isFirst,
                      );
                    },
                  ),
                  const SizedBox(height: 6),
                  TreasureButton(
                    label: 'HOME',
                    tone: TreasureButtonTone.red,
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      context.read<LevelBloc>().add(LevelStarted());
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                  const SizedBox(height: 6),
                  TreasureButton(
                    label: canAfford
                        ? 'CONTINUE · ${levelState.continueCost} COINS'
                        : 'NEED ${levelState.continueCost} COINS',
                    tone: TreasureButtonTone.wood,
                    onPressed: canAfford
                        ? () {
                            context.read<HomeBloc>().add(
                              CoinsSpent(levelState.continueCost),
                            );
                            context.read<LevelBloc>().add(LivesRestored());
                            Navigator.pop(dialogContext);
                          }
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

void handleWrongAnswer({
  required BuildContext context,
  required VoidCallback onTryAgain,
  int moduleIndex = 0,
}) {
  final levelBloc = context.read<LevelBloc>();
  final livesAfterWrong = levelBloc.state.lives - 1;
  levelBloc.add(LifeLost());

  if (livesAfterWrong <= 0) {
    showOutOfLivesDialog(context, moduleIndex: moduleIndex);
    return;
  }

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: TreasureWindow(
        title: 'Try Again',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(MyImages.lose, width: 110),
            const SizedBox(height: 12),
            TreasureButton(
              label: 'TRY AGAIN',
              tone: TreasureButtonTone.red,
              onPressed: () {
                Navigator.pop(context);
                onTryAgain();
              },
            ),
          ],
        ),
      ),
    ),
  );
}
