import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Scoreboard extends StatefulWidget {
  const Scoreboard({Key? key}) : super(key: key);

  @override
  State<Scoreboard> createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard> {
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _scoreboardData = [];

  @override
  void initState() {
    super.initState();
    _fetchScoreboardData();
  }

  Future<void> _fetchScoreboardData() async {
    try {
      // Fetch data from Firestore (replace with your actual data source)
      final snapshot = await _firestore.collection('scoreboard').get();

      _scoreboardData = snapshot.docs.map((doc) {
        return {
          'uid': doc.data()['useremail'], // Assuming user ID is the document ID
          'points': doc.data()['points'] ?? 0, // Get points from the document
        };
      }).toList();

      setState(() {});
    } catch (e) {
      print('Error fetching scoreboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
      ),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView for scrolling
        child: DataTable(
          columns: const [
            DataColumn(label: Text('SL.No.')),
            DataColumn(label: Text('UID')),
            DataColumn(label: Text('Points')),
          ],
          rows: _scoreboardData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return DataRow(
              cells: [
                DataCell(Text((index + 1).toString())), // SL.No.
                DataCell(Text(data['uid'])), // UID
                DataCell(Text(data['points'].toString())), // Points
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
