import 'package:flutter/material.dart';
import 'package:namer_app/Pages/Location_Print.dart'; // Import your LocationPrint widget
import 'package:namer_app/Pages/drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart'; // Correct import

class DifficultyLevel extends StatelessWidget {
  const DifficultyLevel({Key? key, required this.category}) : super(key: key);

  final String category;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> itemData = [
      {
        'textKey': 'virtualVoyage', // Translation key
        'descriptionKey':
            'virtualVoyageDescription', // Translation key for description
        'cardColor': Colors.brown, // Bronze
      },
      {
        'textKey': 'cityCoveCaper', // Translation key
        'descriptionKey':
            'cityCoveCaperDescription', // Translation key for description
        'cardColor': const Color.fromARGB(255, 189, 189, 189), // Silver
      },
      {
        'textKey': 'stateSecretSearch', // Translation key
        'descriptionKey':
            'stateSecretSearchDescription', // Translation key for description
        'cardColor': Colors.amber, // Gold
      },
      {
        'textKey': 'nationNauticalNightmare', // Translation key
        'descriptionKey':
            'nationNauticalNightmareDescription', // Translation key for description
        'cardColor': Colors.lightBlueAccent, // Diamond (light blue)
      },
      {
        'textKey': 'worldWindWander', // Translation key
        'descriptionKey':
            'worldWindWanderDescription', // Translation key for description
        'cardColor': Color.fromARGB(255, 238, 5, 5), // Obsidian
      },
      // Add more items as needed
    ];

    final localizations = AppLocalizations.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          localizations?.chooseDifficultyLevel ?? 'Choose Difficulty Level',
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
          final String text =
              _getLocalizedString(localizations, item['textKey']);
          final String description =
              _getLocalizedString(localizations, item['descriptionKey']);

          return Flexible(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ItemWidget(
                text: text,
                description: description,
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                cardColor: item['cardColor'],
                onTap: () {
                  navigateToLocationPrint(context, item['textKey']);
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getLocalizedString(AppLocalizations? localizations, String key) {
    switch (key) {
      case 'virtualVoyage':
        return localizations?.virtualVoyage ?? key;
      case 'virtualVoyageDescription':
        return localizations?.virtualVoyageDescription ?? key;
      case 'cityCoveCaper':
        return localizations?.cityCoveCaper ?? key;
      case 'cityCoveCaperDescription':
        return localizations?.cityCoveCaperDescription ?? key;
      case 'stateSecretSearch':
        return localizations?.stateSecretSearch ?? key;
      case 'stateSecretSearchDescription':
        return localizations?.stateSecretSearchDescription ?? key;
      case 'nationNauticalNightmare':
        return localizations?.nationNauticalNightmare ?? key;
      case 'nationNauticalNightmareDescription':
        return localizations?.nationNauticalNightmareDescription ?? key;
      case 'worldWindWander':
        return localizations?.worldWindWander ?? key;
      case 'worldWindWanderDescription':
        return localizations?.worldWindWanderDescription ?? key;
      default:
        return key; // Fallback to the key if no matching localization is found
    }
  }

  void navigateToLocationPrint(BuildContext context, String selectedTextKey) {
    print(
        "Sumanth printing $selectedTextKey & $category before calling location print");
    var difficultyLevel;
    switch (selectedTextKey) {
      case 'virtualVoyage':
        difficultyLevel = 'Virtual Voyage';
        break;
      case 'cityCoveCaper':
        difficultyLevel = 'City Cove Caper';
        break;
      case 'stateSecretSearch':
        difficultyLevel = 'State Secret Search';
        break;
      case 'nationNauticalNightmare':
        difficultyLevel = 'Nation Nautical Nightmare';
        break;
      case 'worldWindWander':
        difficultyLevel = 'World Wind Wander';
        break;

      default:
        difficultyLevel = 'Virtual Voyage';
        break;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationScreen(
          selectedText: difficultyLevel,
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
