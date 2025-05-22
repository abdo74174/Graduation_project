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
          validateStatus: (status) => status! < 500,
        )) {
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  Future<List<SubCategory>> fetchAllSubCategories() async {
    try {
      print('🔍 Fetching all subcategories...');
      final response = await dio.get('Subcategories');

      if (response.statusCode == 200) {
        final List data = response.data;
        final subcategories =
            data.map((item) => SubCategory.fromJson(item)).toList();
        print('✅ Fetched ${subcategories.length} subcategories');
        return subcategories;
      } else {
        print('❌ Failed to fetch subcategories: ${response.statusCode}');
        throw Exception('Failed to fetch subcategories');
      }
    } catch (e) {
      print('❌ Error fetching subcategories: $e');
      throw Exception('Failed to fetch subcategories: $e');
    }
  }

  Future<List<SubCategory>> fetchSubCategoriesByCategory(int categoryId) async {
    try {
      // Try different endpoint formats
      final endpoints = [
        'Subcategories/ByCategoryId/$categoryId',
        'Subcategories/Category/$categoryId',
        'Subcategories/GetByCategory/$categoryId',
        'Subcategories?categoryId=$categoryId'
      ];

      DioException? lastError;

      for (final endpoint in endpoints) {
        try {
          print('🔍 Trying endpoint: ${dio.options.baseUrl}$endpoint');

          final response = await dio.get(endpoint);
          print('📥 Response Status: ${response.statusCode}');
          print('📦 Response Data: ${response.data}');

          if (response.statusCode == 200) {
            final List data = response.data;
            final subcategories =
                data.map((item) => SubCategory.fromJson(item)).toList();
            print(
                '✅ Successfully fetched ${subcategories.length} subcategories');
            return subcategories;
          }
        } catch (e) {
          if (e is DioException) {
            lastError = e;
            print('❌ Endpoint $endpoint failed:');
            print('❌ Status: ${e.response?.statusCode}');
            print('❌ Data: ${e.response?.data}');
          }
          continue;
        }
      }

      // If we get here, none of the endpoints worked
      if (lastError != null) {
        print('❌ All endpoints failed. Last error:');
        print('❌ Type: ${lastError.type}');
        print('❌ Message: ${lastError.message}');
        print('❌ Path: ${lastError.requestOptions.path}');
        print('❌ Status: ${lastError.response?.statusCode}');
        print('❌ Data: ${lastError.response?.data}');
      }

      throw Exception('Failed to fetch subcategories for category');
    } catch (e) {
      print('❌ Error fetching subcategories: $e');
      throw Exception('Failed to fetch subcategories: $e');
    }
  }

  Future<void> addSubCategory({
    required String name,
    required String description,
    required int categoryId,
    required File imageFile,
  }) async {
    try {
      print('📤 Adding new subcategory: $name for category $categoryId');
      final formData = FormData.fromMap({
        'Name': name,
        'Description': description,
        'CategoryId': categoryId,
        'Image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await dio.post('Subcategories', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Subcategory added successfully');
      } else {
        print('❌ Failed to add subcategory: ${response.statusCode}');
        throw Exception('Failed to add subcategory: ${response.data}');
      }
    } catch (e) {
      print('❌ Error adding subcategory: $e');
      throw Exception('Failed to add subcategory: $e');
    }
  }

  Future<void> deleteSubCategory(int subCategoryId) async {
    try {
      print('🗑️ Deleting subcategory: $subCategoryId');
      final response = await dio.delete('Subcategories/$subCategoryId');

      if (response.statusCode == 200) {
        print('✅ Subcategory deleted successfully');
      } else {
        print('❌ Failed to delete subcategory: ${response.statusCode}');
        throw Exception('Failed to delete subcategory');
      }
    } catch (e) {
      print('❌ Error deleting subcategory: $e');
      throw Exception('Failed to delete subcategory: $e');
    }
  }
}
