import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/home/home_bloc.dart';
import 'package:handle_hero/bloc/home/home_state.dart';
import 'package:handle_hero/bloc/level/level_bloc.dart';
import 'package:handle_hero/bloc/level/level_event.dart';
import 'package:handle_hero/ui/home/camera_guess_screen.dart';
import 'package:handle_hero/ui/home/dictionary_tab.dart';
import 'package:handle_hero/ui/modules/module1/Level1Screen/level1screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/level_buttom.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 2;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: _selectedTab == 2
            ? AppBar(
                toolbarHeight: 60,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(MyImages.appBar),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
              )
            : null,
        body: _selectedTab == 2
            ? BlocBuilder<HomeBloc, HomeState>(
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
                              onTap: () =>
                                  _openCamera(context, challengeIndex: 0),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            top: 1150,
                            child: _StatueCameraButton(
                              onTap: () =>
                                  _openCamera(context, challengeIndex: 1),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            top: 1890,
                            child: _StatueCameraButton(
                              onTap: () =>
                                  _openCamera(context, challengeIndex: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : _selectedTab == 1
            ? const CameraGuessScreen(challengeIndex: 0, practiceMode: true)
            : _selectedTab == 3
            ? const DictionaryTab()
            : _HomeTabPlaceholder(
                title: switch (_selectedTab) {
                  0 => 'FRIENDS',
                  3 => 'DICTIONARY',
                  _ => 'MY ACCOUNT',
                },
                icon: switch (_selectedTab) {
                  0 => Icons.people_alt_outlined,
                  3 => Icons.menu_book_outlined,
                  _ => Icons.person_outline,
                },
              ),
        bottomNavigationBar: Container(
          height: 60,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(MyImages.appBar),
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedTab,
            onTap: (index) => setState(() => _selectedTab = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: const Color(0xFFFFE3A3),
            unselectedItemColor: Colors.white,
            selectedFontSize: 9,
            unselectedFontSize: 9,
            iconSize: 21,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: _PixelTabIcon(patternIndex: 0),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _PixelTabIcon(patternIndex: 1),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _PixelTabIcon(patternIndex: 2),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _PixelTabIcon(patternIndex: 3),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: _PixelTabIcon(patternIndex: 4),
                label: '',
              ),
            ],
          ),
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

class _PixelTabIcon extends StatelessWidget {
  const _PixelTabIcon({required this.patternIndex});

  final int patternIndex;

  static const _patterns = [
    // Friends
    [
      '.##.##.',
      '.##.##.',
      '..#.#..',
      '###.###',
      '#.#.#.#',
      '###.###',
      '.#...#.',
    ],
    // Learning: open book
    [
      '#######',
      '#..#..#',
      '#..#..#',
      '#..#..#',
      '#..#..#',
      '#..#..#',
      '#######',
    ],
    // Try Yourself: target
    [
      '..###..',
      '.#...#.',
      '#..#..#',
      '#.###.#',
      '#..#..#',
      '.#...#.',
      '..###..',
    ],
    // Dictionary
    [
      '####.##',
      '#..#.#.#',
      '#..#.#.#',
      '####.#.#',
      '#..#.#.#',
      '#..#.#.#',
      '####.##',
    ],
    // Account
    [
      '..###..',
      '.#...#.',
      '.#...#.',
      '..###..',
      '...#...',
      '.#####.',
      '#.....#',
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(28, 28),
      painter: _PixelTabIconPainter(
        pattern: _patterns[patternIndex],
        color: IconTheme.of(context).color ?? Colors.white,
      ),
    );
  }
}

class _PixelTabIconPainter extends CustomPainter {
  const _PixelTabIconPainter({required this.pattern, required this.color});

  final List<String> pattern;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final pixel = size.width / 8;
    final paint = Paint()..color = color;
    for (var row = 0; row < pattern.length; row++) {
      for (var column = 0; column < pattern[row].length; column++) {
        if (pattern[row][column] == '#') {
          canvas.drawRect(
            Rect.fromLTWH(
              (column + 0.5) * pixel,
              (row + 0.5) * pixel,
              pixel,
              pixel,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelTabIconPainter oldDelegate) =>
      oldDelegate.pattern != pattern || oldDelegate.color != color;
}

class _HomeTabPlaceholder extends StatelessWidget {
  const _HomeTabPlaceholder({required this.title, required this.icon});

  final String title;
  final IconData icon;

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
                title: title,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Icon(icon, size: 64, color: const Color(0xFFFFD55A)),
                ),
              ),
            ),
          ),
        ),
      ],
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
