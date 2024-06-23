// import 'dart:io';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


Future<String> callGeminiForRestaurants(String location) async {
  print('Sumanth location is :$location');
  try {
    // Access your API key as an environment variable
    print("Loading .env file");
    await dotenv.load();
    print('Finished loading .env file.');

    final apiKey = dotenv.env['API_KEY']?? '';
    print('Sumanth\'s API Key: $apiKey');
    if (apiKey.isEmpty) {
      throw Exception('API_KEY is not set in the .env file');
    }
    

    // The Gemini 1.5 models are versatile and work with most use cases
    final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);
    final content = [
      Content.text(
          'Return a list of top 10 rated/famous restaurants in $location. Just the names, not description and images. Also, without serial number or bullet points.')
    ];
    final response = await model.generateContent(content);
    
    return response.text ?? '';
  } catch (e) {
    print('Failed to retrieve restaurants from $location');
    print("Error is $e");
  }
  return 'Unexpected error occurred';
}

Future<void> callGeminiForImages(String location) async {
  try {
    await dotenv.load();
    final apiKey = dotenv.env['API_KEY']?? '';

    if (apiKey.isEmpty) {
      throw Exception('API_KEY is not set in the .env file');
    }

    final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);
    final content = [
      Content.text('Generate images for famous landmarks and places in $location.')
    ];
    final response = await model.generateContent(content);

    // Print the entire response to the console
    print('Response from Gemini API: $response');

    // Now we can attempt to extract image URLs based on the response structure
    // if (response != null && response.containsKey('images')) {
    //   final imageUrls = List<String>.from(response['images']);
    //   print('Extracted image URLs: $imageUrls');
    // } else {
    //   print('No images found in the response');
    // }
  } catch (e) {
    print('Failed to retrieve images for $location: $e');
  }
}




Future<String> callGeminiForClues(String responseRestaurants) async {
  try {
   
    await dotenv.load();
    final apiKey = dotenv.env['API_KEY']?? '';
    if (apiKey.isEmpty) {
      throw Exception('API_KEY is not set in the .env file');
    }


    // The Gemini 1.5 models are versatile and work with most use cases
    final model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);
    final content = [
      Content.text(
          'I will provide a list of 10 restaurant names. For each restaurant, generate 3 location-based clues for a scavenger hunt game. The clues should be specific to the restaurant\'s immediate surroundings and not sound generic. Return the responses in JSON format. $responseRestaurants')
    ];
    final response = await model.generateContent(content);
    print(response);
    return response.text ?? '';
  } catch (e) {
    print('Failed to retrieve clues for restaurants from $responseRestaurants');
  }
  return 'Unexpected error occurred';
}
