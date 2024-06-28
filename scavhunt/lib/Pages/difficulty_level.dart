import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namer_app/Pages/Location_Print.dart'; // Import your LocationPrint widget
import 'package:namer_app/Pages/auth_gate.dart';

class DifficultyLevel extends StatelessWidget {
  const DifficultyLevel({Key? key, required this.category});

  final String category;

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
      color: Colors.white,
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
          Color cardColor = Colors.grey; // Default color for other options

          switch (text) {
            case 'Virtual Hunt':
              cardColor = Colors.brown; // Bronze
              break;
            case 'Inter City':
              cardColor = const Color.fromARGB(255, 189, 189, 189); // Silver
              break;
            case 'Inter State':
              cardColor = Colors.amber; // Gold
              break;
            case 'Inter Country':
              cardColor = Colors.lightBlueAccent; // Diamond (light blue)
              break;
            case 'Inter continent':
              cardColor = Color.fromARGB(255, 238, 5, 5); // Obsidian
              break;
          }
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ItemWidget(
                text: text,
                textStyle: itemTextStyle,
                cardColor: cardColor,
                onTap: () {
                  navigateToLocationPrint(context, text);
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void navigateToLocationPrint(BuildContext context, String selectedText) {
    if (selectedText == 'Inter City') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LocationScreen(selectedText: selectedText, category: category)),
      );
    } else if (selectedText == 'Inter State') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LocationScreen(selectedText: selectedText, category: category)),
      );
    } else if (selectedText == 'Inter Country') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LocationScreen(selectedText: selectedText, category: category)),
      );
    } else if (selectedText == 'Inter continent') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LocationScreen(selectedText: selectedText, category: category)),
      );
    } else if (selectedText == 'Virtual Hunt') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LocationScreen(selectedText: selectedText, category: category)),
      );
    } else {
      // Handle other options if needed
    }
  }
}

class ItemWidget extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final VoidCallback onTap;
  final Color cardColor;

  ItemWidget(
      {required this.text,
      required this.textStyle,
      required this.onTap,
      required this.cardColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: cardColor,
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
