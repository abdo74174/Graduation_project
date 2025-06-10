import 'package:dio/dio.dart';
import 'package:graduation_project/Models/order_model.dart';

class OrderService {
  static const String _baseUrl = 'https://10.0.2.2:7273/api/Order';
  final Dio _dio;

  OrderService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          validateStatus: (status) {
            return status != null && status < 500;
          },
        )) {
    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<int> createOrder(int userId, List<Map<String, dynamic>> items) async {
    try {
      print('Creating order for userId: $userId');
      print('Items: $items');

      // Validate input
      if (userId <= 0) {
        print('Error: Invalid userId: $userId');
        throw Exception('Invalid userId: $userId');
      }
      if (items.isEmpty) {
        print('Error: Items list is empty');
        throw Exception('Items list cannot be empty');
      }

      final formattedItems = items.map((item) {
        if (!item.containsKey('productId') || !item.containsKey('quantity')) {
          print('Error: Invalid item format: $item');
          throw Exception('Invalid item format: $item');
        }
        return {
          'productId': item['productId'],
          'quantity': item['quantity'],
        };
      }).toList();

      print('Sending POST request to $_baseUrl/create');
      final response = await _dio.post(
        '$_baseUrl/create',
        data: {
          'userId': userId,
          'items': formattedItems,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['orderId'] != null) {
          final orderId = response.data['orderId'] as int;
          print('Order created successfully with ID: $orderId');
          return orderId;
        } else {
          print('Error: orderId not found in response');
          throw Exception('orderId not found in response');
        }
      } else {
        print('Failed to create order. Status: ${response.statusCode}');
        print('Response data: ${response.data}');
        throw Exception('Failed to create order: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioError(e, 'createOrder');
      rethrow;
    } catch (e) {
      print('Unexpected error in createOrder: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  Future<List<OrderModel>> getAllOrders() async {
    try {
      print('Sending GET request to $_baseUrl');
      final response = await _dio.get('$_baseUrl');

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final List<dynamic> data = response.data;
          final orders = data.map((json) {
            try {
              return OrderModel.fromJson(json);
            } catch (e) {
              print('Error parsing order JSON: $json');
              print('Parsing error: $e');
              throw Exception('Failed to parse order: $e');
            }
          }).toList();

          print('Successfully fetched ${orders.length} orders');
          return orders;
        } else {
          print('Error: Response data is not a list');
          throw Exception('Invalid response format: Expected a list');
        }
      } else {
        print('Failed to fetch orders. Status: ${response.statusCode}');
        print('Response data: ${response.data}');
        throw Exception('Failed to fetch orders: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioError(e, 'getAllOrders');
      rethrow;
    } catch (e) {
      print('Unexpected error in getAllOrders: $e');
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<void> deleteOrder(int orderId) async {
    try {
      print('Deleting order with ID: $orderId');

      if (orderId <= 0) {
        print('Error: Invalid orderId: $orderId');
        throw Exception('Invalid orderId: $orderId');
      }

      print('Sending DELETE request to $_baseUrl/$orderId');
      final response = await _dio.delete('$_baseUrl/$orderId');

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Order $orderId deleted successfully');
      } else {
        print('Failed to delete order. Status: ${response.statusCode}');
        print('Response data: ${response.data}');
        throw Exception('Failed to delete order: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioError(e, 'deleteOrder');
      rethrow;
    } catch (e) {
      print('Unexpected error in deleteOrder: $e');
      throw Exception('Failed to delete order: $e');
    }
  }

  void _handleDioError(DioException e, String methodName) {
    print('DioException in $methodName:');
    print('Error type: ${e.type}');
    print('Error message: ${e.message}');
    if (e.response != null) {
      print('Response status: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
    }
    if (e.error != null) {
      print('Underlying error: ${e.error}');
    }
    throw Exception('Network error in $methodName: ${e.message}');
  }
}
