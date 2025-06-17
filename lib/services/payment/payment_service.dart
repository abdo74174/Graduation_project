import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:graduation_project/Models/cart_item.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/order/order_service.dart';
import 'package:graduation_project/services/cart/cart_service.dart';
import 'dart:io';

class PaymentService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUri,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    validateStatus: (status) => status != null && status < 500,
  ));

  PaymentService() {
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<Map<String, dynamic>> getCustomerCards(int customerId) async {
    if (customerId <= 0) throw Exception('Invalid customer ID');

    try {
      final response = await _dio.get('payments/customer/$customerId/cards');
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format: Expected JSON object');
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to fetch cards: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error fetching cards: $e');
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    required int customerId,
  }) async {
    if (amount <= 0) throw Exception('Invalid payment amount');
    if (customerId <= 0) throw Exception('Invalid customer ID');
    if (currency.isEmpty) throw Exception('Currency cannot be empty');

    try {
      final response = await _dio.post(
        'payments/create-payment-intent',
        data: {
          'amount': (amount * 100).toInt(),
          'currency': currency.toLowerCase(),
          'customerId': customerId,
        },
      );
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format: Expected JSON object');
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to create payment intent: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error creating payment intent: $e');
    }
  }

  Future<Map<String, dynamic>> createSetupIntent({
    required int customerId,
  }) async {
    if (customerId <= 0) throw Exception('Invalid customer ID');

    try {
      final response = await _dio.post(
        'payments/create-setup-intent',
        data: {'customerId': customerId},
      );
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format: Expected JSON object');
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to create setup intent: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error creating setup intent: $e');
    }
  }

  Future<Map<String, dynamic>> verifyPayment({
    required String paymentIntentId,
  }) async {
    if (paymentIntentId.isEmpty) throw Exception('Invalid payment intent ID');

    try {
      final response = await _dio.get('payments/verify/$paymentIntentId');
      if (response.data is! Map<String, dynamic>) {
        throw Exception('Invalid response format: Expected JSON object');
      }
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to verify payment: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error verifying payment: $e');
    }
  }

  Future<void> savePayment({
    required String userId,
    required double amount,
    required String paymentIntentId,
    required List<CartItems> cartItems,
    required String address,
  }) async {
    if (userId.isEmpty) throw Exception('Invalid user ID');
    if (amount <= 0) throw Exception('Invalid payment amount');
    if (paymentIntentId.isEmpty) throw Exception('Invalid payment intent ID');
    if (cartItems.isEmpty) throw Exception('Cart cannot be empty');
    if (address.isEmpty) throw Exception('Address cannot be empty');

    try {
      final paymentResponse = await _dio.post(
        'payments',
        data: {
          'userId': int.parse(userId),
          'amount': amount,
          'paymentIntentId': paymentIntentId,
          'status': 'succeeded',
          'paymentMethod': 'stripe',
        },
      );

      if (paymentResponse.statusCode != 200 &&
          paymentResponse.statusCode != 201) {
        throw Exception(
            'Failed to save payment: ${paymentResponse.statusMessage}');
      }

      final orderItems = cartItems
          .map((item) => {
                'productId': item.productId,
                'quantity': item.quantity,
              })
          .toList();

      await OrderService().createOrder(int.parse(userId), orderItems, address);

      for (var item in cartItems) {
        await CartService().deleteFromCart(item.productId);
      }
    } on DioException catch (e) {
      throw Exception('Failed to save payment: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error saving payment: $e');
    }
  }
}
