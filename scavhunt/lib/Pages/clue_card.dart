import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClueCard extends StatelessWidget {
  final String answer;
  final String imagePath;
  final String date;

  const ClueCard({
    Key? key,
    required this.answer,
    required this.imagePath,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5, // Add some shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF006666), // Background color from Flipcard
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(8.0),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(imagePath), // Use NetworkImage for network images
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
                    Text(
                      answer, // Display answer
                      style: GoogleFonts.dancingScript(
                        textStyle: TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      date,
                      style: GoogleFonts.dancingScript(
                        textStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
