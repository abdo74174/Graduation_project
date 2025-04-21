import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/Models/favourite_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesService {
  final Dio _dio = Dio();

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<Response?> addToFavourites(int productId) async {
    final token = await _getToken();

    print("================== REQUEST DEBUG ==================");
    print("Endpoint: ${baseUri}favourites/add");
    print("Token: $token");
    print("Payload: {'productId': $productId}");
    print("===================================================");

    try {
      final response = await _dio.post(
        '${baseUri}favourites/add',
        data: jsonEncode({'productId': productId}),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
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

  Future<Response> removeFromFavourites(int productId) async {
    final token = await _getToken();
    return _dio.delete(
      '${baseUri}favourites/remove/$productId',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }

  Future<Response?> getFavourites() async {
    final token = await _getToken();
    try {
      final response = await _dio.get(
        '${baseUri}favourites/list',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return response; // Return the entire response, not just the data
    } catch (e) {
      print('Error fetching favourites: $e');
      return null; // Handle failure if necessary
    }
  }
}
