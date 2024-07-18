import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ImageDownloader {
  final String apiKey;

  ImageDownloader(this.apiKey);

  Future<List<String>> fetchImageUrls(String query) async {
    final url = 'https://api.gemini.com/v1/images/search?query=$query&apiKey=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<String>.from(data['results'].map((item) => item['url']));
    } else {
      throw Exception('Failed to load image URLs');
    }
  }

  Future<void> downloadImage(String url, String filename) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final file = File(filename);
      await file.writeAsBytes(response.bodyBytes);
      print('Downloaded $filename');
    } else {
      print('Failed to download $filename');
    }
  }

  Future<void> downloadImages(String query) async {
    final images = await fetchImageUrls(query);
    for (var i = 0; i < images.length; i++) {
      final imageUrl = images[i];
      await downloadImage(imageUrl, 'image_$i.jpg');
    }
  }
}
