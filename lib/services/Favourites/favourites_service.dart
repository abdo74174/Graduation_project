import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesService {
  final Dio _dio = Dio();

  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<Response?> addToFavourites(int productId) async {
    final userId = await _getUserId();
    if (userId == null) {
      print("Error: No user ID found in SharedPreferences");
      return null;
    }

    print("================== REQUEST DEBUG ==================");
    print("Endpoint: ${baseUri}favourites/add");
    print("User ID: $userId");
    print("Payload: {'userId': '$userId', 'productId': $productId}");
    print("===================================================");

    try {
      final response = await _dio.post(
        '${baseUri}favourites/add',
        data: jsonEncode({
          'userId': userId,
          'productId': productId,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print("=========== RESPONSE SUCCESS ===========");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");
      print("========================================");

      return response;
    } on DioException catch (e) {
      print("=========== RESPONSE ERROR ===========");
      print("Status Code: ${e.response?.statusCode}");
      print("Error Message: ${e.message}");
      print("Error Data: ${e.response?.data}");
      print("Headers Sent: ${e.requestOptions.headers}");
      print("Request Data: ${e.requestOptions.data}");
      print("======================================");
      return null;
    }
  }

  Future<Response?> removeFromFavourites(int productId) async {
    final userId = await _getUserId();
    if (userId == null) {
      print("Error: No user ID found in SharedPreferences");
      return null;
    }

    print("================== REQUEST DEBUG ==================");
    print("Endpoint: ${baseUri}favourites/remove/$productId");
    print("User ID: $userId");
    print("===================================================");

    try {
      final response = await _dio.delete(
        '${baseUri}favourites/remove/$productId',
        data: jsonEncode({
          'userId': userId,
        }),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print("=========== RESPONSE SUCCESS ===========");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");
      print("========================================");

      return response;
    } on DioException catch (e) {
      print("=========== RESPONSE ERROR ===========");
      print("Status Code: ${e.response?.statusCode}");
      print("Error Message: ${e.message}");
      print("Error Data: ${e.response?.data}");
      print("Headers Sent: ${e.requestOptions.headers}");
      print("Request Data: ${e.requestOptions.data}");
      print("======================================");
      return null;
    }
  }

  Future<Response?> getFavourites() async {
    final userId = await _getUserId();
    if (userId == null) {
      print("Error: No user ID found in SharedPreferences");
      return null;
    }

    print("================== REQUEST DEBUG ==================");
    print("Endpoint: ${baseUri}favourites/list");
    print("User ID: $userId");
    print("===================================================");

    try {
      final response = await _dio.get(
        '${baseUri}favourites/list',
        queryParameters: {
          'userId': userId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print("=========== RESPONSE SUCCESS ===========");
      print("Status Code: ${response.statusCode}");
      print("Response Data: ${response.data}");
      print("========================================");

      return response;
    } on DioException catch (e) {
      print("=========== RESPONSE ERROR ===========");
      print("Status Code: ${e.response?.statusCode}");
      print("Error Message: ${e.message}");
      print("Error Data: ${e.response?.data}");
      print("Headers Sent: ${e.requestOptions.headers}");
      print("Request Data: ${e.requestOptions.data}");
      print("======================================");
      return null;
    }
  }
}
