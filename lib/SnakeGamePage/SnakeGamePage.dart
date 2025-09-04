import 'dart:async';
import 'package:flutter/material.dart';
import 'package:snakeapp/Account/Account.dart';
import 'package:snakeapp/AccountStorage/AccountStorage.dart';
import 'package:snakeapp/main.dart';

// SnakeGamePage
class SnakeGamePage extends StatefulWidget {
  final int level;
  final Account account;
  const SnakeGamePage({super.key, required this.level, required this.account});
  @override
  State<SnakeGamePage> createState() => _SnakeGamePageState();
}

class _SnakeGamePageState extends State<SnakeGamePage> {
  late int level = widget.level;
  late Account account = widget.account;

  int get rowCount => 20 - (level - 1) * 2;
  int get colCount => 20 - (level - 1) * 2;
  int get totalCells => rowCount * colCount;

  Duration get speed {
    switch (level) {
      case 1:
        return const Duration(milliseconds: 300);
      case 2:
        return const Duration(milliseconds: 220);
      case 3:
        return const Duration(milliseconds: 150);
      default:
        return const Duration(milliseconds: 300);
    }
  }

  Direction direction = Direction.right;
  List<int> snake = [45, 44, 43];
  int food = 100;
  Timer? _timer;

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
    _timer = Timer.periodic(speed, (_) => moveSnake());
  }

  void generateFood() {
    food = (List.generate(
      totalCells,
      (i) => i,
    )..shuffle()).firstWhere((i) => !snake.contains(i));
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

  void showGameOverDialog() async {
    final score = snake.length - 3;
    if (level == account.level && score >= 20) {
      // ✅ غيّر هنا إلى 20 أو أقل للتجربة
      final newLevel = account.level + 1;
      if (newLevel <= 3) {
        final accounts = await AccountStorage.loadAccounts();
        final index = accounts.indexWhere(
          (a) => a.username == account.username,
        );
        if (index != -1) {
          accounts[index] = Account(
            username: account.username,
            password: account.password,
            level: newLevel,
          );
          await AccountStorage.saveAccounts(accounts);
          account = accounts[index];
        }
      }
    }
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('انتهت اللعبة'),
        content: Text('النتيجة: $score'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('العودة'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              startGame();
            },
            child: const Text('إعادة'),
          ),
        ],
      ),
    );
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
        title: Text('مستوى $level'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt_rounded),
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: colCount,
                crossAxisSpacing: 1,
                mainAxisSpacing: 1,
              ),
              itemCount: totalCells,
              itemBuilder: (_, index) {
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