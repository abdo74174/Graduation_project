import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:graduation_project/Models/order_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:http/http.dart' as http;

Future<T> debugTryCatch<T>(Future<T> Function() block, String context) async {
  try {
    return await block();
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('❌ $context failed: $e');
      debugPrint('📌 StackTrace: $stack');
    }
    rethrow;
  }
}

class AdminDeliveryService {
  static final String _baseUrl = baseUri;

  Future<List<OrderModel>> getAllOrders(
      {int page = 1, int pageSize = 20}) async {
    return await debugTryCatch(() async {
      final uri = Uri.parse(
          '${_baseUrl}DeliveryPersonAdmin/orders?page=$page&pageSize=$pageSize');
      if (kDebugMode) debugPrint('➡️ [GET] $uri');
      final response = await http.get(uri);
      if (kDebugMode)
        debugPrint('⬅️ Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load orders: ${response.statusCode} - ${response.body}');
      }
    }, 'GetAllOrders');
  }

  Future<List<DeliveryPersonModel>> getAvailableDeliveryPersons(
      String address) async {
    return await debugTryCatch(() async {
      final uri = Uri.parse(
          '${_baseUrl}DeliveryPersonAdmin/available-delivery-persons?address=$address');
      if (kDebugMode) debugPrint('➡️ [GET] $uri');
      final response = await http.get(uri);
      if (kDebugMode)
        debugPrint('⬅️ Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => DeliveryPersonModel.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load delivery persons: ${response.statusCode} - ${response.body}');
      }
    }, 'GetAvailableDeliveryPersons');
  }

  Future<List<DeliveryPersonRequestModel>> getDeliveryPersonRequests() async {
    return await debugTryCatch(() async {
      final uri = Uri.parse('${_baseUrl}DeliveryPersonAdmin/requests');
      if (kDebugMode) debugPrint('➡️ [GET] $uri');
      final response = await http.get(uri);
      if (kDebugMode)
        debugPrint('⬅️ Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => DeliveryPersonRequestModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load requests: ${response.statusCode} - ${response.body}');
      }
    }, 'GetDeliveryPersonRequests');
  }

  Future<Map<String, dynamic>> getOrderStatistics() async {
    return await debugTryCatch(() async {
      final uri = Uri.parse('${_baseUrl}DeliveryPersonAdmin/statistics');
      if (kDebugMode) debugPrint('➡️ [GET] $uri');
      final response = await http.get(uri);
      if (kDebugMode)
        debugPrint('⬅️ Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 200) {
        return Map<String, dynamic>.from(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to load order statistics: ${response.statusCode} - ${response.body}');
      }
    }, 'GetOrderStatistics');
  }

  Future<void> handleDeliveryPersonRequest(int requestId, String action) async {
    return await debugTryCatch(() async {
      final uri = Uri.parse(
          '${_baseUrl}DeliveryPersonAdmin/request/$requestId?action=$action');
      if (kDebugMode) debugPrint('➡️ [PUT] $uri');
      final response = await http.put(uri);
      if (kDebugMode)
        debugPrint('⬅️ Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 204) {
        return;
      } else {
        throw Exception(
            'Failed to handle request: ${response.statusCode} - ${response.body}');
      }
    }, 'HandleDeliveryPersonRequest');
  }

  Future<void> assignDeliveryPerson(int orderId, int deliveryPersonId) async {
    return await debugTryCatch(() async {
      final uri = Uri.parse('${_baseUrl}DeliveryPersonAdmin/assign-order');
      final headers = {'Content-Type': 'application/json'};
      final body = {
        'orderId': orderId,
        'deliveryPersonId': deliveryPersonId,
      };

      if (kDebugMode) {
        debugPrint('➡️ [POST] $uri');
        debugPrint('Headers: $headers');
        debugPrint('Body: $body');
      }

      final response =
          await http.post(uri, headers: headers, body: jsonEncode(body));
      if (kDebugMode)
        debugPrint('⬅️ Response (${response.statusCode}): ${response.body}');

      if (response.statusCode == 204) {
        return;
      } else {
        throw Exception(
            'Failed to assign delivery person: ${response.statusCode} - ${response.body}');
      }
    }, 'AssignDeliveryPerson');
  }
}

class DeliveryPersonModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? cardNumber;
  final String requestStatus;
  final bool isAvailable;
  final DateTime? createdAt;

  DeliveryPersonModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.cardNumber,
    required this.requestStatus,
    required this.isAvailable,
    this.createdAt,
  });

  factory DeliveryPersonModel.fromJson(Map<String, dynamic> json) {
    return DeliveryPersonModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      cardNumber: json['cardNumber'],
      requestStatus: json['requestStatus'] ?? 'Pending',
      isAvailable: json['isAvailable'] ?? false,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}

class DeliveryPersonRequestModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String status;
  final bool isAvailable;
  final String? cardNumber;
  final DateTime? createdAt;
  final String? cardImageUrl;
  final String? heraImageUrl;

  DeliveryPersonRequestModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.isAvailable,
    this.cardNumber,
    this.createdAt,
    this.cardImageUrl,
    this.heraImageUrl,
  });

  factory DeliveryPersonRequestModel.fromJson(Map<String, dynamic> json) {
    return DeliveryPersonRequestModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      status: json['requestStatus'] ?? 'Pending',
      isAvailable: json['isAvailable'] ?? false,
      cardNumber: json['cardNumber'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      cardImageUrl: json['cardImageUrl'],
      heraImageUrl: json['heraImageUrl'],
    );
  }
}
