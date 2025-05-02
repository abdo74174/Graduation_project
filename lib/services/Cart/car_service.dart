import 'package:dio/dio.dart';
import 'package:graduation_project/Models/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/core/constants/constant.dart';

class CartService {
  final Dio dio = Dio();

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';
    if (userId.isEmpty) {
      print('Error: user_id not found in SharedPreferences');
      throw Exception('User ID not found');
    }
    return userId;
  }

  Future<CartModel> getCart() async {
    final userId = await _getUserId();
    print('Fetching cart for user_id: $userId');
    try {
      final rsp = await dio.get(
        '${baseUri}cart',
        options: Options(headers: {'X-User-Id': userId}),
      );

      print("Response Status Code: ${rsp.statusCode}");
      print("Response Data: ${rsp.data}");

      if (rsp.statusCode == 200) {
        return CartModel.fromJson(rsp.data as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load cart (${rsp.statusCode})');
      }
    } catch (e) {
      print('Error fetching cart: $e');
      throw Exception('Error loading cart: $e');
    }
  }

  Future<bool> addToCart(int productId, int quantity) async {
    final userId = await _getUserId();
    print('Adding to cart for user_id: $userId');

    try {
      final formData = FormData.fromMap({
        'productId': productId,
        'quantity': quantity,
      });

      print("🔄 Sending addToCart request...");
      print("📦 productId: $productId, quantity: $quantity");
      print("🆔 user_id: $userId");

      final response = await dio.post(
        '${baseUri}cart/add',
        data: formData,
        options: Options(
          headers: {
            'X-User-Id': userId,
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print("✅ Status Code: ${response.statusCode}");
      print("📨 Response Data: ${response.data}");

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error adding product to cart: $e');
      return false;
    }
  }

  Future<bool> updateCartItem(int productId, int quantity) async {
    final userId = await _getUserId();
    print('Updating cart for user_id: $userId');

    try {
      final response = await dio.put(
        '${baseUri}cart/update',
        data: {
          'productId': productId,
          'quantity': quantity,
        },
        options: Options(
          headers: {
            'X-User-Id': userId,
            'Content-Type': 'application/json',
          },
        ),
      );

      print(
          '✅ Update Cart Response: ${response.statusCode} - ${response.data}');
      return response.statusCode == 200;
    } on DioException catch (dioError) {
      if (dioError.response != null) {
        print('❌ DioException - Status Code: ${dioError.response?.statusCode}');
        print('❌ Response Data: ${dioError.response?.data}');
        print('❌ Headers: ${dioError.response?.headers}');
      } else {
        print('❌ DioException without response: ${dioError.message}');
      }
      return false;
    } catch (e) {
      print('❌ General error in updateCartItem: $e');
      return false;
    }
  }

  Future<bool> deleteFromCart(int productId) async {
    final userId = await _getUserId();
    print('Deleting from cart for user_id: $userId');

    try {
      final response = await dio.delete(
        '${baseUri}cart/delete/$productId',
        options: Options(
          headers: {'X-User-Id': userId},
        ),
      );

      print(
          '✅ Delete Cart Response: ${response.statusCode} - ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error deleting product from cart: $e');
      return false;
    }
  }

  Future<bool> clearCart() async {
    final userId = await _getUserId();
    print('Clearing cart for user_id: $userId');

    try {
      final response = await dio.delete(
        '${baseUri}cart/clear',
        options: Options(
          headers: {'X-User-Id': userId},
        ),
      );

      print('✅ Clear Cart Response: ${response.statusCode} - ${response.data}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error clearing cart: $e');
      return false;
    }
  }
}
