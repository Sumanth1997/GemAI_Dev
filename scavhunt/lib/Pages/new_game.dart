import 'package:flutter/material.dart';
import 'package:namer_app/Pages/difficulty_level.dart'; // Import your DifficultyLevel widget

class NewGame extends StatefulWidget {
  const NewGame({Key? key}) : super(key: key);

  @override
  State<NewGame> createState() => _NewGameState();
}

class _NewGameState extends State<NewGame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Show a dialog or navigate to select between 'restaurants' and 'Tourist Places'
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Select Category'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        navigateToDifficultyLevel(context, 'restaurants');
                      },
                      child: const Text('Restaurants'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        navigateToDifficultyLevel(context, 'Tourist Places');
                      },
                      child: const Text('Tourist Places'),
                    ),
                  ],
                ),
              ),
            );
          },
          child: const Text('Start New Game'),
        ),
      ),
    );
  }

  void navigateToDifficultyLevel(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DifficultyLevel(category: category),
      ),
    );
  }
}
