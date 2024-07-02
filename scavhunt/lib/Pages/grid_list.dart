import 'package:flutter/material.dart';

class GridList extends StatelessWidget {
GridList({super.key});

  // Replace with your actual list of restaurants, image paths, and dates
  final List<String> restaurants = [
    'Copper Spoon',
    'Restaurant 2',
    // ...
  ];
  final List<String> imagePaths = [
    'images/FortWayne_Downtown.png',
    'path/to/image2.jpg',
    // ...
  ];
  final List<String> dates = [
    'July 12024',
    'Date 2',
    // ...
  ];

  @override
  Widget build(BuildContext context) {
    const title = 'Grid List';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: GridView.count(
          crossAxisCount: 2, // Adjust for desired number of columns
          childAspectRatio: 0.7, // Adjust for desired card aspect ratio
          children: List.generate(restaurants.length, (index) {
            return RestaurantCard(
              restaurantName: restaurants[index],
              imagePath: imagePaths[index],
              date: dates[index],
            );
          }),
        ),
      ),
    );
  }
}

class RestaurantCard extends StatelessWidget {
  final String restaurantName;
  final String imagePath;
  final String date;

  const RestaurantCard({
    super.key,
    required this.restaurantName,
    required this.imagePath,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          // Image background
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          // Text overlay
          Positioned(
            bottom: 10.0,
            left: 10.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  restaurantName,
                  style: const TextStyle(color: Colors.white, fontSize: 18.0),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.white, fontSize: 14.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
