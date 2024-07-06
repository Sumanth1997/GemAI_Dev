// drawer.dart
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:namer_app/Pages/auth_gate.dart';
import 'package:namer_app/Pages/grid_list.dart';
import 'package:namer_app/Pages/scoreboard.dart';
import 'package:namer_app/Pages/tracker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int currentPoints = 0; // Variable to store points
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchPoints();
    _loadProfileImage(); // Load the profile image when the widget initializes
  }

  Future<void> _fetchPoints() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('scoreboard')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          setState(() {
            currentPoints =
                (snapshot.data() as Map<String, dynamic>)['points'] ?? 0;
          });
        }
      } catch (e) {
        print('Error fetching points: $e');
      }
    }
  }
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await _uploadProfileImage(File(pickedFile.path));
    }
  }

  Future<void> _uploadProfileImage(File image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${user.uid}.jpg'); // Store with user UID
        await storageRef.putFile(image);
        final downloadUrl = await storageRef.getDownloadURL();

        setState(() {
          _profileImageUrl = downloadUrl;
        });

        // Save the image URL to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profileImageUrl', downloadUrl);
      } catch (e) {
        print('Error uploading profile image: $e');
      }
    }
  }
  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImageUrl = prefs.getString('profileImageUrl');
    });
  }



  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email =
        user?.email ?? 'No email'; // Get email or default to 'No email'

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            accountName: Padding(
              padding:
                  const EdgeInsets.only(top: 35.0), // Increased top padding
              child: Text('John Doe'),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(email),
                Text('Points: $currentPoints'),
              ],
            ),
            currentAccountPicture: GestureDetector(
              onTap: _pickImage, // Call _pickImage when the avatar is tapped
              child: CircleAvatar(
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : AssetImage('images/avatar.png')
                        as ImageProvider<Object>, // Use NetworkImage if URL exists
              ),
            ),
          ),
          ListTile(
            title: const Text('Card Collection'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GridList()),
              );
            },
          ),
          ListTile(
            title: const Text('Heat Map'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Tracker()),
              );
            },
          ),
          ListTile(
            title: const Text('Scoreboard'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Scoreboard()),
              );
            },
          ),
          ListTile(
            title: const Text('Logout'),
            leading: Icon(Icons.logout),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthGate()),
              );
            },
          ),
        ],
      ),
    );
  }
}
