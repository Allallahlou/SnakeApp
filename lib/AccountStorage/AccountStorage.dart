import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:snakeapp/Account/Account.dart';

class AccountStorage {
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/accounts.json');
  }

  static Future<List<Account>> loadAccounts() async {
    try {
      final file = await _getFile();
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final List<dynamic> decoded = jsonDecode(content);
      return decoded.map((e) => Account.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAccounts(List<Account> accounts) async {
    final file = await _getFile();
    final encoded = jsonEncode(accounts.map((e) => e.toMap()).toList());
    await file.writeAsString(encoded);
  }
}
