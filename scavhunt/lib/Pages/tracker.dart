import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Import for date formatting

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

  @override
  Widget build(BuildContext context) {
    // Get the current month and year
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    // Calculate the start and end dates for the heatmap
    final startDate = DateTime(currentYear, currentMonth - 1, 1);
    final endDate = DateTime(currentYear, currentMonth + 2, 1)
        .subtract(const Duration(days: 1));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker'),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          // width: 400, // Remove the fixed width
          child:  // Remove the RotatedBox
            HeatMap(
              datasets: _heatmapData,
              colorMode: ColorMode.color,
              defaultColor: Colors.grey[200],
              textColor: Colors.black,
              colorsets: {
                1: Colors.lightGreen[100]!,
                5: Colors.lightGreen[300]!,
                10: Colors.lightGreen[500]!,
                15: Colors.lightGreen[700]!,
              },
              startDate: startDate,
              endDate: endDate,
              scrollable: true,
              showColorTip: true,
              // showDayNumbers: true, // This is the incorrect parameter name
              // Use 'showNumber' instead
              // showNumber: true, 
              // Add a gap between months
              // monthLabelStyle: const TextStyle(fontSize: 16),
              // monthLabelPosition: MonthLabelPosition.above,
              // Add a gap between months
              // monthLabelPadding: const EdgeInsets.only(bottom: 10),
            ),
          
        ),
      ),
    );
  }
}
