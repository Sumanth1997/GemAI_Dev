// drawer.dart
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:namer_app/Pages/add_friends.dart';
import 'package:namer_app/Pages/auth_gate.dart';
import 'package:namer_app/Pages/grid_list.dart';
import 'package:namer_app/Pages/main.dart';
import 'package:namer_app/Pages/scoreboard.dart';
import 'package:namer_app/Pages/theme.dart';
import 'package:namer_app/Pages/tracker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  int currentPoints = 0; // Variable to store points
  String? _profileImageUrl;
  String _selectedLanguage = 'English'; // Default language
  final List<String> _languages = [
    'English',
    'Kannada',
    'Spanish',
    'Chinese',
    'French',
    'German',
    'Russian',
    'Japanese',
  ];
  bool _showLanguageDropdown = false; // Flag to control dropdown visibility
  bool _isDarkMode = false; // Flag to control dark mode

  @override
  void initState() {
    super.initState();
    _fetchPoints();
    _loadProfileImage(); // Load the profile image when the widget initializes
    _loadSelectedLanguage(); // Load the selected language from SharedPreferences
    _loadDarkMode(); // Load dark mode preference
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

  // Load the selected language from SharedPreferences
  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';
    });
  }

  // Save the selected language to SharedPreferences
  Future<void> _saveSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', _selectedLanguage);
  }

  // Load dark mode preference from SharedPreferences
  Future<void> _loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  // Save dark mode preference to SharedPreferences
  Future<void> _saveDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  // Toggle dark mode
  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _saveDarkMode();
      // Update the theme provider
      Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email =
        user?.email ?? 'No email'; // Get email or default to 'No email'

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).appBarTheme.backgroundColor,
            ),
            accountName: Padding(
              padding:
                  const EdgeInsets.only(top: 35.0), // Increased top padding
              child: Text(
                'John Doe',
                style: TextStyle(
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  'Points: $currentPoints',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
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
            title: Text(
              AppLocalizations.of(context)?.cardCollection ?? 'Card Collection',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GridList()),
              );
            },
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)?.heatMap ?? 'Heat Map',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Tracker()),
              );
            },
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)?.scoreboard ?? 'Scoreboard',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Scoreboard()),
              );
            },
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)?.friends ?? 'Friends',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddFriendsPage()),
              );
            },
          ),
          ListTile(
            title: Text(
              'App Language: $_selectedLanguage',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ), // Display selected language
            onTap: () {
              setState(() {
                _showLanguageDropdown = !_showLanguageDropdown; // Toggle dropdown
              });
            },
            trailing: _showLanguageDropdown
                ? DropdownButton<String>(
                    value: _selectedLanguage,
                    items: _languages.map((language) {
                      return DropdownMenuItem<String>(
                        value: language,
                        child: Text(
                          language,
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedLanguage = newValue!;
                        _saveSelectedLanguage(); // Save the selected language
                        _showLanguageDropdown = false;
                        Provider.of<LocaleProvider>(context, listen: false)
                            .setLocale(newValue); // Hide dropdown after selection
                      });
                    },
                  )
                : null, // Hide dropdown if not tapped
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)?.logout ?? 'Scoreboard',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            leading: Icon(
              Icons.logout,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthGate()),
              );
            },
          ),
          ListTile(
            title: Text(
              _isDarkMode ? 'Light Mode' : 'Dark Mode',
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ), // Toggle text based on dark mode
            trailing: IconButton(
              icon: Icon(
                _isDarkMode ? Icons.brightness_7 : Icons.brightness_4,
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: _toggleDarkMode,
            ),
          ),
        ],
      ),
    );
  }
}
