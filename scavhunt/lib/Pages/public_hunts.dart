import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:namer_app/Pages/Clues.dart';
// import 'package:scavhunt/Pages/Clues.dart'; // Import Clues.dart

class PublicHunt extends StatefulWidget {
  const PublicHunt({Key? key}) : super(key: key);

  @override
  State<PublicHunt> createState() => _PublicHuntState();
}

class _PublicHuntState extends State<PublicHunt> {
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _huntData = [];

  @override
  void initState() {
    super.initState();
    _fetchHuntData();
  }

  Future<void> _fetchHuntData() async {
    try {
      final snapshot = await _firestore.collection('hunts').get();
      _huntData = snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      setState(() {});
    } catch (e) {
      print('Error fetching hunt data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Hunts'),
      ),
      body: _huntData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _huntData.length,
              itemBuilder: (context, index) {
                final hunt = _huntData[index];

                // Convert answer and clues to lists of strings
                final answerList = [hunt['answer'].toString()]; 
                final cluesList = [
                  hunt['clue1Text'].toString(),
                  hunt['clue2Text'].toString(),
                  hunt['clue3Text'].toString(),
                ];

                print("Sumanth printing cluesList $cluesList");
                return GestureDetector(
                  onTap: () {
                    // Navigate to Clues.dart and pass the hunt data
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CluesCard(
                          restaurantList: answerList, // Pass the answer list
                          cluesList: [cluesList], // Wrap cluesList in a list
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: Center(
                      child: Text(
                        'Points: ${hunt['points']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
