import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/Pages/auth_gate.dart';

import 'package:namer_app/firebase_options.dart';
import 'package:namer_app/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
// import 'firebase_options.dart'; // Import your firebase_options.dart file

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load the selected language from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final selectedLanguage = prefs.getString('selectedLanguage') ?? 'English';

  // Create an instance of LocaleProvider and set the initial language
  final localeProvider = LocaleProvider();
  localeProvider.setLocale(selectedLanguage);

  runApp(
    ChangeNotifierProvider.value(
      value: localeProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          title: 'Namer App',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          ),
          // home: MyHomePage(),
          supportedLocales: L10n.all,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          locale: localeProvider.locale, // Use the current locale
          home: AuthGate(),
        );
      },
    );
  }
}

// Create a ChangeNotifier class to manage the locale
class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(String languageCode) {
    switch (languageCode) {
      case 'English':
        _locale = const Locale('en');
        break;
      case 'Kannada':
        _locale = const Locale('kn');
        break;
      // Add cases for other languages as needed
      default:
        _locale = const Locale('en'); // Default to English
    }
    notifyListeners();
  }
}