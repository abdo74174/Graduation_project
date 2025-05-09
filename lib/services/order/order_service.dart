import 'package:dio/dio.dart';
import 'package:graduation_project/Models/order_model.dart';

class OrderService {
  static const String _baseUrl = 'https://10.0.2.2:7273/api/Order/create';
  final Dio _dio = Dio();

  Future<int> createOrder(int userId, List<Map<String, dynamic>> items) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/create',
        data: {
          'userId': userId,
          'items': items
              .map((item) => {
                    'productId': item['productId'],
                    'quantity': item['quantity'],
                  })
              .toList(),
        },
      );

      if (response.statusCode == 200) {
        return response.data['orderId'];
      } else {
        throw Exception('Failed to create order: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<List<OrderModel>> getAllOrders(int userId) async {
    try {
      final response = await _dio.get('$_baseUrl');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch orders: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<void> deleteOrder(int orderId) async {
    try {
      final response = await _dio.delete('$_baseUrl/$orderId');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete order: ${response.data}');
      }
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }
}
