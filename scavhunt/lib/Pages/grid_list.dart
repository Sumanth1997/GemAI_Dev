import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namer_app/Pages/clue_card.dart';
import 'package:permission_handler/permission_handler.dart'; // Import for storage permissions
import 'package:path_provider/path_provider.dart'; // Import for file storage
import 'package:http/http.dart' as http; // Import for downloading files
import 'dart:io'; // Import for file handling
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
                imagePath: data['imagePath'], // Fetch image path from Firestore
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
  final String imagePath; // Now accepts String (image URL)
  final String date; // Now accepts String

  const ClueGridCard({
    Key? key,
    required this.answer,
    required this.imagePath,
    required this.date,
  }) : super(key: key);

  Future<void> _downloadImage(String imageUrl, String fileName, BuildContext context) async {
    // Request storage permission
    if (await Permission.storage.request().isGranted) {
      try {
        // Get the external storage directory
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          final file = File('${directory.path}/$fileName');
          final response = await http.get(Uri.parse(imageUrl));

          if (response.statusCode == 200) {
            await file.writeAsBytes(response.bodyBytes);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$fileName downloaded successfully!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error downloading image')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('External storage not available')),
          );
        }
      } catch (e) {
        print('Error downloading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading image')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Storage permission denied')),
      );
    }
  }

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
                  imagePath: imagePath, // Pass the image URL
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
            Image.network(
              imagePath, // Use Image.network for network images
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error); // Show an error icon if the image fails to load
              },
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
            // Download icon
            Positioned(
              top: 10.0,
              right: 10.0,
              child: IconButton(
                onPressed: () {
                  final fileName = '${answer.replaceAll(' ', '_')}_$date.jpg';
                  _downloadImage(imagePath, fileName,context);
                },
                icon: Icon(Icons.download, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

