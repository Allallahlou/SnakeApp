import 'package:flutter/material.dart';
import 'package:snakeapp/Account/Account.dart';
import 'package:snakeapp/AccountStorage/AccountStorage.dart';

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
      appBar: AppBar(title: const Text('Create an account ')),
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
                  labelText: 'username',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? ' Enter your username '
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Enter your password'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _signUp,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('connection'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
