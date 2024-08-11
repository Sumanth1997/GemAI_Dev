import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:namer_app/Pages/new_game.dart'; 

// ... other imports ...

// UserManagement class (You might want to move this to a separate file)
class UserManagement {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createUserDocument(User user) async {
    try {
      // Check if the user document already exists
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // If it doesn't exist, create it with initial data
        await _firestore.collection('users').doc(user.uid).set({
          'userId': user.uid,
          'displayName': user.displayName ?? 'Anonymous',
          'email': user.email,
          // Add other user-related fields as needed
        });
        print('User document created successfully!');
      } else {
        print('User document already exists.');
      }
    } catch (e) {
      print('Error creating user document: $e');
    }
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // User is not signed in, show the sign-in screen
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(
                  clientId:
                      "850910294528-ovg72gn8s7n67pogqe9jlru2gr3v1tkd.apps.googleusercontent.com"),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Center(
                child: Text(
                  'QuestSpot',
                  style: TextStyle(
                    fontSize: 32, // Adjust font size as needed
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome to QuestSpot, please sign in!')
                    : const Text('Welcome to QuestSpot, please sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
            sideBuilder: (context, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
              );
            },
          );
        } else {
          // User is signed in
          UserManagement().createUserDocument(snapshot.data!);
          return NewGame(); // Navigate to NewGame 
        }
      },
    );
  }
}
