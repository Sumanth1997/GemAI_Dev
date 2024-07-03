// drawer.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namer_app/Pages/auth_gate.dart';
import 'package:namer_app/Pages/grid_list.dart';
import 'package:namer_app/Pages/tracker.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? 'No email'; // Get email or default to 'No email'

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            accountName: Text('John Doe'), // You can change this to display the user's name if you have it
            accountEmail: Text(email), // Display the user's email
            currentAccountPicture: CircleAvatar(
              backgroundImage: AssetImage('images/avatar.png'),
            ),
          ),
          ListTile(
            title: const Text('Card Collection'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GridList()),
              );
              // Navigator.pop(context);
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
            title: const Text('Logout'),
            leading: Icon(Icons.logout),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context); // Close the drawer
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
