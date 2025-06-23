import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart' show IOHttpClientAdapter;
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

  Future<ProductModel?> fetchProductId(int productId) async {
    try {
      Response response = await dio.get('Product/$productId');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Log the type of data
        print("🔍 fetchProductId: type = ${data.runtimeType}");
        print("📦 fetchProductId: data = $data");

        if (data is Map<String, dynamic>) {
          return ProductModel.fromJson(data);
        }

        if (data is List && data.isNotEmpty) {
          print(
              "⚠️ Warning: Unexpected List response from single product API.");
          return ProductModel.fromJson(data[0] as Map<String, dynamic>);
        }

        if (data is Map && data.containsKey('data')) {
          return ProductModel.fromJson(data['data'] as Map<String, dynamic>);
        }

        return null;
      } else {
        print("❌ Failed to fetch product. Status code: ${response.statusCode}");
        return null;
      }
    } catch (e, stackTrace) {
      print("❌ fetchProductId error: $e\n$stackTrace");
      return null;
    }
  }

  Future<void> addProduct({
    required String userId,
    required String name,
    required bool donation,
    required String address,
    required String description,
    required double price,
    required double comparePrice,
    required double discount,
    required String status,
    required double guarantee,
    required int categoryId,
    required int subCategoryId,
    required int stockQuantity,
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
        throw Exception('Invalid category-subcategory combination. '
            'Subcategory "${matchingSubCategory.name}" belongs to category ID ${matchingSubCategory.categoryId}, '
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
        'Donation': donation,
        'Address': address,
        'Discount': discount,
        'Guarantee': guarantee,
        'CategoryId': categoryId,
        'SubCategoryId': subCategoryId,
        'StockQuantity': stockQuantity,
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
        rethrow;
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

  Future<void> updateProduct({
    required int productId,
    required String userId,
    required String name,
    required bool donation,
    required String address,
    required String description,
    required double price,
    required double discount,
    required double guarantee,
    required int categoryId,
    required int subCategoryId,
    required bool isNew,
    required bool installmentAvailable,
    required List<File>? imageFiles, // Nullable to allow updates without images
  }) async {
    if (name.isEmpty || description.isEmpty) {
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

      // Validate image extensions if images are provided
      if (imageFiles != null && imageFiles.isNotEmpty) {
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
        throw Exception('Invalid category-subcategory combination. '
            'Subcategory "${matchingSubCategory.name}" belongs to category ID ${matchingSubCategory.categoryId}, '
            'not to category ID $categoryId');
      }

      print('✅ Category-Subcategory validation successful');

      // Prepare FormData for the update
      FormData formData = FormData.fromMap({
        'UserId': parsedUserId,
        'Name': name,
        'Description': description,
        'Price': price,
        'Discount': discount,
        'Guarantee': guarantee,
        'CategoryId': categoryId,
        'SubCategoryId': subCategoryId,
        'Donation': donation,
        'Address': address,
        'IsNew': isNew,
        'InstallmentAvailable': installmentAvailable,
        if (imageFiles != null && imageFiles.isNotEmpty)
          'Images': await Future.wait(imageFiles.map((file) async {
            String extension = path.extension(file.path).toLowerCase();
            return await MultipartFile.fromFile(file.path,
                filename: '${DateTime.now().millisecondsSinceEpoch}$extension');
          })),
      });

      print('📤 Sending update product data:');
      print('Product ID: $productId');
      print('Category ID: $categoryId');
      print('Subcategory ID: $subCategoryId');
      print('Price: $price');
      print('Discount: $discount');

      Response response = await dio.put('Product/$productId', data: formData);

      if (response.statusCode == 200) {
        print('✅ Product updated successfully!');
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        print('Response: ${response.data}');
        throw Exception(
            response.data?.toString() ?? 'Failed to update product');
      }
    } catch (e) {
      if (e is DioException) {
        print('❌ Dio error: ${e.message}');
        print('📦 Status Code: ${e.response?.statusCode}');
        print('📩 Response Body: ${e.response?.data}');
        throw Exception(e.response?.data?.toString() ?? e.message);
      } else {
        print('❌ Error: $e');
        rethrow;
      }
    }
  }

  Future<void> updateProductStock(int productId, int newStockQuantity) async {
    try {
      // First, fetch the existing product to get all current data
      Response getResponse = await dio.get('Product/$productId');
      if (getResponse.statusCode != 200) {
        print(
            '❌ Failed to fetch product for stock update. Status: ${getResponse.statusCode}');
        throw Exception('Failed to fetch product for stock update');
      }

      final productData = getResponse.data;
      if (productData == null) {
        throw Exception('Product data not found');
      }

      // Prepare FormData with existing product data, updating only stock quantity
      FormData formData = FormData.fromMap({
        'UserId': productData['userId'],
        'Name': productData['name'],
        'Description': productData['description'],
        'Price': productData['price'],
        'Discount': productData['discount'],
        'Guarantee': productData['guarantee'],
        'CategoryId': productData['categoryId'],
        'SubCategoryId': productData['subCategoryId'],
        'Donation': productData['donation'],
        'Address': productData['address'],
        'IsNew': productData['isNew'],
        'InstallmentAvailable': productData['installmentAvailable'],
        'StockQuantity': newStockQuantity,
        // Note: Not including Images to avoid overwriting existing images
      });

      print('📤 Updating product stock:');
      print('Product ID: $productId');
      print('New Stock Quantity: $newStockQuantity');

      Response response = await dio.put('Product/$productId', data: formData);

      if (response.statusCode == 200) {
        print('✅ Product stock updated successfully!');
      } else {
        print('❌ Failed with status: ${response.statusCode}');
        print('Response: ${response.data}');
        throw Exception(
            response.data?.toString() ?? 'Failed to update product stock');
      }
    } catch (e) {
      if (e is DioException) {
        print('❌ Dio error: ${e.message}');
        print('📦 Status Code: ${e.response?.statusCode}');
        print('📩 Response Body: ${e.response?.data}');
        throw Exception(e.response?.data?.toString() ?? e.message);
      } else {
        print('❌ Error: $e');
        rethrow;
      }
    }
  }
}
