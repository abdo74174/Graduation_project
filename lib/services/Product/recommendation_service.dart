import 'package:dio/dio.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'dart:developer' as developer;

import 'package:graduation_project/core/constants/constant.dart';

class RecommendationService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUri, // ASP.NET Core API
    validateStatus: (status) => status! < 500,
  ));

  // Debug flag to enable/disable detailed logging
  final bool _debugMode = true;

  void _logDebug(String message, {Object? error, StackTrace? stackTrace}) {
    if (_debugMode) {
      developer.log(
        message,
        name: 'RecommendationService',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<ProductModel>> fetchRecommendations(int productId,
      {int topN = 5}) async {
    _logDebug(
        'Fetching recommendations for productId: $productId, topN: $topN');

    try {
      _logDebug('Making API request...');
      final response = await _dio.get(
        'product/recommend',
        queryParameters: {
          'productId': productId,
          'topN': topN,
        },
      );

      _logDebug('API Response received:');
      _logDebug('Request URL: ${response.requestOptions.uri}');
      _logDebug('Response Status: ${response.statusCode}');
      _logDebug('Response Headers: ${response.headers}');
      _logDebug('Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == 'success') {
          _logDebug('Successfully received recommendations data');

          final recommendations =
              (data['recommendations'] as List).where((item) {
            if (item['productId'] == null) {
              _logDebug('⚠️ Invalid item detected - null productId',
                  error: item);
              return false;
            }
            return true;
          }).map((item) {
            // Detailed field validation logging
            _validateProductFields(item);

            try {
              return ProductModel.fromJson(item);
            } catch (e, stackTrace) {
              _logDebug(
                '❌ Error parsing product data',
                error: e,
                stackTrace: stackTrace,
              );
              rethrow;
            }
          }).toList();

          _logDebug('Returning ${recommendations.length} recommendations');
          return recommendations;
        } else {
          throw Exception('API Error: ${data['message']}');
        }
      } else {
        throw Exception(
            'Failed to load recommendations: ${response.statusCode}\nResponse: ${response.data}');
      }
    } catch (e, stackTrace) {
      _logDebug(
        '❌ Error in fetchRecommendations',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  void _validateProductFields(Map<String, dynamic> item) {
    final productId = item['productId'];
    final requiredFields = {
      'categoryId': item['categoryId'],
      'subCategoryId': item['subCategoryId'],
      'stockQuantity': item['stockQuantity'],
      'userId': item['userId'],
    };

    requiredFields.forEach((field, value) {
      if (value == null) {
        _logDebug(
          '⚠️ Missing required field: $field for product $productId',
          error: {'field': field, 'productData': item},
        );
      }
    });

    // Validate data types
    if (item['stockQuantity'] != null && item['stockQuantity'] is! int) {
      _logDebug(
        '⚠️ Invalid data type for stockQuantity',
        error: {
          'expected': 'int',
          'received': item['stockQuantity'].runtimeType
        },
      );
    }
  }
}
