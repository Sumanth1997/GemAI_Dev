import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:namer_app/Pages/Clues.dart'; // Import your CluesCard widget
import 'package:namer_app/Pages/call_gemini.dart'; // Import your callGeminiForRestaurants and callGeminiForClues methods
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LocationScreen extends StatefulWidget {
  final String category;

  const LocationScreen({Key? key, required this.category}) : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _locationMessage = "Fetching list of nearby locations...";

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
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
        _updateLocationMessage(place.locality!, place.administrativeArea!);
      } else {
        throw 'Unable to determine the location.';
      }
    } catch (e) {
      setState(() {
        _locationMessage = 'Error: $e';
      });
    }
  }

  void _updateLocationMessage(
      String locality, String administrativeArea) async {
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
          responseRestaurants == null && retryCount < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (responseRestaurants == null) {
        // Handle case where retries fail (consider more informative message)
        print('Failed to retrieve restaurants after $retryCount retries.');
      } else {
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
      // ignore: unnecessary_null_comparison
      } while (callGeminiClueResponse == null &&
          retryCountClues < 3); // Retry up to 3 times

      // ignore: unnecessary_null_comparison
      if (callGeminiClueResponse == null) {
        // Handle case where retries fail (consider more informative message)
        print('Failed to retrieve restaurants after $retryCountClues retries.');
      } else {
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
            // category: widget.category,
            restaurantList: restaurantList,
            cluesList: cluesList,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _locationMessage = 'Error: $e';
        print("Error is $e");
      });
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
}
