import 'dart:convert';
import 'package:http/http.dart' as http;

class Rec {
  Future<List<Map<String, dynamic>>> getRecommendationsForUser(
      int userId, List<Map<String, String>> interactions) async {
    final url = Uri.parse(
        'https://27adf240-d62c-4499-9fb8-8ac31265ddd2-00-1qy73lvby6rjw.sisko.replit.dev/recommend');

    // Send POST request
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'UserID': userId,
        'interactions': interactions,
      }),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(result['recommendations']);
    } else {
      throw Exception('Failed to get recommendations');
    }
  }
}
