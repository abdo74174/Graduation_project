import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:graduation_project/Models/category_model.dart';
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
        throw Exception('Failed to fetch categories: ${response.data}');
      }
    } catch (e) {
      print('❌ Error fetching categories: $e');
      throw Exception('Failed to fetch categories: $e');
    }
  }

  Future<CategoryModel?> fetchCategoryById(int id) async {
    try {
      print('🔍 Fetching category by ID: $id');
      final response = await dio.get('Categories/$id');
      if (response.statusCode == 200) {
        print('✅ Category fetched successfully');
        return CategoryModel.fromJson(response.data);
      } else if (response.statusCode == 404) {
        print('❌ Category not found: $id');
        return null;
      } else {
        print('❌ Failed to fetch category: ${response.statusCode}');
        throw Exception('Failed to fetch category');
      }
    } catch (e) {
      print('❌ Error fetching category by ID: $e');
      throw Exception('Failed to fetch category: $e');
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
          filename: path.basename(imageFile.path),
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

  Future<void> updateCategory({
    required int id,
    required String name,
    required String description,
    File? imageFile,
  }) async {
    try {
      print('📝 Updating category: $id with name: $name');
      Map<String, dynamic> formDataMap = {
        'Name': name,
        'Description': description,
      };
      if (imageFile != null) {
        print('📷 Including new image in update');
        formDataMap['Image'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: path.basename(imageFile.path),
        );
      }
      final formData = FormData.fromMap(formDataMap);
      final response = await dio.put('Categories/$id', data: formData);
      if (response.statusCode == 200) {
        print('✅ Category updated successfully');
      } else {
        print('❌ Failed to update category: ${response.statusCode}');
        throw Exception('Failed to update category: ${response.data}');
      }
    } catch (e) {
      print('❌ Error updating category: $e');
      if (e is DioException) {
        print('❌ DioException details:');
        print('❌ Status: ${e.response?.statusCode}');
        print('❌ Data: ${e.response?.data}');
        if (e.response?.statusCode == 400) {
          final errorMessage = e.response?.data?.toString() ?? 'Bad request';
          throw Exception('Update failed: $errorMessage');
        } else if (e.response?.statusCode == 404) {
          throw Exception('Category not found');
        } else if (e.response?.statusCode == 403) {
          throw Exception('Access denied');
        }
      }
      throw Exception('Failed to update category: $e');
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
        throw Exception('Failed to delete category: ${response.data}');
      }
    } catch (e) {
      print('❌ Error deleting category: $e');
      if (e is DioException) {
        print('❌ DioException details:');
        print('❌ Status: ${e.response?.statusCode}');
        print('❌ Data: ${e.response?.data}');
        if (e.response?.statusCode == 400) {
          final errorMessage =
              e.response?.data?.toString() ?? 'Cannot delete category';
          throw Exception(errorMessage);
        } else if (e.response?.statusCode == 404) {
          throw Exception('Category not found');
        } else if (e.response?.statusCode == 403) {
          throw Exception('Access denied');
        }
      }
      throw Exception('Failed to delete category: $e');
    }
  }
}
