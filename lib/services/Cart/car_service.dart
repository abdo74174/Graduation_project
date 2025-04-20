import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:graduation_project/Models/cart_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/core/constants/constant.dart';

class CartService {
  final Dio dio = Dio();

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<CartModel> getCart() async {
    final token = await _getToken();
    print(token);
    try {
      final rsp = await dio.get(
        '${baseUri}cart',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Debugging: Print the response data
      // print("Response Status Code: ${rsp.statusCode}");
      // print("Response Data: ${rsp.data}");

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
    final token = await _getToken();

    try {
      final formData = FormData.fromMap({
        'productId': productId,
        'quantity': quantity,
      });

      print("🔄 Sending addToCart request...");
      print("📦 productId: $productId, quantity: $quantity");
      print("🔐 token: $token");

      final response = await dio.post(
        '${baseUri}cart/add',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
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
    final token = await _getToken();

    try {
      final response = await dio.put(
        '${baseUri}cart/update',
        data: {
          'productId': productId,
          'quantity': quantity,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
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
    final token = await _getToken();

    try {
      final response = await dio.delete(
        '${baseUri}cart/delete/$productId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting product from cart: $e');
      return false;
    }
  }

  Future<bool> clearCart() async {
    final token = await _getToken();

    try {
      final response = await dio.delete(
        '$baseUri/cart/clear',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error clearing cart: $e');
      return false;
    }
  }
}
