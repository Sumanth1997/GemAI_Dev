import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:namer_app/Pages/Clues.dart';
import 'package:namer_app/Pages/call_gemini.dart'; // Import correct file here

class LocationPrint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Location Example'),
        ),
        body: LocationScreen(),
      ),
    );
  }
}

class LocationScreen extends StatefulWidget {
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _locationMessage = "Fetching list of nearby restaurants to create a game...";

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
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

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

  void _updateLocationMessage(String locality, String administrativeArea) async {
  try {
    String locationMessage = "$locality, $administrativeArea";
    print(locationMessage);
    String responseRestaurants = await callGeminiForRestaurants(locationMessage);
    print(responseRestaurants);
    String callGeminiClueResponse = await callGeminiForClues(responseRestaurants);
    String responseWithoutBackticks = callGeminiClueResponse.replaceAll('```json', '').replaceAll('```', '');
    Map<String, dynamic> restaurantClues = json.decode(responseWithoutBackticks);

    List<List<String>> cluesList = [];

    // Collect clues
    restaurantClues.forEach((restaurant, clues) {
      List<String> cluesPerRestaurant = [];
      for (var clue in clues) {
        cluesPerRestaurant.add(clue);
      }
      cluesList.add(cluesPerRestaurant);
    });

    // Navigate to CluesCard with collected clues
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CluesCard(cluesList: cluesList),
      ),
    );

  } catch (e) {
    setState(() {
      _locationMessage = 'Error: $e';
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _locationMessage,
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
