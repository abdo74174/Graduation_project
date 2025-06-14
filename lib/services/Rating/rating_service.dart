import 'package:graduation_project/core/constants/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RatingService {
  static final String baseUrl = '${baseUri}ratings';

  Future<void> submitRating({
    required String productId,
    required String userId,
    required int rating,
    String? comment,
  }) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'productId': productId,
        'userId': userId,
        'ratingValue': rating,
        'comment': comment ?? '',
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to submit rating: ${response.body}');
    }
  }

  Future<List<dynamic>> getRatings({String? productId}) async {
    final uri = productId != null
        ? Uri.parse('$baseUrl?productId=$productId')
        : Uri.parse(baseUrl);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load ratings: ${response.body}');
    }
  }
}
