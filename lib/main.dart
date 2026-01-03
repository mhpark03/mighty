import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/game_controller.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const MightyApp());
}

class MightyApp extends StatelessWidget {
  const MightyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GameController(),
      child: MaterialApp(
        title: '마이티',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const GameScreen(),
      ),
    );
  }
}
