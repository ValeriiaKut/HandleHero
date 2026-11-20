import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:handle_hero/ui/home/friends_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/home/home_bloc.dart';
import 'package:handle_hero/bloc/home/home_state.dart';
import 'package:handle_hero/bloc/level/level_bloc.dart';
import 'package:handle_hero/bloc/level/level_event.dart';
import 'package:handle_hero/ui/home/camera_guess_screen.dart';
import 'package:handle_hero/ui/home/account_profile_page.dart';
import 'package:handle_hero/ui/home/dictionary_tab.dart';
import 'package:handle_hero/ui/modules/module1/level_one/level_overview_screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/level_button.dart';
import 'package:handle_hero/widgets/treasure_ui.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.userEmail,
    required this.userName,
    required this.userId,
    required this.onLogout,
  });

  final String userEmail;
  final String userName;
  final String userId;
  final VoidCallback onLogout;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedTab = 2;
  bool _checkingCoinGifts = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPendingCoinGifts();
    });
  }

  Future<void> _showPendingCoinGifts() async {
    if (_checkingCoinGifts) return;
    _checkingCoinGifts = true;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('coin_gifts')
          .where('recipientId', isEqualTo: widget.userId)
          .get();
      final gifts = snapshot.docs
          .where((gift) => gift.data()['seen'] != true)
          .toList();
      for (final gift in gifts) {
        if (!mounted) return;
        await gift.reference.update({'seen': true});
        if (!mounted) return;
        final data = gift.data();
        final senderName = (data['senderName'] as String?)?.trim();
        final amount = (data['amount'] as num?)?.toInt() ?? 10;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => Dialog(
            backgroundColor: Colors.transparent,
            child: TreasureWindow(
              title: 'COIN GIFT!',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(MyImages.success, width: 180),
                  const SizedBox(height: 12),
                  Text(
                    '${senderName?.isNotEmpty == true ? senderName : 'A friend'} sent you',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFE3D9AA),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '+$amount COINS!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFD1C27E),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TreasureButton(
                    label: 'COLLECT',
                    labelColor: Colors.black,
                    labelShadow: false,
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } on FirebaseException catch (error) {
      debugPrint('Could not check coin gifts: ${error.code}');
    } finally {
      _checkingCoinGifts = false;
    }
  }

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
                  children: [
                    Expanded(
                      child: Text(
                        'Hi, ${widget.userName.isEmpty ? 'Adventurer' : widget.userName}!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                                    settings: RouteSettings(
                                      name: '/level-overview/$levelIndex',
                                    ),
                                    builder: (_) =>
                                        LevelOverviewScreen(moduleIndex: levelIndex),
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
                          Positioned(
                            left: 260,
                            top: 225,
                            child: IgnorePointer(
                              child: Image.asset(MyImages.chest, width: 100),
                            ),
                          ),
                          Positioned(
                            left: 260,
                            top: 960,
                            child: IgnorePointer(
                              child: Image.asset(MyImages.chest, width: 100),
                            ),
                          ),
                          Positioned(
                            left: 260,
                            top: 1690,
                            child: IgnorePointer(
                              child: Image.asset(MyImages.chest, width: 100),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : _selectedTab == 0
            ? FriendsPage(userId: widget.userId, userName: widget.userName)
            : _selectedTab == 1
            ? const CameraGuessScreen(challengeIndex: 0, practiceMode: true)
            : _selectedTab == 3
            ? const DictionaryTab()
            : _selectedTab == 4
            ? AccountProfilePage(
                email: widget.userEmail,
                name: widget.userName,
                userId: widget.userId,
                onLogout: widget.onLogout,
              )
            : _HomeTabPlaceholder(
                title: switch (_selectedTab) {
                  0 => 'FRIENDS',
                  3 => 'SANCTUARY OF SIGNS',
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
            selectedItemColor: const Color(0xFFE3D9AA),
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
                  child: Icon(icon, size: 64, color: const Color(0xFFD1C27E)),
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
