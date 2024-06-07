import 'package:flutter/material.dart';
import 'difficulty_level.dart';

class NewGame extends StatelessWidget {
  const NewGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('New Game'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DifficultyLevel()),
            );
          },
        ),
      ),
    );
  }
}
