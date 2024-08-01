import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:namer_app/Pages/auth_gate.dart';
import 'package:namer_app/Pages/drawer.dart';

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
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: localeProvider,
          child: MyApp(),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
          child: MyApp(),
        ),
      ],
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
          theme: Provider.of<ThemeProvider>(context).isDarkMode
              ? ThemeData.dark() // Use dark theme if dark mode is enabled
              : ThemeData.light(),
          // home: MyHomePage(),
          supportedLocales: L10n.all,
          localizationsDelegates: [
            AppLocalizations.delegate, // Use generated delegate
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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
      case 'Spanish':
        _locale = const Locale('es');
        break;
      case 'Chinese':
        _locale = const Locale('zh');
        break;
      case 'French':
        _locale = const Locale('fr');
        break;
      case 'German':
        _locale = const Locale('de');
        break;
      case 'Russian':
        _locale = const Locale('ru');
        break;
      case 'Japanese':
        _locale = const Locale('ja');
        break;
      // Add cases for other languages as needed
      default:
        _locale = const Locale('en'); // Default to English
    }
    notifyListeners();
  }
}
