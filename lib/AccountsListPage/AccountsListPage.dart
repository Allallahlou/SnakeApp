import 'package:flutter/material.dart';
import 'package:snakeapp/Account/Account.dart';
import 'package:snakeapp/AccountStorage/AccountStorage.dart';
// AccountsListPage
class AccountsListPage extends StatelessWidget {
  const AccountsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جميع الحسابات')),
      body: FutureBuilder<List<Account>>(
        future: AccountStorage.loadAccounts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final accounts = snapshot.data!;
          if (accounts.isEmpty) {
            return const Center(child: Text('لا توجد حسابات'));
          }
          return ListView.builder(
            itemCount: accounts.length,
            itemBuilder: (_, index) {
              final acc = accounts[index];
              return ListTile(
                title: Text('👤 ${acc.username}'),
                subtitle: Text('🔑 ${acc.password}'),
                trailing: Text('مستوى ${acc.level}'),
              );
            },
          );
        },
      ),
    );
  }
}