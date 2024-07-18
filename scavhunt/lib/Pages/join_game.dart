import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namer_app/Pages/Clues.dart'; // Import Clues.dart

class JoinGame extends StatefulWidget {
  const JoinGame({Key? key}) : super(key: key);

  @override
  State<JoinGame> createState() => _JoinGameState();
}

class _JoinGameState extends State<JoinGame> {
  final TextEditingController _gameIdController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _gameIdController,
              decoration: InputDecoration(
                hintText: 'Enter Game ID',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _joinGame();
              },
              child: Text('Join'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _joinGame() async {
  final gameId = _gameIdController.text.trim();

  if (gameId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter a Game ID')),
    );
    return;
  }

  try {
    final gameDoc =
        await _firestore.collection('sharedGames').doc(gameId).get();

    if (gameDoc.exists) {
      final restaurantList = List<String>.from(gameDoc.data()!['restaurantList']);
      final flattenedCluesList = List<String>.from(gameDoc.data()!['cluesList']);
      final difficulty_level = gameDoc.data()!['difficulty_level'];

      // Reconstruct the cluesList from the flattened array
      final List<List<String>> cluesList = [];
      for (int i = 0; i < restaurantList.length; i++) {
        cluesList.add(flattenedCluesList
            .sublist(i * 3, (i + 1) * 3)
            .map((e) => e as String)
            .toList());
      }

      // Navigate to Clues with the loaded data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Clues(
            restaurants: restaurantList,
            cluesList: cluesList, // Now passing a List<List<String>>
            currentIndex: 0,
            isAnswerSubmittedList: [],
            difficulty_level: difficulty_level, // Initialize isAnswerSubmittedList
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid Game ID')),
      );
    }
  } catch (e) {
    print('Error joining game: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error joining game')),
    );
  }
}



}
