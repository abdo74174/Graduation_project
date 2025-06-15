import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:graduation_project/Models/order_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/admin_dashboard.dart';

class OrderService {
  static final String _baseUrl = '${baseUri}Order';
  final Dio _dio;

  OrderService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
          validateStatus: (status) => status != null && status < 500,
        )) {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
  }

  Future<int> createOrder(
      int userId, List<Map<String, dynamic>> items, String address) async {
    try {
      if (userId <= 0) throw Exception('Invalid userId: $userId');
      if (items.isEmpty) throw Exception('Items list cannot be empty');

      final formattedItems = items.map((item) {
        if (!item.containsKey('productId') || !item.containsKey('quantity')) {
          throw Exception('Invalid item format: $item');
        }
        return {
          'productId': item['productId'],
          'quantity': item['quantity'],
        };
      }).toList();

      final response = await _dio.post(
        '$_baseUrl/create',
        data: {
          'userId': userId,
          'items': formattedItems,
          "address": address,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['orderId'] != null) {
          return response.data['orderId'] as int;
        } else {
          throw Exception('orderId not found in response');
        }
      } else {
        throw Exception('Failed to create order: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioError(e, 'createOrder');
      rethrow;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Future<List<OrderModel>> getAllOrders() async {
    try {
      final response = await _dio.get(_baseUrl);

      if (response.statusCode == 200) {
        if (response.data is List) {
          final List<dynamic> data = response.data;
          return data.map((json) => OrderModel.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format: Expected a list');
        }
      } else {
        throw Exception('Failed to fetch orders: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioError(e, 'getAllOrders');
      rethrow;
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<List<OrderModel>> getOrdersByDeliveryPerson(
      int deliveryPersonId) async {
    try {
      final response = await _dio.get('$_baseUrl/delivery/$deliveryPersonId');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final List<dynamic> data = response.data;
          return data.map((json) => OrderModel.fromJson(json)).toList();
        } else {
          throw Exception('Invalid response format: Expected a list');
        }
      } else {
        throw Exception('Failed to fetch orders: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioError(e, 'getOrdersByDeliveryPerson');
      rethrow;
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  Future<List<DeliveryPersonModel>> getAvailableDeliveryPersons() async {
    try {
      final response = await _dio.get('$_baseUrl/delivery-persons');

      if (response.statusCode == 200) {
        if (response.data is List) {
          final List<dynamic> data = response.data;
          return data
              .map((json) => DeliveryPersonModel.fromJson(json))
              .toList();
        } else {
          throw Exception('Invalid response format: Expected a list');
        }
      } else {
        throw Exception(
            'Failed to fetch delivery persons: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioError(e, 'getAvailableDeliveryPersons');
      rethrow;
    } catch (e) {
      throw Exception('Failed to fetch delivery persons: $e');
    }
  }

  Future<void> assignDeliveryPerson(int orderId, int deliveryPersonId) async {
    try {
      if (orderId <= 0) throw Exception('Invalid orderId: $orderId');
      if (deliveryPersonId <= 0)
        throw Exception('Invalid deliveryPersonId: $deliveryPersonId');

      final response = await _dio.put(
        '$_baseUrl/$orderId/assign-delivery',
        queryParameters: {'deliveryPersonId': deliveryPersonId},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'Failed to assign delivery person: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioError(e, 'assignDeliveryPerson');
      rethrow;
    } catch (e) {
      throw Exception('Failed to assign delivery person: $e');
    }
  }

  Future<void> deleteOrder(int orderId) async {
    try {
      if (orderId <= 0) throw Exception('Invalid orderId: $orderId');

      final response = await _dio.delete('$_baseUrl/$orderId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete order: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioError(e, 'deleteOrder');
      rethrow;
    } catch (e) {
      throw Exception('Failed to delete order: $e');
    }
  }

  Future<void> updateOrderStatus(
      int orderId, int deliveryPersonId, String status) async {
    try {
      if (orderId <= 0) throw Exception('Invalid orderId: $orderId');
      if (deliveryPersonId <= 0)
        throw Exception('Invalid deliveryPersonId: $deliveryPersonId');
      if (!['Shipped', 'Delivered', 'Cancelled', 'Processing']
          .contains(status)) {
        throw Exception('Invalid status: $status');
      }

      final response = await _dio.put(
        '$_baseUrl/$orderId/delivery-status',
        queryParameters: {
          'deliveryPersonId': deliveryPersonId,
          'status': status,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'Failed to update order status: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      String errorMsg = 'Network error in updateOrderStatus: ${e.message}';
      if (e.response != null) {
        errorMsg += ' (Status: ${e.response?.statusCode})';
        if (e.response?.statusCode == 403) {
          errorMsg = 'You are not assigned to this order.';
        } else if (e.response?.statusCode == 400) {
          errorMsg = 'Invalid status or request parameters.';
        }
      }
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  Future<void> confirmOrderDelivery(int orderId, bool isDelivered) async {
    try {
      if (orderId <= 0) throw Exception('Invalid orderId: $orderId');

      final response = await _dio.put(
        '$_baseUrl/$orderId/confirm-delivery',
        data: {'isDelivered': isDelivered},
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'Failed to confirm delivery: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioError(e, 'confirmOrderDelivery');
      rethrow;
    } catch (e) {
      throw Exception('Failed to confirm delivery: $e');
    }
  }

  void _handleDioError(DioException e, String methodName) {
    String errorMsg = 'Network error in $methodName: ${e.message}';
    if (e.response != null) {
      errorMsg += ' (Status: ${e.response?.statusCode})';
    }
    throw Exception(errorMsg);
  }
}
