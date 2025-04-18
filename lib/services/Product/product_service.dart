import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart' show DefaultHttpClientAdapter;
import 'package:path/path.dart' as path;

class ProductService {
  final Dio dio;

  ProductService()
      : dio = Dio(BaseOptions(
          baseUrl: 'https://10.0.2.2:7273/api/',
        )) {
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
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
