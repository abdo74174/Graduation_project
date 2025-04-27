import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart' show IOHttpClientAdapter;
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:path/path.dart' as path;

class ProductService {
  final Dio dio;

  ProductService()
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

  Future<List<ProductModel>> fetchAllProducts() async {
    try {
      Response response = await dio.get('Product');

      if (response.statusCode == 200) {
        List data = response.data;
        List<ProductModel> products =
            data.map((item) => ProductModel.fromJson(item)).toList();

        return products;
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
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
    // ignore: non_constant_identifier_names
    required int StockQuantity,
    required List<File> imageFiles,
  }) async {
    if (name.isEmpty || description.isEmpty || imageFiles.isEmpty) {
      print('Please fill all required fields.');
      return;
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
      print(
          '❌ Invalid file extensions: ${invalidFiles.map((file) => path.extension(file.path)).join(', ')}');
      return; // Stop further processing if invalid files are found
    }

    try {
      // Prepare the FormData with images and their extensions
      FormData formData = FormData.fromMap({
        'UserId': int.parse(userId),
        'Name': name,
        'Description': description,
        'Price': price,
        'IsNew': true, // Or false depending on your logic
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

      Response response = await dio.post('Product', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Product added successfully!');
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        print('Response: ${response.data}');
      }
    } catch (e) {
      if (e is DioException) {
        print('❌ Dio error: ${e.message}');
        print('📦 Status Code: ${e.response?.statusCode}');
        print('📩 Response Body: ${e.response?.data}');
      } else {
        print('❌ Unknown error: $e');
      }
    }
  }
}
