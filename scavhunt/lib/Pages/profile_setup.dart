import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/Pages/new_game.dart'; // Import the page to navigate to

class ProfileSetup extends StatefulWidget {
  final User user;

  const ProfileSetup({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  final TextEditingController _displayNameController = TextEditingController();
  int _selectedAge = 18;
  String? _selectedCountry;
  final _formKey = GlobalKey<FormState>();

  List<String> _countries = [
    'USA',
    'Canada',
    'Mexico',
    // Add more countries as needed
  ];

  @override
  void initState() {
    super.initState();
    _displayNameController.text = widget.user.displayName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome!'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please complete your profile before proceeding.'),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your display name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Age: $_selectedAge'),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedAge--;
                        });
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedAge++;
                        });
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: const InputDecoration(
                    labelText: 'Country of Origin',
                  ),
                  items: _countries.map((String country) {
                    return DropdownMenuItem<String>(
                      value: country,
                      child: Text(country),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCountry = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your country';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Update user profile in Firebase Auth
                      await widget.user.updateDisplayName(
                          _displayNameController.text);

                      // Update additional user data in Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.user.uid)
                          .set({
                        'userId': widget.user.uid,
                        'displayName': _displayNameController.text,
                        'email': widget.user.email,
                        'age': _selectedAge,
                        'country': _selectedCountry,
                      });

                      // Navigate to NewGame() after successful profile setup
                      Navigator.pushReplacement(
                        // ignore: use_build_context_synchronously
                        context,
                        MaterialPageRoute(builder: (context) => NewGame()),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
