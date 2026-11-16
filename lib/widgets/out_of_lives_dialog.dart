import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/home/home_bloc.dart';
import 'package:handle_hero/bloc/home/home_event.dart';
import 'package:handle_hero/bloc/home/home_state.dart';
import 'package:handle_hero/bloc/level/level_bloc.dart';
import 'package:handle_hero/bloc/level/level_event.dart';
import 'package:handle_hero/ui/modules/module1/Level1Screen/level1screen.dart';
import 'package:handle_hero/utils/my_images.dart';

Future<void> showOutOfLivesDialog(BuildContext context, {int moduleIndex = 0}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          final levelState = context.read<LevelBloc>().state;
          final canAfford = homeState.coins >= levelState.continueCost;

          return AlertDialog(
            backgroundColor: const Color(0xFF6B3E26),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(MyImages.lose, width: 130),
                const SizedBox(height: 12),
                const Text(
                  'No lives left!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Coins: ${homeState.coins}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              Column(
                children: [
                  TextButton(
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
                    child: const Text(
                      'Restart',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      context.read<LevelBloc>().add(LevelStarted());
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text(
                      'Home',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: canAfford
                        ? () {
                            context.read<HomeBloc>().add(
                              CoinsSpent(levelState.continueCost),
                            );
                            context.read<LevelBloc>().add(LivesRestored());
                            Navigator.pop(dialogContext);
                          }
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          canAfford
                              ? 'Continue'
                              : 'Need ${levelState.continueCost}',
                          style: TextStyle(
                            fontSize: 12,
                            color: canAfford
                                ? Colors.amber
                                : Colors.white38,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Image.asset(MyImages.coin, width: 18),
                        Text(
                          '${levelState.continueCost}',
                          style: TextStyle(
                            fontSize: 12,
                            color: canAfford
                                ? Colors.amber
                                : Colors.white38,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
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
    builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF6B3E26),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(MyImages.lose, width: 150),
          const SizedBox(height: 15),
          const Text(
            'Wrong!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.pop(context);
              onTryAgain();
            },
            child: const Text(
              'Try Again',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}
