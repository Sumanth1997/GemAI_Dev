import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:namer_app/Pages/Location_Print.dart'; // Import your LocationPrint widget
// import 'package:namer_app/Pages/auth_gate.dart';
import 'package:namer_app/Pages/drawer.dart';
// import 'package:namer_app/Pages/grid_list.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class DifficultyLevel extends StatelessWidget {
  const DifficultyLevel({Key? key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final List<String> itemTexts = [
      'Virtual Voyage',
      'City Cove Caper',
      'State Secret Search',
      'Nation Nautical Nightmare',
      'World Wind Wander',
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
          AppLocalizations.of(context)?.chooseDifficultyLevel ?? 'Choose Difficulty Level',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
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
      drawer: AppDrawer(),
      body: Column(
        children: itemTexts.map((text) {
          Color cardColor = Colors.grey; // Default color for other options

          switch (text) {
            case 'Virtual Voyage':
              cardColor = Colors.brown; // Bronze
              break;
            case 'City Cove Caper':
              cardColor = const Color.fromARGB(255, 189, 189, 189); // Silver
              break;
            case 'State Secret Search':
              cardColor = Colors.amber; // Gold
              break;
            case 'Nation Nautical Nightmare':
              cardColor = Colors.lightBlueAccent; // Diamond (light blue)
              break;
            case 'World Wind Wander':
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
    if (selectedText == 'City Cove Caper') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LocationScreen(selectedText: selectedText, category: category)),
      );
    } else if (selectedText == 'State Secret Search') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LocationScreen(selectedText: selectedText, category: category)),
      );
    } else if (selectedText == 'Nation Nautical Nightmare') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LocationScreen(selectedText: selectedText, category: category)),
      );
    } else if (selectedText == 'World Wind Wander') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LocationScreen(selectedText: selectedText, category: category)),
      );
    } else if (selectedText == 'Virtual Voyage') {
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
