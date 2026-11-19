import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:handle_hero/bloc/home/home_bloc.dart';
import 'package:handle_hero/bloc/home/home_event.dart';
import 'package:handle_hero/bloc/level/level_bloc.dart';
import 'package:handle_hero/data/module_catalog.dart';
import 'package:handle_hero/data/sentence_activities.dart';
import 'package:handle_hero/models/models.dart';
import 'package:handle_hero/ui/modules/module1/level_one/level_overview_screen.dart';
import 'package:handle_hero/utils/my_images.dart';
import 'package:handle_hero/widgets/letter_sign.dart';
import 'package:handle_hero/widgets/letter_glyph.dart';
import 'package:handle_hero/widgets/lives_bar.dart';
import 'package:handle_hero/widgets/module_completion_dialog.dart';
import 'package:handle_hero/widgets/out_of_lives_dialog.dart';

enum _ChallengeActivity { nameSign, findSign, matchPair, sentence }

class _ChallengeTask {
  const _ChallengeTask(this.activity, this.letter);

  final _ChallengeActivity activity;
  final LetterOption letter;
}

class MixedChallengeScreen extends StatefulWidget {
  const MixedChallengeScreen({super.key, required this.moduleIndex});

  final int moduleIndex;

  @override
  State<MixedChallengeScreen> createState() => _MixedChallengeScreenState();
}

class _MixedChallengeScreenState extends State<MixedChallengeScreen> {
  static const _tasksPerActivity = 4;
  final _random = math.Random();
  late final List<LetterOption> _letters;
  late final List<_ChallengeTask> _tasks;
  late List<String> _letterChoices;
  late List<LetterOption> _imageChoices;
  List<LetterOption> _sentenceImageChoices = const [];
  late List<String> _pairLetters;
  late List<LetterOption> _pairImages;
  final Set<String> _matchedLetters = {};
  int _taskIndex = 0;
  String? _selectedPairLetter;

  _ChallengeTask get _task => _tasks[_taskIndex];

  @override
  void initState() {
    super.initState();
    final available = [...ModuleCatalog.lettersFor(widget.moduleIndex)]
      ..shuffle(_random);
    _letters = available;
    _tasks = _buildChallengeTasks(_letters);
    _prepareTask();
  }

  List<_ChallengeTask> _buildChallengeTasks(List<LetterOption> letters) {
    final activityTypes = _ChallengeActivity.values;
    final counts = {for (final activity in activityTypes) activity: 0};
    final tasks = <_ChallengeTask>[];

    // Place every module letter at least once before filling remaining slots.
    for (final letter in [...letters]..shuffle(_random)) {
      final eligible = activityTypes
          .where((activity) => counts[activity]! < _tasksPerActivity)
          .toList();
      if (eligible.isEmpty) break;
      final activity = eligible[_random.nextInt(eligible.length)];
      tasks.add(_ChallengeTask(activity, letter));
      counts[activity] = counts[activity]! + 1;
    }

    while (tasks.length < activityTypes.length * _tasksPerActivity) {
      final eligible = activityTypes
          .where((activity) => counts[activity]! < _tasksPerActivity)
          .toList();
      final activity = eligible[_random.nextInt(eligible.length)];
      final letter = letters[_random.nextInt(letters.length)];
      tasks.add(_ChallengeTask(activity, letter));
      counts[activity] = counts[activity]! + 1;
    }

    return _shuffled(tasks);
  }

  void _prepareTask() {
    final target = _task.letter;
    _letterChoices = _shuffled(
      (_task.activity == _ChallengeActivity.nameSign
              ? ModuleCatalog.lettersFor(widget.moduleIndex)
              : _letters)
          .map((item) => item.letter)
          .toList(),
    );
    final imageDistractors = _shuffled(
      ModuleCatalog.lettersFor(widget.moduleIndex)
          .where((item) => item.letter != target.letter)
          .toList(),
    ).take(5);
    _imageChoices = _shuffled([target, ...imageDistractors]);
    final sentenceDistractors = _shuffled(
      ModuleCatalog.lettersFor(widget.moduleIndex)
          .where((item) => item.letter != target.letter)
          .toList(),
    ).take(3);
    _sentenceImageChoices = _shuffled([target, ...sentenceDistractors]);
    final distractors = _shuffled(
      _letters.where((item) => item.letter != target.letter).toList(),
    ).take(2);
    final pairOptions = [target, ...distractors];
    _pairLetters = _shuffled(pairOptions.map((item) => item.letter).toList());
    _pairImages = _shuffled(pairOptions);
    _matchedLetters.clear();
    _selectedPairLetter = null;
  }

  List<T> _shuffled<T>(List<T> items) => items..shuffle(_random);

  void _answerWrong({VoidCallback? onTryAgain}) {
    handleWrongAnswer(
      context: context,
      moduleIndex: widget.moduleIndex,
      onTryAgain: () {
        setState(() {
          _selectedPairLetter = null;
          onTryAgain?.call();
        });
      },
    );
  }

  void _advance() {
    if (_taskIndex == _tasks.length - 1) {
      _finishChallenge();
      return;
    }
    setState(() {
      _taskIndex++;
      _prepareTask();
    });
  }

  void _finishChallenge() {
    final mistakes = context.read<LevelBloc>().state.mistakes;
    final reward = switch (mistakes) {
      0 => 20,
      1 => 10,
      2 => 15,
      _ => 0,
    };
    context.read<HomeBloc>().add(CoinsEarned(reward));
    showModuleCompletionDialog(
      context: context,
      mistakes: mistakes,
      reward: reward,
      onConfirm: () {
        Navigator.pop(context);
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
    );
  }

  void _answerLetter(String letter) {
    if (letter != _task.letter.letter) {
      _answerWrong();
      return;
    }
    _advance();
  }

  void _answerImage(LetterOption option) {
    if (option.letter != _task.letter.letter) {
      _answerWrong();
      return;
    }
    _advance();
  }

  void _selectPairLetter(String letter) {
    if (_matchedLetters.contains(letter)) return;
    setState(() => _selectedPairLetter = letter);
  }

  void _selectPairImage(LetterOption option) {
    final selected = _selectedPairLetter;
    if (selected == null || _matchedLetters.contains(option.letter)) return;
    if (selected != option.letter) {
      _answerWrong(
        onTryAgain: () => _matchedLetters.clear(),
      );
      return;
    }
    final completed = {..._matchedLetters, selected};
    if (completed.length == _pairLetters.length) {
      _advance();
      return;
    }
    setState(() {
      _matchedLetters.add(selected);
      _selectedPairLetter = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final task = _task;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(MyImages.background, fit: BoxFit.cover),
          ),
          LevelHeader(
            onBack: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LevelOverviewScreen(
                  moduleIndex: widget.moduleIndex,
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: 108,
            bottom: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _outlinedText(
                    'CHALLENGE ${widget.moduleIndex ~/ 4 + 1}',
                    fontSize: 22,
                  ),
                  const SizedBox(height: 8),
                  _outlinedText(
                    'TASK ${_taskIndex + 1} OF ${_tasks.length} · ${_activityName(task.activity)}',
                    fontSize: 13,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: (_taskIndex + 1) / _tasks.length,
                      backgroundColor: const Color(0xFF6B3E26),
                      color: const Color(0xFFFFD166),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _activityView(task)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityView(_ChallengeTask task) {
    return switch (task.activity) {
      _ChallengeActivity.nameSign => _nameSignView(task),
      _ChallengeActivity.findSign => _findSignView(task),
      _ChallengeActivity.matchPair => _matchPairView(),
      _ChallengeActivity.sentence => _sentenceView(task),
    };
  }

  Widget _nameSignView(_ChallengeTask task) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _outlinedText('What letter is this?', fontSize: 18),
        const SizedBox(height: 12),
        Expanded(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) => Transform.translate(
                offset: const Offset(0, -30),
                child: LetterSign(
                  option: task.letter,
                  size: math.min(constraints.maxWidth, constraints.maxHeight),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 128,
          child: Transform.translate(
            offset: const Offset(0, -8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final letter in _letterChoices)
                  _letterChoiceButton(
                    letter,
                    compact: true,
                    onTap: () => _answerLetter(letter),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _findSignView(_ChallengeTask task) {
    return Column(
      children: [
        _outlinedText('Find the sign for ${task.letter.letter}', fontSize: 18),
        const SizedBox(height: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final rows = (_imageChoices.length / 2).ceil();
              const spacing = 14.0;
              final imageSize = math.min(
                (constraints.maxWidth - spacing) / 2,
                (constraints.maxHeight - spacing * (rows - 1)) / rows,
              );
              return Wrap(
                alignment: WrapAlignment.center,
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final option in _imageChoices)
                    _imageChoice(option, imageSize),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _matchPairView() {
    return Column(
      children: [
        _outlinedText('Match the pairs', fontSize: 18),
        const SizedBox(height: 12),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final rowHeight = constraints.maxHeight / _pairLetters.length;
              final signSize = math.min(
                180.0,
                math.min(constraints.maxWidth / 2.15, rowHeight * 1.06),
              );
              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PairConnectionPainter(
                        letters: _pairLetters,
                        images: _pairImages.map((option) => option.letter).toList(),
                        connected: _matchedLetters,
                        rowHeight: rowHeight,
                        width: constraints.maxWidth,
                        imageSize: signSize,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            for (final letter in _pairLetters)
                              SizedBox(
                                height: rowHeight,
                                child: Center(
                                  child: _letterChoiceButton(
                                    letter,
                                    imageSize: signSize,
                                    onTap: () => _selectPairLetter(letter),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            for (final option in _pairImages)
                              SizedBox(
                                height: rowHeight,
                                child: Center(
                                  child: _imageChoice(option, signSize),
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
          ),
        ),
        _outlinedText(
          'Matched ${_matchedLetters.length} of ${_pairLetters.length}',
          fontSize: 13,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _sentenceView(_ChallengeTask task) {
    final prompt = SentenceActivities.forLetters([task.letter]).first;
    final sentenceChoices = _sentenceImageChoices.isEmpty
        ? [
            task.letter,
            ...ModuleCatalog.lettersFor(widget.moduleIndex)
                .where((item) => item.letter != task.letter.letter)
                .take(3),
          ]
        : _sentenceImageChoices;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, -20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _outlinedText('Complete the sentence', fontSize: 18),
              const SizedBox(height: 18),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF382630),
                    border: Border.all(
                      color: const Color(0xFF817B6B),
                      width: 4,
                    ),
                  ),
                  child: Text.rich(
                    _sentenceSpan(prompt),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
            ),
          ),
        const SizedBox(height: 24),
        SizedBox(
          height: MediaQuery.sizeOf(context).height * .4,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageSize = math.min(
                (constraints.maxWidth - 12) / 2,
                (constraints.maxHeight - 12) / 2,
              );
              return Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final option in sentenceChoices)
                    _imageChoice(option, imageSize),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  TextSpan _sentenceSpan(SentencePrompt prompt) {
    final parts = prompt.sentence.split('_');
    return TextSpan(
      style: const TextStyle(
        color: Color(0xFFFFE8B2),
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.45,
      ),
      children: [
        TextSpan(text: parts.first),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Container(
              width: 42,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF9A5737),
                border: Border.all(color: const Color(0xFF28202A), width: 4),
              ),
              child: const Text(
                '?',
                style: TextStyle(
                  color: Color(0xFFFFE8B2),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        if (parts.length > 1) TextSpan(text: parts.last),
      ],
    );
  }

  Widget _letterChoiceButton(
    String letter, {
    required VoidCallback onTap,
    bool compact = false,
    double? imageSize,
  }) {
    final size = imageSize ?? (compact ? 60.0 : 76.0);
    return InkWell(
      onTap: onTap,
      child: SizedBox.square(
        dimension: size,
        child: LetterGlyph(letter: letter, size: size),
      ),
    );
  }

  Widget _imageChoice(LetterOption option, double size) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _task.activity == _ChallengeActivity.matchPair
            ? _selectPairImage(option)
            : _answerImage(option),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(child: LetterSign(option: option, size: size)),
        ),
      ),
    );
  }

  Widget _outlinedText(
    String text, {
    required double fontSize,
    Color color = const Color(0xFFFFE8B2),
  }) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 1.2,
      letterSpacing: .4,
    );
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Colors.black,
          ),
        ),
        Text(text, textAlign: TextAlign.center, style: style.copyWith(color: color)),
      ],
    );
  }

  String _activityName(_ChallengeActivity activity) => switch (activity) {
    _ChallengeActivity.nameSign => 'NAME THE LETTER',
    _ChallengeActivity.findSign => 'FIND THE SIGN',
    _ChallengeActivity.matchPair => 'MATCH PAIRS',
    _ChallengeActivity.sentence => 'COMPLETE SENTENCE',
  };
}

class _PairConnectionPainter extends CustomPainter {
  const _PairConnectionPainter({
    required this.letters,
    required this.images,
    required this.connected,
    required this.rowHeight,
    required this.width,
    required this.imageSize,
  });

  final List<String> letters;
  final List<String> images;
  final Set<String> connected;
  final double rowHeight;
  final double width;
  final double imageSize;

  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = const Color(0xFF382630)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.square;
    final line = Paint()
      ..color = const Color(0xFFFFD166)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.square;

    for (final letter in connected) {
      final letterIndex = letters.indexOf(letter);
      final imageIndex = images.indexOf(letter);
      if (letterIndex < 0 || imageIndex < 0) continue;
      final start = Offset(
        width * .25,
        rowHeight * (letterIndex + .5),
      );
      final end = Offset(
        width * .75,
        rowHeight * (imageIndex + .5),
      );
      canvas.drawLine(start, end, outline);
      canvas.drawLine(start, end, line);
    }
  }

  @override
  bool shouldRepaint(covariant _PairConnectionPainter oldDelegate) =>
      oldDelegate.letters != letters ||
      oldDelegate.images != images ||
      oldDelegate.connected != connected ||
      oldDelegate.rowHeight != rowHeight ||
      oldDelegate.imageSize != imageSize;
}
