// main.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SnakeApp());
}

class SnakeApp extends StatelessWidget {
  const SnakeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const WelcomePage(),
    );
  }
}

// --------------------------------------------------
// صفحة ترحيبية
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مرحباً بك')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignUpPage()),
              ),
              child: const Text('إنشاء حساب'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
              child: const Text('تسجيل الدخول'),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// Account model + storage
class Account {
  final String username;
  final String password;
  final int level;

  Account({required this.username, required this.password, this.level = 1});

  Map<String, dynamic> toMap() => {
    'username': username,
    'password': password,
    'level': level,
  };

  factory Account.fromMap(Map<String, dynamic> map) => Account(
    username: map['username'],
    password: map['password'],
    level: map['level'] ?? 1,
  );
}

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

// --------------------------------------------------
// SignUp
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final accounts = await AccountStorage.loadAccounts();
    final username = _userCtrl.text.trim();
    if (accounts.any((a) => a.username == username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اسم المستخدم موجود مسبقًا')),
      );
      setState(() => _loading = false);
      return;
    }
    accounts.add(Account(username: username, password: _passCtrl.text.trim()));
    await AccountStorage.saveAccounts(accounts);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _userCtrl,
                decoration: const InputDecoration(
                  labelText: 'اسم المستخدم',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'أدخل اسم المستخدم' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'أدخل كلمة المرور' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _signUp,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('إنشاء'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// Login
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final accounts = await AccountStorage.loadAccounts();
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    final acc = accounts.firstWhere(
      (a) => a.username == user && a.password == pass,
      orElse: () {
        return Account(username: '', password: '');
      },
    );
    if (acc.username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اسم المستخدم أو كلمة المرور خاطئة')),
      );
      setState(() => _loading = false);
      return;
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LevelsPage(account: acc)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _userCtrl,
                decoration: const InputDecoration(
                  labelText: 'اسم المستخدم',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('دخول'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
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

// --------------------------------------------------
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

// --------------------------------------------------
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

enum Direction { up, down, left, right }
