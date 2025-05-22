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
          validateStatus: (status) => status! < 500,
        )) {
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  Future<List<CategoryModel>> fetchAllCategories() async {
    try {
      print('🔍 Fetching all categories...');
      final response = await dio.get('Categories');

      if (response.statusCode == 200) {
        final List data = response.data;
        final categories =
            data.map((item) => CategoryModel.fromJson(item)).toList();
        print('✅ Fetched ${categories.length} categories');
        return categories;
      } else {
        print('❌ Failed to fetch categories: ${response.statusCode}');
        throw Exception('Failed to fetch categories');
      }
    } catch (e) {
      print('❌ Error fetching categories: $e');
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<void> addCategory({
    required String name,
    required String description,
    required File imageFile,
  }) async {
    try {
      print('📤 Adding new category: $name');
      final formData = FormData.fromMap({
        'Name': name,
        'Description': description,
        'Image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await dio.post('Categories', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Category added successfully');
      } else {
        print('❌ Failed to add category: ${response.statusCode}');
        throw Exception('Failed to add category: ${response.data}');
      }
    } catch (e) {
      print('❌ Error adding category: $e');
      throw Exception('Failed to add category: $e');
    }
  }

  Future<void> deleteCategory(int categoryId) async {
    try {
      print('🗑️ Deleting category: $categoryId');
      final response = await dio.delete('Categories/$categoryId');

      if (response.statusCode == 200) {
        print('✅ Category deleted successfully');
      } else {
        print('❌ Failed to delete category: ${response.statusCode}');
        throw Exception('Failed to delete category');
      }
    } catch (e) {
      print('❌ Error deleting category: $e');
      throw Exception('Failed to delete category: $e');
    }
  }
}
