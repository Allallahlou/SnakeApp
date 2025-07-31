import 'package:flutter/material.dart';
import 'dart:async';

class SnakePage extends StatefulWidget {
  const SnakePage({super.key});
  @override
  State<SnakePage> createState() => _SnakePageState();
}

class _SnakePageState extends State<SnakePage> {
  static const int rowCount = 20;
  static const int colCount = 20;
  static const int totalCells = rowCount * colCount;

  Direction direction = Direction.right;
  List<int> snake = [45, 44, 43];
  int food = 100;
  Timer? _timer;
  Duration speed = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    snake = [45, 44, 43];
    direction = Direction.right;
    generateFood();
    _timer?.cancel();
    _timer = Timer.periodic(speed, (timer) => moveSnake());
  }

  void generateFood() {
    food = (List.generate(totalCells, (i) => i)..shuffle())
        .firstWhere((i) => !snake.contains(i));
  }

  void moveSnake() {
    setState(() {
      final head = snake.first;
      int newHead;
      switch (direction) {
        case Direction.up:
          newHead = head - colCount;
          break;
        case Direction.down:
          newHead = head + colCount;
          break;
        case Direction.left:
          newHead = head - 1;
          break;
        case Direction.right:
          newHead = head + 1;
          break;
      }

      if (newHead < 0 ||
          newHead >= totalCells ||
          (direction == Direction.left && head % colCount == 0) ||
          (direction == Direction.right && (head + 1) % colCount == 0) ||
          snake.contains(newHead)) {
        _timer?.cancel();
        showGameOverDialog();
        return;
      }

      snake.insert(0, newHead);
      if (newHead == food) {
        generateFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void showGameOverDialog() {
    Future.microtask(() {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text('انتهت اللعبة'),
          content: Text('النتيجة: ${snake.length - 3}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                startGame();
              },
              child: const Text('إعادة اللعب'),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake Game'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
            tooltip: 'إعادة اللعب',
            onPressed: startGame,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: colCount,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemCount: totalCells,
              itemBuilder: (context, index) {
                if (snake.contains(index)) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }
                if (index == food) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.arrow_left),
                  onPressed: () => direction = Direction.left,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.arrow_drop_up),
                      onPressed: () => direction = Direction.up,
                    ),
                    const SizedBox(height: 12),
                    IconButton(
                      iconSize: 48,
                      icon: const Icon(Icons.arrow_drop_down),
                      onPressed: () => direction = Direction.down,
                    ),
                  ],
                ),
                IconButton(
                  iconSize: 48,
                  icon: const Icon(Icons.arrow_right),
                  onPressed: () => direction = Direction.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum Direction { up, down, left, right }