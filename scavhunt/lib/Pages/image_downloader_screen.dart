import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart'; // Import the generative_model package

class GeminiImageScreen extends StatefulWidget {
  @override
  _GeminiImageScreenState createState() => _GeminiImageScreenState();
}

class _GeminiImageScreenState extends State<GeminiImageScreen> {
  String location = 'New York'; // Example location

  Future<void> callGeminiForImages(String location) async {
    try {
      const apiKey = 'AIzaSyDtJ6HffYTNKv9H0Ax0B4WuwXEMHtadj1Y';

      final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);
      final content = [
        Content.text('Generate images for famous landmarks and places in $location.')
      ];
      final response = await model.generateContent(content);

      // Print the entire response to the console
      print('Response from Gemini API: $response');

      // Handle displaying the response in your app UI
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Gemini API Response'),
            content: Text(response.toString()), // Use toString() to display content
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );

    } catch (e) {
      print('Failed to retrieve images for $location: $e');
      // Handle error state in your UI
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to retrieve images for $location: $e'),
            actions: <Widget>[
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gemini Images'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            callGeminiForImages(location);
          },
          child: Text('Generate Images for $location'),
        ),
      ),
    );
  }
}
