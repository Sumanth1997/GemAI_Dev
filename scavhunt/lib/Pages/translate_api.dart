import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';

class TranslateApi {
  static final TranslateApi _instance = TranslateApi._internal();
  static bool _initialized = false;

  TranslateApi._internal();

  factory TranslateApi() {
    return _instance;
  }

  static String apiKey = '';

  static Future<void> init() async {
    if (!_initialized) {
      // Load the .env file
      await dotenv.load();

      // Get the API key from the .env file
      apiKey = dotenv.env['TRANSLATE_API'] ?? '';
      if (apiKey.isEmpty) {
        throw Exception('TRANSLATE_API is not set in the .env file');
      }
      _initialized = true;
    }
  }

  static Future<String> translate(String clue, String toLanguage) async {
    await init(); // Ensure init is called

    final encodedClue = Uri.encodeComponent(clue);
    final uri = Uri.parse('https://translation.googleapis.com/language/translate/v2?target=$toLanguage&key=$apiKey&q=$encodedClue');
    final response = await http.post(uri);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final translations = body['data']['translations'] as List;
      final translation = translations.first;
      final translatedText = HtmlUnescape().convert(translation['translatedText']);
      print("Sumanth printing translated text $translatedText");
      return translatedText;
    } else {
      final errorResponse = json.decode(response.body);
      throw Exception('Failed to translate: ${errorResponse['error']['message']}');
    }
  }
}
