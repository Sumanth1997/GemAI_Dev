import 'package:flutter/material.dart';
import 'package:namer_app/Pages/Location_Print.dart'; // Import your LocationPrint widget
import 'package:namer_app/Pages/drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';

class DifficultyLevel extends StatelessWidget {
  const DifficultyLevel({Key? key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> itemData = [
      {
        'text': 'Virtual Voyage',
        'description': 'Play at home, discover digital treasures..',
        'cardColor': Colors.brown, // Bronze
      },
      {
        'text': 'City Cove Caper',
        'description': 'Uncover hidden treasures within your city limits.',
        'cardColor': const Color.fromARGB(255, 189, 189, 189), // Silver
      },
      {
        'text': 'State Secret Search',
        'description': 'Uncover mysteries within your state.',
        'cardColor': Colors.amber, // Gold
      },
      {
        'text': 'Nation Nautical Nightmare',
        'description': 'Conquer challenges across the country.',
        'cardColor': Colors.lightBlueAccent, // Diamond (light blue)
      },
      {
        'text': 'World Wind Wander',
        'description': 'Embark on a global adventure.',
        'cardColor': Color.fromARGB(255, 238, 5, 5), // Obsidian
      },
      // Add more items as needed
    ];

    final TextStyle itemTextStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Scaffold(
      resizeToAvoidBottomInset : false,
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
        children: itemData.map((item) {
          return Flexible(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ItemWidget(
                text: item['text'],
                description: item['description'], // Pass the description
                textStyle: itemTextStyle,
                cardColor: item['cardColor'],
                onTap: () {
                  navigateToLocationPrint(context, item['text']);
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void navigateToLocationPrint(BuildContext context, String selectedText) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationScreen(
          selectedText: selectedText,
          category: category,
        ),
      ),
    );
  }
}

class ItemWidget extends StatelessWidget {
  final String text;
  final String description; // Add the description property
  final TextStyle textStyle;
  final VoidCallback onTap;
  final Color cardColor;

  ItemWidget({
    required this.text,
    required this.description, // Pass the description
    required this.textStyle,
    required this.onTap,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, // Make the card take up the full width
        child: Card(
          color: cardColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  text,
                  style: textStyle,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  description, // Display the description
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
