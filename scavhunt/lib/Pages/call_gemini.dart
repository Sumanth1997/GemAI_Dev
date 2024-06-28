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
          'Return a list of top 10 rated/famous restaurants in $location. Just the names, not description and images. Also, without serial number or bullet points. Response should not contain any special characters.')
    ];
    final response = await model.generateContent(content);
    
    return response.text ?? '';
  } catch (e) {
    print('Failed to retrieve restaurants from $location');
    print("Error is $e");
    return '';
  }
  // return 'Unexpected error occurred';
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
          'I will provide a list of 10 restaurant names. For each restaurant, generate 3 location-based clues for a scavenger hunt game. The clues should be specific to the restaurant\'s immediate surroundings and not sound generic. Return the responses in JSON format. Response should not contain any special characters in it. $responseRestaurants')
    ];
    final response = await model.generateContent(content);
    print(response);
    return response.text ?? '';
  } catch (e) {
    print('Failed to retrieve clues for restaurants from $responseRestaurants');
    return '';
  }
  // return 'Unexpected error occurred';
}

Future<String> callGeminiForCityTouristPlaces(String location) async {
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
          'Return a list of top 10 famous/must visit tourist places in $location. Just the names, not description and images. Also, without serial number or bullet points. Response should not contain any special characters.')
    ];
    final response = await model.generateContent(content);
    
    return response.text ?? '';
  } catch (e) {
    print('Failed to retrieve restaurants from $location');
    print("Error is $e");
    return '';
  }
  // return 'Unexpected error occurred';
}

Future<String> callGeminiForCountryTouristPlaces(String location) async {
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
          'Return a list of top 10 famous/must visit tourist places in $location. Just the names, not description and images. Also, without serial number or bullet points. Response should not contain any special characters.')
    ];
    final response = await model.generateContent(content);
    
    return response.text ?? '';
  } catch (e) {
    print('Failed to retrieve restaurants from $location');
    print("Error is $e");
    return '';
  }
  // return 'Unexpected error occurred';
}

Future<String> callGeminiForStateTouristPlaces(String location) async {
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
          'Return a list of top 10 famous/must visit tourist places in $location. Just the names, not description and images. Also, without serial number or bullet points. Response should not contain any special characters.')
    ];
    final response = await model.generateContent(content);
    
    return response.text ?? '';
  } catch (e) {
    print('Failed to retrieve restaurants from $location');
    print("Error is $e");
    return '';
  }
  // return 'Unexpected error occurred';
}

Future<String> callGeminiForContinentalTouristPlaces(String location) async {
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
          'Return a list of top 10 famous/must visit tourist places in $location. Just the names, not description and images. Also, without serial number or bullet points. Response should not contain any special characters.')
    ];
    final response = await model.generateContent(content);
    
    return response.text ?? '';
  } catch (e) {
    print('Failed to retrieve restaurants from $location');
    print("Error is $e");
    return '';
  }
  // return 'Unexpected error occurred';
}

Future<String> callGeminiForTouristPlacesClues(String responseRestaurants,String location) async {
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
          'I will provide a list of 10 famous/must visit tourist places in $location. For each place, generate 3 location-based clues for a scavenger hunt game. The clues should be specific to the tourist place\'s immediate surroundings and not sound generic. Return the responses in JSON format. Response should not contain any special characters in it. $responseRestaurants')
    ];
    final response = await model.generateContent(content);
    print(response);
    return response.text ?? '';
  } catch (e) {
    print('Failed to retrieve clues for restaurants from $responseRestaurants');
    return '';
  }
  // return 'Unexpected error occurred';
}

Future<String> callGeminiForStateRestaurants(String location) async {
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
          'Return a list of top 10 rated/famous restaurants in $location. Just the names, not description and images. Also, without serial number or bullet points. Response should not contain any special characters.')
    ];
    final response = await model.generateContent(content);
    
    return response.text ?? '';
  } catch (e) {
    print('Failed to retrieve restaurants from $location');
    print("Error is $e");
    return '';
  }
  // return 'Unexpected error occurred';
}

Future<String> callGeminiForCountryRestaurants(String country) async {
  print('Sumanth location is :$country');
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
          'Return a list of top 10 rated/famous restaurants in $country. Just the names, not description and images. Also, without serial number or bullet points. Response should not contain any special characters.')
    ];
    final response = await model.generateContent(content);
    
    return response.text ?? '';
  } catch (e) {
    print('Failed to retrieve restaurants from $country');
    print("Error is $e");
    return '';
  }
  // return 'Unexpected error occurred';
}
Future<String> callGeminiForContinentalRestaurants(String location) async {
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
          'Return a list of top 10 rated/famous restaurants in the world. Just the names, not description and images. Also, without serial number or bullet points. Response should not contain any special characters.')
    ];
    final response = await model.generateContent(content);
    
    return response.text ?? '';
  } catch (e) {
    print('Failed to retrieve restaurants from $location');
    print("Error is $e");
    return '';
  }
  // return 'Unexpected error occurred';
}
