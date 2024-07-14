// import 'package:flip_card/flip_card_controller.dart';
// import 'dart:io';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:namer_app/Pages/drawer.dart';
import 'package:namer_app/Pages/new_game.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart';

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
        restaurants: restaurantList,
        cluesList: cluesList,
        currentIndex: 0,
        isAnswerSubmittedList: [],
      ),
    );
  }
}

// ignore: must_be_immutable
class Clues extends StatefulWidget {
  final int currentIndex;
  List<String> restaurants; // List of restaurant names
  List<List<String>> cluesList;
  final List<bool> isAnswerSubmittedList;

  Clues({
    Key? key,
    required this.restaurants,
    required this.cluesList,
    required this.currentIndex,
    required this.isAnswerSubmittedList,
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
  Map<int, XFile?> _selectedImages = {};
  // List of clues for each restaurant
  final TextEditingController _answerController = TextEditingController();

  Map<int, String?> displayedClues = {};
  int currentGameIndex = 0;
  // List<bool> isAnswerSubmittedList;
  // _CluesState(List<bool> isAnswerSubmittedList);
  late List<bool> isAnswerSubmittedList;
  Map<int, String?> userAnswers = {};

  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  int points = 0;
  bool isAnswerChecked = false;
  StreamSubscription<DocumentSnapshot>? _scoreboardSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _loadPoints(); // Load points from SharedPreferences
    _listenToScoreboardUpdates();
    isAnswerSubmittedList = widget.isAnswerSubmittedList;
    // _loadGameProgress(); // Start list
    //ening for scoreboard updates
    if (isAnswerSubmittedList.isEmpty) {
      isAnswerSubmittedList = List.filled(10, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Sumanth inside Clues");
    return Scaffold(
      appBar: AppBar(
        title: Text('FlipCard'),
        actions: [
          IconButton(
              onPressed: () {
                _saveGameProgress();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => NewGame()),
                  (route) => false,
                );
              },
              icon: Icon(Icons.home)),
          IconButton(
            onPressed: () {
              _shareGame();
            },
            icon: Icon(Icons.share),
          ),
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
              int currentPoints =
                  (snapshot.data?.data() as Map<String, dynamic>?)?['points'] ??
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
              index: currentGameIndex,
              onIndexChanged: (index) {
                setState(() {
                  currentGameIndex =
                      index; // Update currentGameIndex when the card changes
                });
                _answerController.clear();
                displayedClues[index] = null;
                _saveGameProgress();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveGameProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentGameIndex', currentGameIndex);

    // Save restaurantList
    final restaurantListJson = jsonEncode(widget.restaurants);
    await prefs.setString('restaurantList', restaurantListJson);

    // Save cluesList (This requires a bit more work as it's a List of Lists)
    final cluesListJson = jsonEncode(
        widget.cluesList.map((clueList) => jsonEncode(clueList)).toList());
    await prefs.setString('cluesList', cluesListJson);

    // Save isAnswerSubmittedList
    for (int i = 0; i < isAnswerSubmittedList.length; i++) {
      await prefs.setBool('isAnswered_$i', isAnswerSubmittedList[i]);
    }
  }

  Future<void> _loadGameProgress() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      currentGameIndex = prefs.getInt('currentGameIndex') ?? 0;

      // Load restaurantList
      final restaurantListJson = prefs.getString('restaurantList') ?? '[]';
      final loadedRestaurantList = jsonDecode(restaurantListJson) as List;
      // If you need to convert the loaded list to List<String>, you can do this:
      widget.restaurants =
          loadedRestaurantList.map((item) => item.toString()).toList();

      // Load cluesList
      final cluesListJson = prefs.getString('cluesList') ?? '[]';
      final loadedCluesList = (jsonDecode(cluesListJson) as List)
          .map((clueListJson) => (jsonDecode(clueListJson) as List)
              .map((clue) => clue.toString())
              .toList())
          .toList();
      // If you need to convert to List<List<String>>, you can do this:
      widget.cluesList = loadedCluesList
          .map((clueList) => clueList.map((clue) => clue.toString()).toList())
          .toList();

      // Load isAnswerSubmittedList
      for (int i = 0; i < isAnswerSubmittedList.length; i++) {
        isAnswerSubmittedList[i] = prefs.getBool('isAnswered_$i') ?? false;
      }
    });
  }

  Future<void> _shareGame() async {
    // Generate a unique ID for the game
    final gameId = _uuid.v4();

    // Create the sharedGames collection if it doesn't exist
    // await _firestore.collection('sharedGames').doc().set({});

    // Flatten the cluesList
    final flattenedCluesList =
        widget.cluesList.expand((clueList) => clueList).toList();

    // Create a record in Firestore with the game ID, restaurantList, and cluesList
    await _firestore.collection('sharedGames').doc(gameId).set({
      'restaurantList': widget.restaurants,
      'cluesList': flattenedCluesList,
    });

    await Clipboard.setData(ClipboardData(text: gameId));

    // Display a message or navigate to a screen where the user can share the game ID
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Game ID: $gameId copied to clipboard!'),
        action: SnackBarAction(
          label: 'Share',
          onPressed: () {
            // Implement your sharing logic here (e.g., using share_plus package)
          },
        ),
      ),
    );
  }

  Widget _buildFlipCard(String imagePath, List<String> clues, int currentIndex,
      BuildContext context) {
    final isAnswerSubmitted = widget.isAnswerSubmittedList.isNotEmpty &&
        widget.isAnswerSubmittedList[currentIndex - 1];

    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      side: CardSide.FRONT,
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
                  child: Text(
                    'Clues',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                SizedBox(height: 16),
                if (displayedClues[currentIndex] != null)
                  Container(
                    padding: EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: Text(
                      displayedClues[currentIndex]!,
                      style: TextStyle(fontSize: 18.0, color: Colors.white),
                    ),
                  ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              displayedClues[currentIndex] = clues[i];
                            });
                          },
                          child: Text('Clue ${i + 1}'),
                        ),
                      ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _answerController,
                        enabled: !isAnswerSubmitted,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: isAnswerSubmitted
                              ? 'Already Answered'
                              : 'Enter answer for $currentIndex',
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
                        onPressed: isAnswerSubmitted
                            ? null
                            : () {
                                String userAnswer = _answerController.text;
                                String message = '';
                                if (userAnswer ==
                                    widget.restaurants[currentIndex - 1]) {
                                  setState(() {
                                    points += 100;
                                    message = 'Correct!';
                                    userAnswers[currentIndex] = userAnswer;
                                    isAnswerSubmittedList[currentIndex - 1] =
                                        true;
                                    _savePoints(points);
                                    _uploadRestaurantData(currentIndex);
                                  });
                                  print(
                                      "Correct answer is ${widget.restaurants[currentIndex - 1]}");
                                } else {
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
                                          onPressed: () {
                                            Navigator.pop(context);
                                            // After dialog is closed, update state
                                            setState(() {});
                                          },
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
                    SizedBox(width: 16), // Add a gap between buttons
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isAnswerSubmittedList[currentIndex - 1]
                            ? () {
                                _GetThereMaps(currentIndex -
                                    1,widget.restaurants[currentIndex - 1]); // Call _GetThereMaps when the button is pressed
                              }
                            : null,
                        child: const Text('Get There'),
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
                        image: _selectedImages[currentIndex] != null
                            ? FileImage(
                                File(_selectedImages[currentIndex]!.path))
                            : AssetImage(imagePath) as ImageProvider<Object>,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                if (_selectedImages[currentIndex] != null)
                  Positioned(
                    top: 10.0,
                    left: 10.0,
                    child: IconButton(
                      onPressed: () {
                        // Wrap in a function
                        _pickImage(currentIndex);
                      },
                      icon: Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        if (isAnswerSubmittedList[currentIndex - 1] == true)
                          Text(
                            '${widget.restaurants[currentIndex - 1]}',
                            style: GoogleFonts.dancingScript(
                              textStyle: TextStyle(
                                fontSize: 36,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Text(
                          DateFormat('MMMM d, y').format(DateTime.now()),
                          style: GoogleFonts.dancingScript(
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (_selectedImage == null)
                          ElevatedButton(
                            onPressed: () {
                              // Wrap in a function
                              _pickImage(currentIndex);
                            },
                            child: Text('Upload Image'),
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

  Future<void> _pickImage(int currentIndex) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        // Update the selected image for the specific card
        _selectedImages[currentIndex] = pickedFile;
      });

      // Upload image to Firebase Storage
      final imageUrl = await _uploadImageToFirebase(pickedFile);

      // Update the imagePath in the 'clues' collection for the current index
      if (imageUrl != null) {
        await _updateImagePathInFirestore(imageUrl, currentIndex);
      }
    }
  }

  Future<void> _GetThereMaps(int currentIndex, String restaurant) async {
    // Get the restaurant name and address from your data
    // final restaurantName = widget.restaurants[currentIndex];
    // final restaurantAddress =
        'Address of the restaurant'; // Replace with actual address
    print('Directions to $restaurant');
    // Use the maps_launcher package to open the maps app
    try {
      await MapsLauncher.launchQuery('directions to $restaurant');
    } catch (e) {
      print('Error launching maps: $e');
      // Handle the error (e.g., show an error message to the user)
    }
  }

  Future<String?> _uploadImageToFirebase(XFile imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('clues_images/${_uuid.v4()}.jpg'); // Unique filename
      final uploadTask = await storageRef.putFile(File(imageFile.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _updateImagePathInFirestore(
      String imageUrl, int currentIndex) async {
    final firestore = FirebaseFirestore.instance;
    final cluesCollection = firestore.collection('clues');

    // Get the document ID of the clue based on the current index
    final querySnapshot = await cluesCollection
        .where('answer', isEqualTo: widget.restaurants[currentIndex - 1])
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await cluesCollection.doc(docId).update({'imagePath': imageUrl});
    } else {
      print('Error: Could not find clue document to update.');
    }
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
  void dispose() {
    _scoreboardSubscription
        ?.cancel(); // Cancel the subscription when the widget is disposed
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

  Future<void> _uploadRestaurantData(int currentIndex) async {
    final restaurants = widget.restaurants;
    final answer = restaurants[currentIndex - 1];
    final image =
        'images/FortWayne_Downtown.png'; // Replace with actual image path (consider using File)

    // final storageRef = FirebaseStorage.instance.ref();
    // storageRef
    //     .child('restaurant_images/$answer.png'); // Create a unique filename
    final date = DateFormat('MMMM d, y')
        .format(DateTime.now()); // Format the date as a string
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

      // Get the image URL from the Firestore document
      final querySnapshot =
          await collectionRef.where('answer', isEqualTo: answer).get();

      String imageUrl = image; // Default to the placeholder image

      if (querySnapshot.docs.isNotEmpty) {
        // final docId = querySnapshot.docs.first.id;
        final docData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        imageUrl = docData['imagePath'] ??
            image; // Get the image URL from the document
      }

      await collectionRef.add({
        'answer': answer,
        'imagePath': imageUrl, // Use the image URL from the document
        'date': date, // Store the date as a string
        'user': user?.uid ??
            'Unknown User', // Store user ID or 'Unknown User' if not authenticated
      });

      // Update the heatmap collection
      final date1 = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _updateHeatmapData(user?.email, date1);
      await _updateScoreboard(
          user?.uid, user?.email); // Pass both uid and email
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
    final user = FirebaseAuth.instance.currentUser;
    try {
      // Use userId as the document ID
      final docRef = heatmapCollection
          .doc(user?.uid)
          .collection('dailyCounts')
          .doc(formattedDate);

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
