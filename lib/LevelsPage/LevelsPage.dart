import 'package:flutter/material.dart';
import 'package:snakeapp/Account/Account.dart';
import 'package:snakeapp/AccountsListPage/AccountsListPage.dart';
import 'package:snakeapp/SnakeGamePage/SnakeGamePage.dart';


// LevelsPage
class LevelsPage extends StatelessWidget {
  final Account account;
  const LevelsPage({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('مرحباً ${account.username}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(3, (level) {
              final levelNum = level + 1;
              final enabled = levelNum <= account.level;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: enabled
                      ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SnakeGamePage(
                              level: levelNum,
                              account: account,
                            ),
                          ),
                        )
                      : null,
                  child: Text(
                    'المستوى $levelNum',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.list),
              label: const Text('عرض الحسابات'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountsListPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}