import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart' show IOHttpClientAdapter;
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/subcateoery_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:path/path.dart' as path;

class SubCategoryService {
  final Dio dio;

  SubCategoryService()
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

  Future<List<SubCategory>> fetchAllSubCategories() async {
    List<SubCategory> subcategories = [];
    try {
      Response response = await dio.get('Subcategories');
      if (response.statusCode == 200) {
        final List data = response.data;
        subcategories = data
            .map((e) => SubCategory.fromJson(e))
            .toList(); // Ensure correct mapping
        return subcategories;
      } else {
        throw Exception("Failed to load Subcategories");
      }
    } catch (e) {
      throw Exception("API error: $e");
    }
  }
}
