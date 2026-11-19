import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/level/level_bloc.dart';
import 'package:handle_hero/bloc/level/level_state.dart';

class LivesBar extends StatelessWidget {
  const LivesBar({super.key, this.heartSize = 36});

  final double heartSize;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LevelBloc, LevelState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < state.maxLives; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: PixelHeart(
                  filled: i < state.lives,
                  size: heartSize,
                ),
              ),
          ],
        );
      },
    );
  }
}

class LevelHeader extends StatelessWidget {
  const LevelHeader({
    super.key,
    required this.onBack,
    this.top = 40,
    this.heartSize = 36,
  });

  final VoidCallback onBack;
  final double top;
  final double heartSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Transform.translate(
                offset: const Offset(-8, 0),
                child: LivesBar(heartSize: heartSize),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: InkWell(
                onTap: onBack,
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(child: PixelBackArrow(size: 32)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PixelBackArrow extends StatelessWidget {
  const PixelBackArrow({super.key, this.size = 28});

  final double size;

  // A clear left arrow: triangular head and long rectangular shaft.
  static const _pixels = [
    [0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 1, 1, 0, 0, 0, 0, 0],
    [0, 1, 1, 1, 0, 0, 0, 0, 0],
    [1, 1, 1, 1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 0, 0, 0, 0, 0],
    [0, 0, 1, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0, 0, 0],
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _PixelBackArrowPainter()),
      );
}

class _PixelBackArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE3D9AA)
      ..isAntiAlias = false;
    final cellW = size.width / 9;
    final cellH = size.height / 7;
    for (var y = 0; y < 7; y++) {
      for (var x = 0; x < 9; x++) {
        if (PixelBackArrow._pixels[y][x] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PixelHeart extends StatelessWidget {
  const PixelHeart({
    super.key,
    required this.filled,
    this.size = 36,
  });

  final bool filled;
  final double size;

  static const _cols = 11;
  static const _rows = 10;

  /// 0 empty, 1 outline, 2 fill, 3 highlight
  static const _pixels = [
    [0, 1, 1, 1, 0, 0, 0, 1, 1, 1, 0],
    [1, 2, 3, 2, 1, 0, 1, 2, 2, 2, 1],
    [1, 3, 2, 2, 2, 1, 2, 2, 2, 2, 1],
    [1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1],
    [1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1],
    [0, 1, 2, 2, 2, 2, 2, 2, 2, 1, 0],
    [0, 0, 1, 2, 2, 2, 2, 2, 1, 0, 0],
    [0, 0, 0, 1, 2, 2, 2, 1, 0, 0, 0],
    [0, 0, 0, 0, 1, 2, 1, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * (_rows / _cols),
      child: CustomPaint(
        painter: _PixelHeartPainter(filled: filled),
      ),
    );
  }
}

class _PixelHeartPainter extends CustomPainter {
  const _PixelHeartPainter({required this.filled});

  final bool filled;

  static const _outline = Color(0xFF532D2C);
  static const _fill = Color(0xFFEB514F);
  static const _highlight = Color(0xFFFFA49A);
  static const _empty = Color(0xFFAA514D);

  @override
  void paint(Canvas canvas, Size size) {
    final pixelW = size.width / PixelHeart._cols;
    final pixelH = size.height / PixelHeart._rows;
    final paint = Paint()..isAntiAlias = false;

    for (var y = 0; y < PixelHeart._rows; y++) {
      for (var x = 0; x < PixelHeart._cols; x++) {
        final cell = PixelHeart._pixels[y][x];
        if (cell == 0) continue;

        if (!filled) {
          if (cell != 1) continue;
          paint.color = _empty;
        } else {
          paint.color = switch (cell) {
            1 => _outline,
            3 => _highlight,
            _ => _fill,
          };
        }

        canvas.drawRect(
          Rect.fromLTWH(x * pixelW, y * pixelH, pixelW, pixelH),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PixelHeartPainter oldDelegate) {
    return oldDelegate.filled != filled;
  }
}
