import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:namer_app/Pages/Clues.dart'; // Import your CluesCard widget
import 'package:namer_app/Pages/call_gemini.dart'; // Import your callGeminiForRestaurants and callGeminiForClues methods
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:pretty_logger/pretty_logger.dart';
// import 'package:logger/logger.dart';
// import 'package:path/path.dart' as path;

class LocationScreen extends StatefulWidget {
  final String category;
  final String selectedText;

  const LocationScreen(
      {Key? key, required this.category, required this.selectedText})
      : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _locationMessage = "Fetching list of nearby locations...";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(widget.category, widget.selectedText);
  }

  Future<void> _getCurrentLocation(String category, String selectedText) async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      // Check for location permissions
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied.';
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Reverse geocode the coordinates
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        print("Sumanth's place is ${placemarks[0]}");
        print("Sumanth category is $category");
        if (category == 'restaurants') {
          if (selectedText == 'City Cove Caper') {
            interCityHunt(place.locality!, place.administrativeArea!);
          } else if (selectedText == 'Virtual Voyage') {
            interCityHunt(place.locality!, place.administrativeArea!);
          } else if (selectedText == 'State Secret Search') {
            interStateHunt(place.administrativeArea!);
          } else if (selectedText == 'Nation Nautical Nightmare') {
            interCountryHunt(place.country!);
          } else if (selectedText == 'World Wind Wander') {
            interContinentalHunt();
          }
        } else {
          if (selectedText == 'City Cove Caper') {
            interCityTouristHunt(place.locality!, place.administrativeArea!);
          } else if (selectedText == 'Virtual Voyage') {
            interCityTouristHunt(place.locality!, place.administrativeArea!);
          } else if (selectedText == 'State Secret Search') {
            interStateTouristHunt(place.administrativeArea!);
          } else if (selectedText == 'Nation Nautical Nightmare') {
            interCountryTouristHunt(place.country!);
          } else if (selectedText == 'World Wind Wander') {
            interContinentalTouristHunt();
          }
          // _createTouristPlacesHunt(place.locality!, place.administrativeArea!);
        }
      } else {
        throw 'Unable to determine the location.';
      }
    } catch (e) {
      if (e is FormatException) {
        print('Error parsing JSON: $e');
        // Display an error message to the user
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
      } else {
        print('Error: $e');
        // Handle other potential errors
      }
    }
  }

  void interCityHunt(String locality, String administrativeArea) async {
    try {
      String locationMessage = "$locality, $administrativeArea";
      print(locationMessage);
      String? responseRestaurants;
      int retryCount = 0; // Track retry attempts

      do {
        responseRestaurants = await callGeminiForRestaurants(locationMessage);
        print("Sumanth debug restaurants $responseRestaurants");
        retryCount++;
      } while (
          responseRestaurants.isEmpty && retryCount < 3); // Retry up to 3 times

      if (responseRestaurants.isEmpty) {
        // Handle case where retries fail
        print('Failed to retrieve restaurants after $retryCount retries.');
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return; // Stop execution if responseRestaurants is null
      }
      // print(responseRestaurants);

      String? callGeminiClueResponse;
      // int retryCountClues = 0; // Track retry attempts

      callGeminiClueResponse = await callGeminiForClues(responseRestaurants);
      // print("Sumanth debug clues |$callGeminiClueResponse|");
      // retryCountClues++;
      if (callGeminiClueResponse.isNotEmpty) {
        int chunkSize = 1000; // Customize the chunk size as needed
        for (int i = 0; i < callGeminiClueResponse.length; i += chunkSize) {
          int end = (i + chunkSize < callGeminiClueResponse.length)
              ? i + chunkSize
              : callGeminiClueResponse.length;
          print("Sumanth debug clues");
          print(callGeminiClueResponse.substring(i, end));
        }
      }
      // _writeErrorDetailsToFile(callGeminiClueResponse, responseRestaurants);

      if (callGeminiClueResponse.isEmpty) {
        // Handle case where retries fail
        // print('Failed to retrieve clues after $retryCountClues retries.');
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return; // Stop execution if callGeminiClueResponse is null
      }

      print("Sumanth debug JSON error point 1");
      // String responseWithoutBackticks = callGeminiClueResponse
      //     .replaceAll('```json', '')
      //     .replaceAll('```', '');

      print("Sumanth debug JSON error point 1.1");
      if (callGeminiClueResponse.isEmpty) {
        print("Sumanth debug before 1.2 clues response is null");
      }
      print("Sumanth debug 1.2 |$callGeminiClueResponse|");
      Map<String, dynamic> restaurantClues;
      try {
        restaurantClues = json.decode(callGeminiClueResponse);
      } catch (e) {
        print('Error parsing JSON: $e');
        setState(() {});
        return;
      }

      List<List<String>> cluesList = [];
      print("Sumanth debug JSON error point 2");

      List<String> restaurantList = responseRestaurants
          .split('\n')
          .map((restaurant) => restaurant.trim())
          .toList();

      print("Sumanth debug JSON error point 3");
      restaurantClues.forEach((restaurant, clues) {
        List<String> cluesPerRestaurant = [];
        for (var clue in clues) {
          cluesPerRestaurant.add(clue);
        }
        cluesList.add(cluesPerRestaurant);
      });

      print("Sumanth debug JSON error point 4");
      print("Sumanth inside Location print");

      // Navigate to CluesCard with the fetched data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CluesCard(
            difficulty_level: widget.selectedText,
            restaurantList: restaurantList,
            cluesList: cluesList,
          ),
        ),
      );
    } catch (e) {
      print('Error: $e');
      // Handle other potential errors
      setState(() {});
    }
  }

  void interStateHunt(String administrativeArea) async {
    try {
      // String locationMessage = "$administrativeArea";
      print(administrativeArea);
      String responseRestaurants;
      int retryCount = 0; // Track retry attempts

      do {
        responseRestaurants =
            await callGeminiForStateRestaurants(administrativeArea);
        retryCount++;
      } while (
          // ignore: unnecessary_null_comparison
          responseRestaurants.isEmpty && retryCount < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (responseRestaurants.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
      }
      print(responseRestaurants);
      // String callGeminiClueResponse =
      //     await callGeminiForClues(responseRestaurants);
      String callGeminiClueResponse;
      int retryCountClues = 0; // Track retry attempts

      do {
        callGeminiClueResponse = await callGeminiForClues(responseRestaurants);
        retryCountClues++;
        _writeErrorDetailsToFile(callGeminiClueResponse, responseRestaurants);
        // ignore: unnecessary_null_comparison
      } while (callGeminiClueResponse.isEmpty &&
          retryCountClues < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (callGeminiClueResponse.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
      }
      String responseWithoutBackticks = callGeminiClueResponse
          .replaceAll('```json', '')
          .replaceAll('```', '');
      Map<String, dynamic> restaurantClues =
          json.decode(responseWithoutBackticks);
      List<List<String>> cluesList = [];

      List<String> restaurantList = responseRestaurants
          .split('\n')
          .map((restaurant) => restaurant.trim())
          .toList();

      restaurantClues.forEach((restaurant, clues) {
        List<String> cluesPerRestaurant = [];
        for (var clue in clues) {
          cluesPerRestaurant.add(clue);
        }
        cluesList.add(cluesPerRestaurant);
      });
      print("Sumanth inside Location print");
      // Navigate to CluesCard with the fetched data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CluesCard(
            difficulty_level: widget.selectedText,
            restaurantList: restaurantList,
            cluesList: cluesList,
          ),
        ),
      );
    } catch (e) {
      if (e is FormatException) {
        print('Error parsing JSON: $e');
        // Display an error message to the user
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
      } else {
        print('Error: $e');
        // Handle other potential errors
      }
    }
  }

  void interCountryHunt(String country) async {
    try {
      // String locationMessage = "$locality, $administrativeArea";
      print(country);
      String responseRestaurants;
      int retryCount = 0; // Track retry attempts

      do {
        responseRestaurants = await callGeminiForCountryRestaurants(country);
        retryCount++;
      } while (
          // ignore: unnecessary_null_comparison
          responseRestaurants.isEmpty && retryCount < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (responseRestaurants.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
      }
      print(responseRestaurants);
      // String callGeminiClueResponse =
      //     await callGeminiForClues(responseRestaurants);
      String callGeminiClueResponse;
      int retryCountClues = 0; // Track retry attempts

      do {
        callGeminiClueResponse = await callGeminiForClues(responseRestaurants);
        retryCountClues++;
        _writeErrorDetailsToFile(callGeminiClueResponse, responseRestaurants);
        // ignore: unnecessary_null_comparison
      } while (callGeminiClueResponse.isEmpty &&
          retryCountClues < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (callGeminiClueResponse.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
      }
      String responseWithoutBackticks = callGeminiClueResponse
          .replaceAll('```json', '')
          .replaceAll('```', '');
      Map<String, dynamic> restaurantClues =
          json.decode(responseWithoutBackticks);
      List<List<String>> cluesList = [];

      List<String> restaurantList = responseRestaurants
          .split('\n')
          .map((restaurant) => restaurant.trim())
          .toList();

      restaurantClues.forEach((restaurant, clues) {
        List<String> cluesPerRestaurant = [];
        for (var clue in clues) {
          cluesPerRestaurant.add(clue);
        }
        cluesList.add(cluesPerRestaurant);
      });
      print("Sumanth inside Location print");
      // Navigate to CluesCard with the fetched data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CluesCard(
            difficulty_level: widget.selectedText,
            restaurantList: restaurantList,
            cluesList: cluesList,
          ),
        ),
      );
    } catch (e) {
      if (e is FormatException) {}
      if (e is FormatException) {
        print('Error parsing JSON: $e');
        // Display an error message to the user
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
      } else {
        print('Error: $e');
        // Handle other potential errors
      }
    }
  }

  void interContinentalHunt() async {
    try {
      String locationMessage = "The world";
      // print(locationMessage);
      String responseRestaurants;
      int retryCount = 0; // Track retry attempts

      do {
        responseRestaurants =
            await callGeminiForContinentalRestaurants(locationMessage);
        retryCount++;
      } while (
          // ignore: unnecessary_null_comparison
          responseRestaurants.isEmpty && retryCount < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (responseRestaurants.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
        // Use the retrieved restaurants in responseRestaurants
      }
      print(responseRestaurants);
      // String callGeminiClueResponse =
      //     await callGeminiForClues(responseRestaurants);
      String callGeminiClueResponse;
      int retryCountClues = 0; // Track retry attempts

      do {
        callGeminiClueResponse = await callGeminiForClues(responseRestaurants);
        retryCountClues++;
        _writeErrorDetailsToFile(callGeminiClueResponse, responseRestaurants);
        // ignore: unnecessary_null_comparison
      } while (callGeminiClueResponse.isEmpty &&
          retryCountClues < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (callGeminiClueResponse.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
        // Use the retrieved restaurants in responseRestaurants
      }
      String responseWithoutBackticks = callGeminiClueResponse
          .replaceAll('```json', '')
          .replaceAll('```', '');
      Map<String, dynamic> restaurantClues =
          json.decode(responseWithoutBackticks);
      List<List<String>> cluesList = [];

      List<String> restaurantList = responseRestaurants
          .split('\n')
          .map((restaurant) => restaurant.trim())
          .toList();

      restaurantClues.forEach((restaurant, clues) {
        List<String> cluesPerRestaurant = [];
        for (var clue in clues) {
          cluesPerRestaurant.add(clue);
        }
        cluesList.add(cluesPerRestaurant);
      });
      print("Sumanth inside Location print");
      // Navigate to CluesCard with the fetched data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CluesCard(
            difficulty_level: widget.selectedText,
            restaurantList: restaurantList,
            cluesList: cluesList,
          ),
        ),
      );
    } catch (e) {
      if (e is FormatException) {
        print('Error parsing JSON: $e');
        // Display an error message to the user
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
      } else {
        print('Error: $e');
        // Handle other potential errors
      }
    }
  }

  void virtualHunt(String locality, String administrativeArea) async {
    try {
      String locationMessage = "$locality, $administrativeArea";
      print(locationMessage);
      String responseRestaurants;
      int retryCount = 0; // Track retry attempts

      do {
        responseRestaurants = await callGeminiForRestaurants(locationMessage);
        retryCount++;
      } while (
          // ignore: unnecessary_null_comparison
          responseRestaurants.isEmpty && retryCount < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (responseRestaurants.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
        // Use the retrieved restaurants in responseRestaurants
      }
      print(responseRestaurants);
      // String callGeminiClueResponse =
      //     await callGeminiForClues(responseRestaurants);
      String callGeminiClueResponse;
      int retryCountClues = 0; // Track retry attempts

      do {
        callGeminiClueResponse = await callGeminiForClues(responseRestaurants);
        retryCountClues++;
        _writeErrorDetailsToFile(callGeminiClueResponse, responseRestaurants);
        // ignore: unnecessary_null_comparison
      } while (callGeminiClueResponse.isEmpty &&
          retryCountClues < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (callGeminiClueResponse.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
        // Use the retrieved restaurants in responseRestaurants
      }
      String responseWithoutBackticks = callGeminiClueResponse
          .replaceAll('```json', '')
          .replaceAll('```', '');
      Map<String, dynamic> restaurantClues =
          json.decode(responseWithoutBackticks);
      List<List<String>> cluesList = [];

      List<String> restaurantList = responseRestaurants
          .split('\n')
          .map((restaurant) => restaurant.trim())
          .toList();

      restaurantClues.forEach((restaurant, clues) {
        List<String> cluesPerRestaurant = [];
        for (var clue in clues) {
          cluesPerRestaurant.add(clue);
        }
        cluesList.add(cluesPerRestaurant);
      });
      print("Sumanth inside Location print");
      // Navigate to CluesCard with the fetched data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CluesCard(
            difficulty_level: widget.selectedText,
            restaurantList: restaurantList,
            cluesList: cluesList,
          ),
        ),
      );
    } catch (e) {
      if (e is FormatException) {
        print('Error parsing JSON: $e');
        // Display an error message to the user
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
      } else {
        print('Error: $e');
        // Handle other potential errors
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _locationMessage == "Fetching list of nearby locations..."
          ? const SpinKitFadingCircle(
              // Use SpinKitFadingCircle as an example
              color: Colors.blue, // Customize the color (optional)
              size: 50.0, // Customize the size (optional)
            )
          : Text(
              _locationMessage,
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
    );
  }

  void interContinentalTouristHunt() async {
    try {
      String locationMessage = "The World";
      print(locationMessage);
      String responseTouristPlaces;
      int retryCount = 0; // Track retry attempts

      do {
        responseTouristPlaces =
            await callGeminiForContinentalTouristPlaces(locationMessage);
        retryCount++;
      } while (
          // ignore: unnecessary_null_comparison
          responseTouristPlaces.isEmpty &&
              retryCount < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (responseTouristPlaces.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
        // Use the retrieved restaurants in responseRestaurants
      }
      print(responseTouristPlaces);
      // String callGeminiClueResponse =
      //     await callGeminiForClues(responseRestaurants);
      String callGeminiClueResponse;
      int retryCountClues = 0; // Track retry attempts

      do {
        callGeminiClueResponse = await callGeminiForTouristPlacesClues(
            responseTouristPlaces, locationMessage);
        _writeErrorDetailsToFile(callGeminiClueResponse, responseTouristPlaces);
        retryCountClues++;
        // ignore: unnecessary_null_comparison
      } while (callGeminiClueResponse.isEmpty &&
          retryCountClues < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (callGeminiClueResponse.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
        // Use the retrieved restaurants in responseRestaurants
      }
      String responseWithoutBackticks = callGeminiClueResponse
          .replaceAll('```json', '')
          .replaceAll('```', '');
      Map<String, dynamic> restaurantClues =
          json.decode(responseWithoutBackticks);
      List<List<String>> cluesList = [];

      List<String> restaurantList = responseTouristPlaces
          .split('\n')
          .map((restaurant) => restaurant.trim())
          .toList();

      restaurantClues.forEach((restaurant, clues) {
        List<String> cluesPerRestaurant = [];
        for (var clue in clues) {
          cluesPerRestaurant.add(clue);
        }
        cluesList.add(cluesPerRestaurant);
      });
      print("Sumanth inside Location print");
      // Navigate to CluesCard with the fetched data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CluesCard(
            difficulty_level: widget.selectedText,
            restaurantList: restaurantList,
            cluesList: cluesList,
          ),
        ),
      );
    } catch (e) {
      if (e is FormatException) {
        print('Error parsing JSON: $e');
        // Display an error message to the user
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
      } else {
        print('Error: $e');
        // Handle other potential errors
      }
    }
  }

  void interCountryTouristHunt(String country) async {
    try {
      // String locationMessage = "$locality, $administrativeArea";
      // print(locationMessage);
      String responseTouristPlaces;
      int retryCount = 0; // Track retry attempts

      do {
        responseTouristPlaces =
            await callGeminiForCountryTouristPlaces(country);
        retryCount++;
      } while (
          // ignore: unnecessary_null_comparison
          responseTouristPlaces.isEmpty &&
              retryCount < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (responseTouristPlaces.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
        // Use the retrieved restaurants in responseRestaurants
      }
      print(responseTouristPlaces);
      // String callGeminiClueResponse =
      //     await callGeminiForClues(responseRestaurants);
      String callGeminiClueResponse;
      int retryCountClues = 0; // Track retry attempts

      do {
        callGeminiClueResponse = await callGeminiForTouristPlacesClues(
            responseTouristPlaces, country);
        _writeErrorDetailsToFile(callGeminiClueResponse, responseTouristPlaces);
        retryCountClues++;
        // ignore: unnecessary_null_comparison
      } while (callGeminiClueResponse.isEmpty &&
          retryCountClues < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (callGeminiClueResponse.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
        // Use the retrieved restaurants in responseRestaurants
      }
      String responseWithoutBackticks = callGeminiClueResponse
          .replaceAll('```json', '')
          .replaceAll('```', '');
      Map<String, dynamic> restaurantClues =
          json.decode(responseWithoutBackticks);
      List<List<String>> cluesList = [];

      List<String> restaurantList = responseTouristPlaces
          .split('\n')
          .map((restaurant) => restaurant.trim())
          .toList();

      restaurantClues.forEach((restaurant, clues) {
        List<String> cluesPerRestaurant = [];
        for (var clue in clues) {
          cluesPerRestaurant.add(clue);
        }
        cluesList.add(cluesPerRestaurant);
      });
      print("Sumanth inside Location print");
      // Navigate to CluesCard with the fetched data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CluesCard(
            difficulty_level: widget.selectedText,
            restaurantList: restaurantList,
            cluesList: cluesList,
          ),
        ),
      );
    } catch (e) {
      if (e is FormatException) {
        print('Error parsing JSON: $e');
        // Display an error message to the user
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
      } else {
        print('Error: $e');
        // Handle other potential errors
      }
    }
  }

  void interCityTouristHunt(String locality, String administrativeArea) async {
    try {
      String locationMessage = "$locality, $administrativeArea";
      print(locationMessage);
      String responseTouristPlaces;
      int retryCount = 0; // Track retry attempts

      do {
        responseTouristPlaces =
            await callGeminiForCityTouristPlaces(locationMessage);
        retryCount++;
      } while (
          // ignore: unnecessary_null_comparison
          responseTouristPlaces.isEmpty &&
              retryCount < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (responseTouristPlaces.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
        // Use the retrieved restaurants in responseRestaurants
      }
      print(responseTouristPlaces);
      // String callGeminiClueResponse =
      //     await callGeminiForClues(responseRestaurants);
      String callGeminiClueResponse;
      int retryCountClues = 0; // Track retry attempts

      do {
        callGeminiClueResponse = await callGeminiForTouristPlacesClues(
            responseTouristPlaces, locationMessage);
        _writeErrorDetailsToFile(callGeminiClueResponse, responseTouristPlaces);
        retryCountClues++;
        // ignore: unnecessary_null_comparison
      } while (callGeminiClueResponse.isEmpty &&
          retryCountClues < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (callGeminiClueResponse.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
        // Use the retrieved restaurants in responseRestaurants
      }
      String responseWithoutBackticks = callGeminiClueResponse
          .replaceAll('```json', '')
          .replaceAll('```', '');
      Map<String, dynamic> restaurantClues =
          json.decode(responseWithoutBackticks);
      List<List<String>> cluesList = [];

      List<String> restaurantList = responseTouristPlaces
          .split('\n')
          .map((restaurant) => restaurant.trim())
          .toList();

      restaurantClues.forEach((restaurant, clues) {
        List<String> cluesPerRestaurant = [];
        for (var clue in clues) {
          cluesPerRestaurant.add(clue);
        }
        cluesList.add(cluesPerRestaurant);
      });
      print("Sumanth inside Location print");
      // Navigate to CluesCard with the fetched data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CluesCard(
            difficulty_level: widget.selectedText,
            restaurantList: restaurantList,
            cluesList: cluesList,
          ),
        ),
      );
    } catch (e) {
      if (e is FormatException) {
        print('Error parsing JSON: $e');
        // Display an error message to the user
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
      } else {
        print('Error: $e');
        // Handle other potential errors
      }
    }
  }

  void interStateTouristHunt(String administrativeArea) async {
    try {
      // String locationMessage = "$administrativeArea";
      // print(locationMessage);
      String? responseTouristPlaces;
      int retryCount = 0; // Track retry attempts

      do {
        responseTouristPlaces =
            await callGeminiForStateTouristPlaces(administrativeArea);
        retryCount++;
      } while (
          // ignore: unnecessary_null_comparison
          responseTouristPlaces.isEmpty &&
              retryCount < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (responseTouristPlaces.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
        // Use the retrieved restaurants in responseRestaurants
      }
      print(responseTouristPlaces);
      // String callGeminiClueResponse =
      //     await callGeminiForClues(responseRestaurants);
      String? callGeminiClueResponse;
      int retryCountClues = 0; // Track retry attempts

      do {
        callGeminiClueResponse = await callGeminiForTouristPlacesClues(
            responseTouristPlaces, administrativeArea);
        _writeErrorDetailsToFile(callGeminiClueResponse, responseTouristPlaces);
        retryCountClues++;
        // ignore: unnecessary_null_comparison
      } while (callGeminiClueResponse.isEmpty &&
          retryCountClues < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (callGeminiClueResponse.isEmpty) {
        // Handle case where retries fail (consider more informative message)
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
        return;
      }
      String responseWithoutBackticks = callGeminiClueResponse
          .replaceAll('```json', '')
          .replaceAll('```', '');
      Map<String, dynamic> restaurantClues =
          json.decode(responseWithoutBackticks);
      List<List<String>> cluesList = [];

      List<String> restaurantList = responseTouristPlaces
          .split('\n')
          .map((restaurant) => restaurant.trim())
          .toList();

      restaurantClues.forEach((restaurant, clues) {
        List<String> cluesPerRestaurant = [];
        for (var clue in clues) {
          cluesPerRestaurant.add(clue);
        }
        cluesList.add(cluesPerRestaurant);
      });
      print("Sumanth inside Location print");
      // Navigate to CluesCard with the fetched data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CluesCard(
            difficulty_level: widget.selectedText,
            restaurantList: restaurantList,
            cluesList: cluesList,
          ),
        ),
      );
    } catch (e) {
      if (e is FormatException) {
        print('Error parsing JSON: $e');
        // Display an error message to the user
        setState(() {
          _locationMessage = 'Error loading data. Please try again.';
        });
      } else {
        print('Error: $e');
        // Handle other potential errors
      }
    }
  }

  Future<void> _writeErrorDetailsToFile(
      String? callGeminiClueResponse, String? responseTouristPlaces) async {
    // Create an instance of Logger
    print("Sumanth Error is :");
    print(callGeminiClueResponse);
    print(responseTouristPlaces);

    // import 'dart:io';

    try {
      // Get the temporary directory
      final directory = await getTemporaryDirectory();
      final logsDirectoryPath = '${directory.path}/logs';

      // Create the logs directory if it doesn't exist
      final logsDirectory = Directory(logsDirectoryPath);
      if (!await logsDirectory.exists()) {
        await logsDirectory.create(recursive: true);
      }

      // Define the file path in the logs directory
      final filePath = '$logsDirectoryPath/error_log.txt';

      // Create a File instance
      final file = File(filePath);

      // Write the error details to the file
      final errorDetails =
          'Call Gemini Clue Response: $callGeminiClueResponse\nResponse Tourist Places: $responseTouristPlaces\n';

      // Append the error details to the file
      await file.writeAsString(errorDetails, mode: FileMode.append);

      print('Error details written to file: $filePath');
    } catch (e) {
      print('Error writing to file: $e');
    }
  }
}
