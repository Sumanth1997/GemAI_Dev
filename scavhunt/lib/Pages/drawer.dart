// drawer.dart
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:namer_app/Pages/add_friends.dart';
import 'package:namer_app/Pages/auth_gate.dart';
import 'package:namer_app/Pages/grid_list.dart';
import 'package:namer_app/main.dart';
import 'package:namer_app/Pages/scoreboard.dart';
import 'package:namer_app/Pages/theme.dart';
import 'package:namer_app/Pages/tracker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  String? _displayName; // Variable to store the display name

  @override
  void initState() {
    super.initState();
    _fetchPoints();
    _loadProfileImage(); // Load the profile image when the widget initializes
    _loadSelectedLanguage(); // Load the selected language from SharedPreferences
    _loadDarkMode(); // Load dark mode preference
    _fetchDisplayName(); // Fetch the display name from Firestore
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

  Future<void> _saveApiKey() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _formKey.currentState!.validate()) {
      final apiKey = _apiKeyController.text.trim();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'apiKey': apiKey});
      // Close the dialog after saving
      Navigator.of(context).pop();
    }
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  // Fetch the display name from Firestore
  Future<void> _fetchDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          setState(() {
            _displayName = snapshot.data()?['displayName'];
          });
        }
      } catch (e) {
        print('Error fetching display name: $e');
      }
    }
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
                _displayName ?? 'John Doe', // Use the fetched display name
                style: TextStyle(
                  color:
                      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white,
                ),
              ),
            ),
            accountEmail: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white,
                  ),
                ),
                Text(
                  'Points: $currentPoints',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white,
                  ),
                ),
              ],
            ),
            currentAccountPicture: GestureDetector(
              onTap: _pickImage, // Call _pickImage when the avatar is tapped
              child: CircleAvatar(
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null, // Remove AssetImage('images/avatar.png')
                // If no profile image is available, the CircleAvatar will be empty
              ),
            ),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)?.cardCollection ?? 'Card Collection',
              // style: TextStyle(
              //   color: _isDarkMode ? Colors.white : Colors.black,
              // ),
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
              // style: TextStyle(
              //   color: _isDarkMode ? Colors.white : Colors.black,
              // ),
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
              // style: TextStyle(
              //   color: _isDarkMode ? Colors.white : Colors.black,
              // ),
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
              // style: TextStyle(
              //   color: _isDarkMode ? Colors.white : Colors.black,
              // ),
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
              // style: TextStyle(
              //   color: _isDarkMode ? Colors.white : Colors.black,
              // ),
            ),
            onTap: () {
              setState(() {
                _showLanguageDropdown = !_showLanguageDropdown;
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
                          // style: TextStyle(
                          //   color: _isDarkMode ? Colors.white : Colors.black,
                          // ),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedLanguage = newValue!;
                        _saveSelectedLanguage(); // Save the selected language
                        _showLanguageDropdown = false;
                        Provider.of<LocaleProvider>(context, listen: false)
                            .setLocale(newValue);
                      });
                    },
                  )
                : null, // Hide dropdown if not tapped
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)?.theme ?? 'Theme',
              // style: TextStyle(
              //   color: _isDarkMode ? Colors.white : Colors.black,
              // ),
            ),
            trailing: IconButton(
              icon: Icon(
                _isDarkMode ? Icons.brightness_7 : Icons.brightness_4,
              ),
              onPressed: () {
                _toggleDarkMode();
              },
            ),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)?.logout ?? 'Logout',
              // style: TextStyle(
              //   color: _isDarkMode ? Colors.white : Colors.black,
              // ),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
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
