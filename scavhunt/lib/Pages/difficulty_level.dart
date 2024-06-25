import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:namer_app/Pages/Clues.dart';
import 'package:namer_app/Pages/Location_Print.dart';
import 'package:namer_app/Pages/auth_gate.dart';

class DifficultyLevel extends StatelessWidget {
  const DifficultyLevel({Key? key, required String category});

  @override
  Widget build(BuildContext context) {
    final List<String> itemTexts = [
      'Virtual Hunt',
      'Inter City',
      'Inter State',
      'Inter Country',
      'Inter continent',
      // Add more items as needed
    ];

    final TextStyle itemTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.deepPurple,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Choose difficulty level',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              accountName: Text('John Doe'),
              accountEmail: Text('john.doe@example.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('images/avatar.png'),
              ),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                Navigator.pop(context);
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
      ),
      body: Column(
        children: itemTexts.map((text) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ItemWidget(
                text: text,
                textStyle: itemTextStyle,
                onTap: () {
                  if (text == 'Inter City') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LocationPrint()),
                    );
                  } else if (text == 'Inter State') {
                    
                  } else if (text == 'Inter Country') {
                    
                  } else if (text == 'Inter continent') {
                    // Handle 'Inter continent' navigation
                  } else if (text == 'Virtual Hunt') {
                    // Handle 'Virtual Hunt' navigation
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final VoidCallback onTap;

  ItemWidget({required this.text, required this.textStyle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              text,
              style: textStyle,
            ),
          ),
        ),
      ),
    );
  }
}
