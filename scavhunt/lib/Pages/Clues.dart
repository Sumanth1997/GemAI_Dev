// import 'package:flip_card/flip_card_controller.dart';
// import 'dart:io';

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:namer_app/Pages/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path_provider/path_provider.dart';

// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';

class CluesCard extends StatelessWidget {
  final List<String> restaurantList;
  final List<List<String>> cluesList;
  

  const CluesCard(
      {Key? key, required this.restaurantList, required this.cluesList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlipCard',
      theme: ThemeData.dark(),
      home: Clues(
          restaurants: restaurantList, cluesList: cluesList, currentIndex: 0),
    );
  }
}

class Clues extends StatefulWidget {
  final int currentIndex;
  final List<String> restaurants; // List of restaurant names
  final List<List<String>> cluesList;

  Clues({
    Key? key,
    required this.restaurants,
    required this.cluesList,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<Clues> createState() => _CluesState();
}

class _CluesState extends State<Clues> {
  final List<String> images = [
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png', // Add more images if you have different ones
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png',
  ];

  // List of clues for each restaurant
  final TextEditingController _answerController = TextEditingController();
  List<bool> isAnswerSubmittedList = List.filled(10, false);

  int points = 0;
  bool isAnswerChecked = false;
  StreamSubscription<DocumentSnapshot>? _scoreboardSubscription; 
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    print("Sumanth inside Clues");
    return Scaffold(
      appBar: AppBar(
        title: Text('FlipCard'),
        actions: [
          // Use StreamBuilder to display points dynamically
          StreamBuilder<DocumentSnapshot>(
            stream: _firestore
                .collection('scoreboard')
                .doc(FirebaseAuth.instance.currentUser?.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('Loading...');
              }

              // Get points from the snapshot
              int currentPoints = (snapshot.data?.data()
                  as Map<String, dynamic>?)?['points'] ??
                  0;

              return Text('Points: $currentPoints');
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: const Color(0xFFFFFFFF)),
          ),
          MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: AppBar(
              elevation: 0.0,
              backgroundColor: Color(0x00FFFFFF),
            ),
          ),
          Center(
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                return _buildFlipCard(
                    images[index], widget.cluesList[index], index + 1, context);
              },
              itemCount: widget.cluesList.length,
              itemWidth: MediaQuery.of(context).size.width * 0.85,
              itemHeight: MediaQuery.of(context).size.height * 0.75,
              layout: SwiperLayout.TINDER,
              viewportFraction: 0.8,
              scale: 0.9,
              onIndexChanged: (index) {
                _answerController.clear();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlipCard(String imagePath, List<String> clues, int currentIndex,
      BuildContext context) {
    // print("Sumanth $clues");
    final _answerController = TextEditingController(text: '');
    
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      // controller: _flipCardController,
      side: CardSide.FRONT, // Ensure the front side is displayed first
      speed: 1000,
      onFlipDone: (status) {
        print(status);
      },
      front: Container(
        decoration: BoxDecoration(
          color: Color(0xFF006666),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Clues',
                          style: TextStyle(fontSize: 24, color: Colors.white)),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  // Changed Row for button placement
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 3; i++) // Loop for 3 buttons
                      Expanded(
                        // Ensures even distribution
                        child: ElevatedButton(
                          onPressed: () => _showClueDialog(context, i, clues),
                          child: Text('Clue ${i + 1}'), // Button Text
                        ),
                      ),
                  ],
                ),
                Row(
                  // Changed Row for button placement
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      // Ensures even distribution
                      child: TextField(
                        controller: _answerController, // Assign the controller
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter answer for $currentIndex ',
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isAnswerSubmittedList[currentIndex - 1]
                            ? null
                            : () {
                                String userAnswer =
                                    _answerController.text; // Get user input
                                String message = '';
                                if (userAnswer ==
                                    widget.restaurants[currentIndex - 1]) {
                                  // Handle correct answer (show success message, etc.)
                                  setState(() {
                                    // Call setState here to update UI within _CluesCardState
                                    points += 100;
                                    message = 'Correct!';
                                    isAnswerSubmittedList[currentIndex - 1] =
                                        true;
                                    // final flipCardController = FlipCardController();
                                    // _flipCardController.toggleCard();
                                    _savePoints(points);
                                    _uploadRestaurantData(currentIndex);
                                  });
                                  print(
                                      "Correct answer is ${widget.restaurants[currentIndex - 1]}");
                                } else {
                                  // Handle incorrect answer (show error message, etc.)
                                  message = 'Incorrect';
                                  print(
                                      "Correct answer is ${widget.restaurants[currentIndex - 1]}");
                                }
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Result'),
                                      content: Text(message),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(
                                              context), // Close dialog
                                          child: Text('Close'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                        child: Text('Check answer'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('Click here to flip back',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Text('$currentIndex/${images.length}',
                  style: TextStyle(fontSize: 12.0, color: Colors.white)),
            ),
          ],
        ),
      ),
      back: Container(
        decoration: BoxDecoration(
          color: Color(0xFF006666),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8.0),
                      ),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (isAnswerSubmittedList[
                            currentIndex - 1]) // Check condition
                          Text(
                            '${widget.restaurants[currentIndex - 1]}', // Display answer
                            style: GoogleFonts.dancingScript(
                              textStyle: TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        // Text('Back',
                        //     style: TextStyle(fontSize: 24, color: Colors.white)),
                        Text(
                          DateFormat('MMMM d, y').format(DateTime.now()),
                          style: GoogleFonts.dancingScript(
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Text('$currentIndex/${images.length}',
                  style: TextStyle(fontSize: 12.0, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _listenToScoreboardUpdates() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _scoreboardSubscription = _firestore
          .collection('scoreboard')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          setState(() {
            points = (snapshot.data() as Map<String, dynamic>)['points'] ?? 0;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPoints(); // Load points from SharedPreferences
    _listenToScoreboardUpdates(); // Start listening for scoreboard updates
  }

  @override
  void dispose() {
    _scoreboardSubscription?.cancel(); // Cancel the subscription when the widget is disposed
    super.dispose();
  }

  Future<void> _savePoints(int points) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('points', points);
  }

  Future<int> _loadPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('points') ?? 0; // Default to 0 if no points saved
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPoints().then((loadedPoints) {
      setState(() {
        points = loadedPoints;
      });
    });
  }

  // ... (Existing code in Clues.dart)

    Future<void> _uploadRestaurantData(int currentIndex) async {
    final restaurants = widget.restaurants;
    final answer = restaurants[currentIndex - 1];
    final image =
        'images/FortWayne_Downtown.png'; // Replace with actual image path (consider using File)

    // final storageRef = FirebaseStorage.instance.ref();
    // storageRef
    //     .child('restaurant_images/$answer.png'); // Create a unique filename
    final date = DateFormat('MMMM d, y').format(DateTime.now()); // Format the date as a string
    print("Sumanth in upload restaurant data in clues");
    try {
      // final imageFile = File(image); // Assuming image path points to a local file
      // await imageRef.putFile(imageFile);
      // final downloadUrl = await imageRef.getDownloadURL();

      final firestore = FirebaseFirestore.instance;
      final collectionRef =
          firestore.collection('clues'); // Use 'clues' collection

      // Get the current user (you'll need to implement user authentication)
      final user = FirebaseAuth
          .instance.currentUser; // Replace with your authentication logic

      await collectionRef.add({
        'answer': answer,
        'imagePath': image,
        'date': date, // Store the date as a string
        'user': user?.email ??
            'Unknown User', // Store user ID or 'Unknown User' if not authenticated
      });

      // Update the heatmap collection
      final date1 = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _updateHeatmapData(user?.email, date1);
      await _updateScoreboard(user?.uid, user?.email); // Pass both uid and email
    } on FirebaseException catch (e) {
      // Handle upload errors
      print("Sumanth in upload restaurant data error is $e");
    }
  }

  Future<void> _updateHeatmapData(String? userId, String dateString) async {
    final firestore = FirebaseFirestore.instance;
    final heatmapCollection = firestore.collection('heatMap');
    final date = DateTime.parse(dateString); 
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final user = FirebaseAuth
          .instance.currentUser;
    try {
      // Use userId as the document ID
      final docRef = heatmapCollection.doc(user?.uid).collection('dailyCounts').doc(formattedDate);

      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Document exists, increment the count
        await docRef.update({
          'count': FieldValue.increment(1),
        });
      } else {
        // Document doesn't exist, create a new document
        await docRef.set({
          'count': 1,
        });
      }
    } catch (e) {
      print('Error updating heatmap data: $e');
    }
  }

  Future<void> _updateScoreboard(String? userId, String? userEmail) async {
    final firestore = FirebaseFirestore.instance;
    final scoreboardCollection = firestore.collection('scoreboard');

    try {
      // Check if a document for the user exists
      final docRef = scoreboardCollection.doc(userId); // Use userId as doc ID
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Document exists, increment the points
        await docRef.update({
          'points': FieldValue.increment(100), // Increment by 100 points
          'useremail': userEmail, // Update the useremail field
        });
      } else {
        // Document doesn't exist, create a new document
        await docRef.set({
          'points': points, // Initial points
          'useremail': userEmail, // Set the useremail field
        });
      }
    } catch (e) {
      print('Error updating scoreboard data: $e');
    }
  }

}

void _showClueDialog(BuildContext context, int index, List<String> cluesList) {
  // final cluesList = Provider.of<List<String>>(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Your AlertDialog or Card display logic using clues[index]
      return AlertDialog(
        title: Text('Clue ${index + 1}'), // Use index + 1 for correct numbering
        content: Text(cluesList[index]), // Access clue based on index
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}

class PromptCard extends StatelessWidget {
  final String message;

  const PromptCard({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.only(top: 10.0), // Adjust margins as needed
      decoration: BoxDecoration(
        color: message == 'Correct!'
            ? Colors.green
            : Colors.red, // Set color based on message
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.white,
        ),
      ),
    );
  }
}
