import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/home/home_bloc.dart';
import 'package:handle_hero/bloc/home/home_state.dart';
import 'package:handle_hero/bloc/level/level_bloc.dart';
import 'package:handle_hero/bloc/level/level_event.dart';
import 'package:handle_hero/ui/home/camera_guess_screen.dart';
import 'package:handle_hero/ui/modules/module1/Level1Screen/level1screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/level_buttom.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(MyImages.appBar),
                fit: BoxFit.fill,
              ),
            ),
          ),
          title: Row(
            children: [
              InkWell(
                onTap: () => print('Settings'),
                child: const Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: 35,
                ),
              ),
              const Spacer(),
              BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(MyImages.coin, width: 22),
                      const SizedBox(width: 6),
                      Text(
                        '${state.coins}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                height: 2250,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(MyImages.grass),
                            repeat: ImageRepeat.repeatY,
                          ),
                        ),
                      ),
                    ),
                    for (
                      var levelIndex = 0;
                      levelIndex < state.levels.length;
                      levelIndex++
                    )
                      LevelButton(
                        left: state.levels[levelIndex].left,
                        top: state.levels[levelIndex].top,
                        backgroundImage: state.levels[levelIndex].bg,
                        numberImage: state.levels[levelIndex].number,
                        onTap: () {
                          context.read<LevelBloc>().add(LevelStarted());
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  Level1screen(moduleIndex: levelIndex),
                            ),
                          );
                        },
                      ),
                    Positioned(
                      left: 10,
                      top: 420,
                      child: _StatueCameraButton(
                        onTap: () => _openCamera(context, challengeIndex: 0),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 1150,
                      child: _StatueCameraButton(
                        onTap: () => _openCamera(context, challengeIndex: 1),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 1890,
                      child: _StatueCameraButton(
                        onTap: () => _openCamera(context, challengeIndex: 2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openCamera(BuildContext context, {required int challengeIndex}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CameraGuessScreen(challengeIndex: challengeIndex),
      ),
    );
  }
}

class _StatueCameraButton extends StatelessWidget {
  const _StatueCameraButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Image.asset(MyImages.statue, width: 400),
    );
  }
}
