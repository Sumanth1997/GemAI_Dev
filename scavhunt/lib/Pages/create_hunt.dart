import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class CreateHunt extends StatefulWidget {
  const CreateHunt({Key? key}) : super(key: key);

  @override
  State<CreateHunt> createState() => _CreateHuntState();
}

class _CreateHuntState extends State<CreateHunt> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  int _numHunts = 1; // Default to 1 hunt
  List<List<TextEditingController>> _clueTextControllers = [];
  List<TextEditingController> _answerControllers = [];
  List<File?> _huntImages = [];
  List<TextEditingController> _pointsControllers = []; // Points controllers

  String? _postalCode; // Store the postal code

  @override
  void initState() {
    super.initState();
    _initializeHuntData();
    _getUserLocation(); // Get postal code on initialization
  }

  void _initializeHuntData() {
    _clueTextControllers = List.generate(_numHunts, (index) => [
          TextEditingController(),
          TextEditingController(),
          TextEditingController(),
        ]);
    _answerControllers = List.generate(_numHunts, (index) => TextEditingController());
    _huntImages = List.generate(_numHunts, (index) => null);
    _pointsControllers = List.generate(_numHunts, (index) => TextEditingController());
  }

  // Image Upload Function
  Future<void> _getImage(int huntIndex) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _huntImages[huntIndex] = File(pickedFile.path);
      });
    }
  }

  // Get User Location (Postal Code)
  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are disabled.
        return;
      }

      // Check for location permissions
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, so we can't request location data.
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are permanently denied, so we can't request location data.
        return;
      }

      // When we reach here, permissions are granted and we can get the location.
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Reverse geocode the coordinates
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _postalCode = place.postalCode;
        });
      } else {
        // Handle case where location cannot be determined
        print('Unable to determine the location.');
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  // Create Hunt Function
  Future<void> _createHunt() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      for (int huntIndex = 0; huntIndex < _numHunts; huntIndex++) {
        // Upload Image to Firebase Storage
        String? imageUrl;
        if (_huntImages[huntIndex] != null) {
          final ref = _storage
              .ref()
              .child('hunt_images')
              .child(_huntImages[huntIndex]!.path);
          final uploadTask = ref.putFile(_huntImages[huntIndex]!);
          await uploadTask.whenComplete(() async {
            imageUrl = await ref.getDownloadURL();
          });
        }

        // Calculate total points
        int points = int.tryParse(_pointsControllers[huntIndex].text) ?? 0;
        int totalPoints = points + (int.tryParse(_postalCode ?? '0') ?? 0);

        // Add Hunt Data to Firestore
        await _firestore.collection('hunts').add({
          'title': 'Hunt ${huntIndex + 1}', // Title is now fixed
          'clue1Text': _clueTextControllers[huntIndex][0].text,
          'clue2Text': _clueTextControllers[huntIndex][1].text,
          'clue3Text': _clueTextControllers[huntIndex][2].text,
          'answer': _answerControllers[huntIndex].text,
          'image': imageUrl, // Store the image URL
          'points': totalPoints, // Store total points
        });
      }

      // Navigate back to previous screen
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Number of Hunts Control
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_numHunts > 1) {
                              _numHunts--;
                              _initializeHuntData();
                            }
                          });
                        },
                        icon: const Icon(Icons.remove),
                      ),
                      Text('$_numHunts'),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _numHunts++;
                            _initializeHuntData();
                          });
                        },
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),

                // Hunt Forms
                for (int huntIndex = 0; huntIndex < _numHunts; huntIndex++)
                  _buildHuntForm(huntIndex),

                const SizedBox(height: 32.0),

                // Create Hunt Button
                ElevatedButton(
                  onPressed: _createHunt,
                  child: const Text('Create Hunts'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Function to Build Hunt Form
  Widget _buildHuntForm(int huntIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hunt Title (Centered)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Text(
              'Hunt ${huntIndex + 1}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Clue 1
        _buildClueSection(huntIndex, 1),
        const SizedBox(height: 8.0),

        // Clue 2
        _buildClueSection(huntIndex, 2),
        const SizedBox(height: 8.0),

        // Clue 3
        _buildClueSection(huntIndex, 3),
        const SizedBox(height: 8.0),

        // Answer
        _buildAnswerSection(huntIndex),
        const SizedBox(height: 8.0),

        // Points
        _buildPointsSection(huntIndex),
        const SizedBox(height: 8.0),

        // Image Upload
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _getImage(huntIndex),
              child: Text('Choose Image for Hunt ${huntIndex + 1}'),
            ),
            const SizedBox(width: 16.0),
            if (_huntImages[huntIndex] != null)
              Image.file(
                _huntImages[huntIndex]!,
                height: 100,
                width: 100,
              ),
          ],
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }

  // Helper Function to Build Clue Section
  Widget _buildClueSection(int huntIndex, int clueIndex) {
    return Padding(
      padding: const EdgeInsets.all(8.0), // Add padding
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey), // Add border
          borderRadius: BorderRadius.circular(8.0), // Add rounded corners
        ),
        padding: const EdgeInsets.all(16.0), // Add padding inside the box
        child: SizedBox(
          width: double.infinity, // Allow width to expand
          child: TextFormField(
            controller: _clueTextControllers[huntIndex][clueIndex - 1],
            decoration: InputDecoration(
              labelText: 'Clue $clueIndex Text',
              border: InputBorder.none, // Remove default border
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter clue $clueIndex text';
              }
              if (value.length > 1000) {
                return 'Clue cannot exceed 1000 characters';
              }
              return null;
            },
            maxLines: null, // Allow multiple lines
            maxLength: 1000,
          ),
        ),
      ),
    );
  }

  // Helper Function to Build Answer Section
  Widget _buildAnswerSection(int huntIndex) {
    return Padding(
      padding: const EdgeInsets.all(8.0), // Add padding
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey), // Add border
          borderRadius: BorderRadius.circular(8.0), // Add rounded corners
        ),
        padding: const EdgeInsets.all(16.0), // Add padding inside the box
        child: SizedBox(
          width: double.infinity, // Allow width to expand
          child: TextFormField(
            controller: _answerControllers[huntIndex],
            decoration: InputDecoration(
              labelText: 'Answer',
              border: InputBorder.none, // Remove default border
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the answer';
              }
              if (value.length > 30) {
                return 'Answer cannot exceed 30 characters';
              }
              return null;
            },
            maxLines: 1, // Allow only one line
            maxLength: 30,
          ),
        ),
      ),
    );
  }

  // Helper Function to Build Points Section
  Widget _buildPointsSection(int huntIndex) {
    return Padding(
      padding: const EdgeInsets.all(8.0), // Add padding
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey), // Add border
          borderRadius: BorderRadius.circular(8.0), // Add rounded corners
        ),
        padding: const EdgeInsets.all(16.0), // Add padding inside the box
        child: SizedBox(
          width: double.infinity, // Allow width to expand
          child: TextFormField(
            controller: _pointsControllers[huntIndex],
            decoration: InputDecoration(
              labelText: 'Points',
              border: InputBorder.none, // Remove default border
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter points';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              if (int.parse(value) > 1000) {
                return 'Maximum points allowed is 1000';
              }
              return null;
            },
            maxLines: 1, // Allow only one line
            maxLength: 4, // Allow maximum 4 digits for points
          ),
        ),
      ),
    );
  }
}
