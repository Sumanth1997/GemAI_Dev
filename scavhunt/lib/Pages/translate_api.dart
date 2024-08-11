import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      // Fetch the API key from Firestore
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('apikeys').doc('translation').get();
      if (doc.exists) {
        apiKey = doc.data()?['apikey'] as String;
      } else {
        throw Exception('API key not found in Firestore');
      }

      if (apiKey.isEmpty) {
        throw Exception('API_KEY is not set in Firestore');
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
