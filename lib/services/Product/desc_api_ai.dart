import 'package:dio/dio.dart';

class ProductDescriptionService {
  final Dio _dio = Dio();
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';
  static const String _apiKey =
      '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'; // Replace with your API key from https://openrouter.ai

  Future<String> generateDescription({
    required String productName,
    required String category,
    String? subCategory,
  }) async {
    final String prompt = '''
Generate a concise and engaging product description (50-100 words) for a product named "$productName" in the category "$category"${subCategory != null ? ' and subcategory "$subCategory"' : ''}. Highlight its key features, appeal to potential buyers, and use a friendly tone and dont write intro in first .
''';

    try {
      final response = await _dio.post(
        _baseUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_apiKey',
            'Content-Type': 'application/json',
            'HTTP-Referer':
                'https://yourapp.com', // Replace with your app's URL
            'X-Title': 'Product Description Generator',
          },
        ),
        data: {
          "model": "openai/gpt-3.5-turbo",
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "temperature": 0.7,
        },
      );

      return response.data['choices'][0]['message']['content'].trim();
    } catch (e) {
      throw Exception("Failed to generate description: $e");
    }
  }
}
