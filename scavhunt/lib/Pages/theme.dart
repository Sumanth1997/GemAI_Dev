import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode =  MediaQueryData.fromWindow(WidgetsBinding.instance.window).platformBrightness == Brightness.dark; // Initialize based on device brightness
  bool get isDarkMode => _isDarkMode;
  // Define color schemes for light and dark mode
  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue, // Example primary color
    hintColor: Colors.grey, // Example accent color
    scaffoldBackgroundColor: Color(0xFFFEFAE0), // Example background color
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFFCCD5AE), // Customize app bar background
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold, // Customize app bar title text color
        fontSize: 20, // Customize app bar title font size
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.openSans(
        textStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      bodyLarge: GoogleFonts.openSans(
        textStyle: TextStyle(
          fontSize: 16
        ),
        color: Colors.black,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFE0E5B6), // Customize button background color
        textStyle: TextStyle(
          color:Colors.black,
          fontWeight: FontWeight.bold,// Customize button text color
        ),
      ),
    ),
    cardTheme: CardTheme(
      color: Colors.black,// Customize card background color
      elevation: 2, // Customize card elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Customize card border radius
      ),
    ),
    // ... other light theme customizations
  );

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.purple, // Example primary color for dark mode
    hintColor: Colors.grey, // Example accent color for dark mode
    scaffoldBackgroundColor: Color(0xFF346751), // Example background color for dark mode
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF161616), // Customize app bar background
      titleTextStyle: TextStyle(
        color: Colors.white, // Customize app bar title text color
        fontSize: 20, // Customize app bar title font size
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.openSans(
        textStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      bodyLarge: GoogleFonts.openSans(
        textStyle: TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom( // Customize button background color
        textStyle: TextStyle(
          color: Colors.black,// Customize button text color
        ),
      ),
    ),
    cardTheme: CardTheme( // Customize card background color for dark mode
      elevation: 2, // Customize card elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Customize card border radius
      ),
    ),
    
    // ... other dark theme customizations
  );

  ThemeData get currentTheme => _isDarkMode ? darkTheme : lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
