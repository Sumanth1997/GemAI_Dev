import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:card_swiper/card_swiper.dart';

class CluesCard extends StatelessWidget {
  final List<List<String>> cluesList;

  CluesCard({Key? key, required this.cluesList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlipCard',
      theme: ThemeData.dark(),
      home: Clues(cluesList: cluesList, currentIndex: 0),
    );
  }
}

class Clues extends StatelessWidget {
  final List<String> images = [
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png', // Add more images if you have different ones
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png',
    'images/FortWayne_Downtown.png',
  ];
  final int currentIndex;
  final List<List<String>> cluesList;

  Clues({Key? key, required this.cluesList, required this.currentIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlipCard'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: const Color(0xFFFFFFFF)),
          ),
          MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: AppBar(
              elevation: 0.0,
              backgroundColor: Color(0x00FFFFFF),
            ),
          ),
          Center(
            child: Swiper(
              itemBuilder: (BuildContext context, int index) {
                return _buildFlipCard(images[index], cluesList[index], index + 1);
              },
              itemCount: cluesList.length,
              itemWidth: MediaQuery.of(context).size.width * 0.85,
              itemHeight: MediaQuery.of(context).size.height * 0.75,
              layout: SwiperLayout.TINDER,
              viewportFraction: 0.8,
              scale: 0.9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlipCard(String imagePath, List<String> clues, int currentIndex) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      side: CardSide.FRONT, // Ensure the front side is displayed first
      speed: 1000,
      onFlipDone: (status) {
        print(status);
      },
      front: Container(
        decoration: BoxDecoration(
          color: Color(0xFF006666),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Clues',
                        style: TextStyle(fontSize: 24, color: Colors.white)),
                  ],
                ),
                SizedBox(height: 16),
                for (var clue in clues)
                  Text(clue,
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                SizedBox(height: 16),
                Text('Click here to flip back',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Text('$currentIndex/${images.length}',
                  style: TextStyle(fontSize: 12.0, color: Colors.white)),
            ),
          ],
        ),
      ),
      back: Container(
        decoration: BoxDecoration(
          color: Color(0xFF006666),
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(8.0),
                      ),
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('Back',
                            style:
                                TextStyle(fontSize: 24, color: Colors.white)),
                        Text('Click here to flip front',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Text('$currentIndex/${images.length}',
                  style: TextStyle(fontSize: 12.0, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
