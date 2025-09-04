import 'package:flutter/material.dart';
import 'package:snakeapp/WelcomePage/WelcomePage.dart';

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

enum Direction { up, down, left, right }
