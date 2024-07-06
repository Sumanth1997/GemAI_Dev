import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namer_app/Pages/clue_card.dart';
// Import for date formatting

class GridList extends StatefulWidget {
  const GridList({Key? key}) : super(key: key);

  @override
  State<GridList> createState() => _GridListState();
}

class _GridListState extends State<GridList> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clues Grid'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('clues')
            .where('user', isEqualTo: _auth.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final clues = snapshot.data!.docs;

          return GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            children: clues.map((clue) {
              final data = clue.data() as Map<String, dynamic>;
              return ClueGridCard(
                answer: data['answer'],
                imagePath: data['imagePath'],
                date: data['date'], // Pass the date string directly
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class ClueGridCard extends StatelessWidget {
  final String answer;
  final String imagePath;
  final String date; // Now accepts String

  const ClueGridCard({
    Key? key,
    required this.answer,
    required this.imagePath,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show a dialog or navigate to a new screen to display the larger card
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: SizedBox(
                width: 300, // Set desired width
                height: 400, // Set desired height
                child: ClueCard(
                  answer: answer,
                  imagePath: imagePath,
                  date: date,
                ),
              ),
            );
          },
        );
      }, // <-- This closing parenthesis was missing
      child: Card(
        child: Stack(
          children: [
            // Image background
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
            // Text overlay
            Positioned(
              bottom: 10.0,
              left: 10.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    answer,
                    style: const TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                  Text(
                    date, // Display the date string directly
                    style: const TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

