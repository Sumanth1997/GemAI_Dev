import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/Pages/Clues.dart';
import 'package:namer_app/Pages/create_hunt.dart';
import 'package:namer_app/Pages/difficulty_level.dart';
import 'package:namer_app/Pages/drawer.dart';
import 'package:namer_app/Pages/profile_setup.dart';
import 'package:namer_app/Pages/public_hunts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your DifficultyLevel widget

class NewGame extends StatefulWidget {
  const NewGame({Key? key}) : super(key: key);

  @override
  State<NewGame> createState() => _NewGameState();
}

class _NewGameState extends State<NewGame> {

  @override
  void initState() {
    super.initState();
    _checkUserAndNavigate(); 
  }

  Future<void> _checkUserAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final isNewUser = await UserManagement().isNewUser(user);
      if (isNewUser) {
        // Navigate to ProfileSetup if it's a new user
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfileSetup(user: user)),
        );
      } 
      // If it's not a new user, you are already on the NewGame screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        centerTitle: true,
      ),
      drawer: AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
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
                            navigateToDifficultyLevel(
                                context, 'Tourist Places');
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
            const SizedBox(height: 20), // Add some spacing between buttons
            // In new_game.dart

            ElevatedButton(
              onPressed: () async {
                await _loadAndNavigateToClues(context);
              },
              child: const Text('Load Game'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateHunt(), // Replace LoadGame with your actual widget
                  ),
                );
              },
              child: const Text('Create Hunt'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PublicHunt(), // Replace LoadGame with your actual widget
                  ),
                );
              },
              child: const Text('Public Hunts'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadAndNavigateToClues(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    final currentGameIndex = prefs.getInt('currentGameIndex') ?? 0;
    final restaurantListJson = prefs.getString('restaurantList') ?? '[]';
    final loadedRestaurantList =
        jsonDecode(restaurantListJson) as List<dynamic>;
    final cluesListJson = prefs.getString('cluesList') ?? '[]';
    final loadedCluesList = (jsonDecode(cluesListJson) as List<dynamic>)
        .map((clueListJson) => (jsonDecode(clueListJson) as List<dynamic>)
            .map((clue) => clue.toString())
            .toList())
        .cast<List<String>>()
        .toList();

    // Load isAnswerSubmittedList
    List<bool> isAnswerSubmittedList = [];
    for (int i = 0; i < loadedRestaurantList.length; i++) {
      isAnswerSubmittedList
          .add(prefs.getBool('isAnswered_$i') ?? false);
    }

    // 2. Navigate to Clues, passing the loaded game data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Clues(
          restaurants: loadedRestaurantList.cast<String>().toList(),
          cluesList: loadedCluesList,
          currentIndex: currentGameIndex,
          isAnswerSubmittedList: isAnswerSubmittedList,
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

class UserManagement {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> isNewUser(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      return !userDoc.exists;
    } catch (e) {
      print('Error checking if user is new: $e');
      return false; // Assume not a new user if error occurs
    }
  }
}
