import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart' show IOHttpClientAdapter;
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/Product/subcategory_service.dart';
import 'package:path/path.dart' as path;

class ProductService {
  final Dio dio;

  ProductService()
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

  Future<List<ProductModel>> fetchAllProducts() async {
    try {
      print('🌐 Making API request to: ${dio.options.baseUrl}Product');
      Response response = await dio.get('Product');
      print('✅ API Response Status: ${response.statusCode}');
      print('📦 API Response Data: ${response.data}');

      if (response.statusCode == 200) {
        List data = response.data;
        List<ProductModel> products =
            data.map((item) => ProductModel.fromJson(item)).toList();
        print('📥 Parsed ${products.length} products');
        return products;
      } else {
        print('❌ Failed to load products: ${response.statusCode}');
        throw Exception("Failed to load products");
      }
    } catch (e, stackTrace) {
      print('❌ API error: $e');
      print('Stack trace: $stackTrace');
      throw Exception("API error: $e");
    }
  }

  Future<void> addProduct({
    required String userId,
    required String name,
    required String description,
    required double price,
    required double comparePrice,
    required double discount,
    required String status,
    required int categoryId,
    required int subCategoryId,
    required int StockQuantity,
    required List<File> imageFiles,
  }) async {
    if (name.isEmpty || description.isEmpty || imageFiles.isEmpty) {
      throw Exception('Please fill all required fields.');
    }

    if (userId.isEmpty) {
      throw Exception('User ID is required.');
    }

    try {
      int parsedUserId;
      try {
        parsedUserId = int.parse(userId);
      } catch (e) {
        throw Exception('Invalid user ID format');
      }

      // Validate image extensions
      const allowedExtensions = [
        '.jpg',
        '.jpeg',
        '.png',
        '.gif',
        '.bmp',
        '.webp',
        '.tiff',
        '.tif',
        '.svg',
        '.ico',
        '.heif'
      ];
      final invalidFiles = imageFiles.where((file) {
        final extension = path.extension(file.path).toLowerCase();
        return !allowedExtensions.contains(extension);
      }).toList();

      if (invalidFiles.isNotEmpty) {
        throw Exception(
            'Invalid file extensions: ${invalidFiles.map((file) => path.extension(file.path)).join(', ')}');
      }

      // Validate subcategory belongs to the selected category
      final subCategoryService = SubCategoryService();
      print(
          '🔍 Fetching subcategories to validate category-subcategory relationship...');
      print(
          '📝 Validating: CategoryId=$categoryId, SubCategoryId=$subCategoryId');

      final subCategories = await subCategoryService.fetchAllSubCategories();
      print('✅ Fetched ${subCategories.length} subcategories');

      // Find the specific subcategory
      final matchingSubCategory = subCategories.firstWhere(
        (subCategory) => subCategory.subCategoryId == subCategoryId,
        orElse: () =>
            throw Exception('Subcategory with ID $subCategoryId not found'),
      );

      // Validate category match
      if (matchingSubCategory.categoryId != categoryId) {
        print('❌ Category mismatch:');
        print('   Expected categoryId: ${matchingSubCategory.categoryId}');
        print('   Provided categoryId: $categoryId');
        throw Exception('Invalid category-subcategory combination. ' +
            'Subcategory "${matchingSubCategory.name}" belongs to category ID ${matchingSubCategory.categoryId}, ' +
            'not to category ID $categoryId');
      }

      print('✅ Category-Subcategory validation successful');

      // Prepare the FormData with images and their extensions
      FormData formData = FormData.fromMap({
        'UserId': parsedUserId,
        'Name': name,
        'Description': description,
        'Price': price,
        'ComparePrice': comparePrice,
        'Status': status,
        'Discount': discount,
        'CategoryId': categoryId,
        'SubCategoryId': subCategoryId,
        'StockQuantity': StockQuantity,
        'Images': await Future.wait(imageFiles.map((file) async {
          String extension = path.extension(file.path).toLowerCase();
          return await MultipartFile.fromFile(file.path,
              filename: '${DateTime.now().millisecondsSinceEpoch}$extension');
        })),
      });

      print('📤 Sending product data:');
      print('Category ID: $categoryId');
      print('Subcategory ID: $subCategoryId');
      print('Status: $status');
      print('Price: $price');
      print('Compare Price: $comparePrice');

      Response response = await dio.post('Product', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(
            "ggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg");
        print(response.data);
        print(userId);
        print('✅ Product added successfully!');
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        print('Response: ${response.data}');
        throw Exception(response.data?.toString() ?? 'Failed to add product');
      }
    } catch (e) {
      if (e is DioException) {
        print('❌ Dio error: ${e.message}');
        print('📦 Status Code: ${e.response?.statusCode}');
        print('📩 Response Body: ${e.response?.data}');
        throw Exception(e.response?.data?.toString() ?? e.message);
      } else {
        print('❌ Error: $e');
        throw e;
      }
    }
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      Response response = await dio.delete('Product/$productId');

      if (response.statusCode == 200) {
        print('✅ Product deleted successfully!');
        return true;
      } else {
        print('❌ Failed to delete product. Status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      if (e is DioException) {
        print('❌ Dio error: ${e.message}');
        print('📦 Status Code: ${e.response?.statusCode}');
        print('📩 Response Body: ${e.response?.data}');
      } else {
        print('❌ Unknown error: $e');
      }
      return false;
    }
  }
}
