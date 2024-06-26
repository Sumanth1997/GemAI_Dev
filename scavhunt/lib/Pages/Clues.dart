// import 'package:flip_card/flip_card_controller.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
          restaurants: restaurantList, cluesList: cluesList, currentIndex: 0, onAnswerCorrect: (String restaurantName, String imagePath, String date) {  },),
    );
  }
}

class Clues extends StatefulWidget {
  final int currentIndex;
  final List<String> restaurants; // List of restaurant names
  final List<List<String>> cluesList;
  final Function(String restaurantName, String imagePath, String date)
      onAnswerCorrect;

  Clues(
      {Key? key,
      required this.restaurants,
      required this.cluesList,
      required this.currentIndex,
      required this.onAnswerCorrect})
      : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    print("Sumanth inside Clues");
    return Scaffold(
      appBar: AppBar(
        title: Text('FlipCard'),
        actions: [
          Text('Points: $points'), // Points display on top right
        ],
      ),
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
                                    widget.onAnswerCorrect(
                                      widget.restaurants[currentIndex - 1],
                                      'images/restaurant_${widget.restaurants[currentIndex - 1]}.png', // Replace with actual image path
                                      DateFormat('yyyy-MM-dd').format(DateTime
                                          .now()), // Assuming date is answer reveal date
                                    );
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

  Future<void> _uploadRestaurantData(int currentIndex) async {
    final restaurants = widget.restaurants;
    // final cluesList = widget.cluesList;
    final answer = restaurants[currentIndex - 1];
    final image =
        'images/FortWayne_Downtown.png'; // Replace with actual image path (consider using File)

    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef
        .child('restaurant_images/$answer.png'); // Create a unique filename

    try {
      final imageFile =
          File(image); // Assuming image path points to a local file
      await imageRef.putFile(imageFile);
      final downloadUrl = await imageRef.getDownloadURL();

      final firestore = FirebaseFirestore.instance;
      final collectionRef = firestore.collection('restaurants');

      await collectionRef.add({
        'name': answer,
        'image': downloadUrl,
        'date': DateTime.now(), // Assuming date is answer reveal date
      });
    } on FirebaseException catch (e) {
      // Handle upload errors
      print(e);
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
