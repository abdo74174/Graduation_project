// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:dio/dio.dart';
// ignore: duplicate_shown_name
import 'package:dio/io.dart' show IOHttpClientAdapter, IOHttpClientAdapter;
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/subcateoery_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:path/path.dart' as path;

class CategoryService {
  final Dio dio;

  CategoryService()
      : dio = Dio(BaseOptions(
          baseUrl: baseUri,
        )) {
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  Future<List<CategoryModel>> fetchAllCategories() async {
    List<CategoryModel> categories = [];
    try {
      Response response = await dio.get('Categories');
      if (response.statusCode == 200) {
        final List data = response.data;
        categories = data.map((e) => CategoryModel.fromJson(e)).toList();

        return categories;
      } else {
        throw Exception(
            "Failed to load categories, Status Code: ${response.statusCode}");
      }
    } catch (e) {
      // Enhanced error handling
      if (e is DioException) {
        // DioError handling (for network issues, timeouts, etc.)
        if (e.type == DioExceptionType.connectionTimeout) {
          throw Exception("Connection Timeout. Please check your network.");
        } else if (e.type == DioExceptionType.receiveTimeout) {
          throw Exception(
              "Receive Timeout. The server is taking too long to respond.");
        } else if (e.type == DioExceptionType.unknown) {
          throw Exception("Network error: ${e.message}");
        } else {
          throw Exception("API error: $e");
        }
      } else {
        // General error handling
        throw Exception("An unexpected error occurred: $e");
      }
    }
  }
}
