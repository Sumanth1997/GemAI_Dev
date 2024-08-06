import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Tracker extends StatefulWidget {
  const Tracker({Key? key}) : super(key: key);

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  Map<DateTime, int> _heatmapData = {};

  @override
  void initState() {
    super.initState();
    _fetchHeatmapData();
  }

  Future<void> _fetchHeatmapData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userId = user.uid;
      final heatmapCollection = _firestore.collection('heatMap');
      final dailyCounts = heatmapCollection.doc(userId).collection('dailyCounts');

      try {
        final snapshot = await dailyCounts.get();
        _heatmapData = {}; // Clear existing data

        for (final doc in snapshot.docs) {
          final dateString = doc.id; // Date is stored as document ID
          final date = DateTime.parse(dateString);
          final count = doc.data()['count'] as int;
          _heatmapData[date] = count;
        }
        setState(() {});
      } catch (e) {
        print('Error fetching heatmap data: $e');
      }
    }
  }

  List<Widget> _generateMonthHeatmaps() {
    final now = DateTime.now();
    final currentYear = now.year;

    // Generate heatmaps for the past 6 months including the current month
    return List.generate(6, (index) {
      final monthOffset = index;
      final month = now.month - monthOffset;
      final year = currentYear + (month < 1 ? -1 : 0);
      final adjustedMonth = month < 1 ? month + 12 : month;

      final startDate = DateTime(year, adjustedMonth, 1);
      final endDate = DateTime(year, adjustedMonth + 1, 0);

      // Filter data for the current month
      final filteredData = Map.fromEntries(
        _heatmapData.entries.where((entry) =>
            entry.key.isAfter(startDate.subtract(Duration(days: 1))) &&
            entry.key.isBefore(endDate.add(Duration(days: 1))))
        .map((entry) => MapEntry(entry.key, entry.value))
      );

      // Create a grid with the number of cells equal to the days in the month
      final numberOfDays = endDate.day;
      final heatmapGrid = List.generate(numberOfDays, (dayIndex) {
        final date = DateTime(year, adjustedMonth, dayIndex + 1);
        final count = filteredData[date] ?? 0;

        return Container(
          margin: EdgeInsets.all(1.0),
          color: _getColorForCount(count),
          child: Center(
            child: Text(
              '${date.day}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      });

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            Text(
              "${startDate.month}/${startDate.year}",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, // 7 days a week, adjust as needed
                childAspectRatio: 1.0,
                crossAxisSpacing: 2.0,
                mainAxisSpacing: 2.0,
              ),
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: numberOfDays,
              itemBuilder: (context, index) => heatmapGrid[index],
            ),
          ],
        ),
      );
    });
  }

  Color _getColorForCount(int count) {
    if (count >= 15) {
      return Colors.lightGreen[700]!;
    } else if (count >= 10) {
      return Colors.lightGreen[500]!;
    } else if (count >= 5) {
      return Colors.lightGreen[300]!;
    } else if (count >= 1) {
      return Colors.lightGreen[100]!;
    } else {
      return Colors.grey[200]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker'),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: _generateMonthHeatmaps(),
        ),
      ),
    );
  }
}
