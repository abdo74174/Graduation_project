import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:graduation_project/core/constants/constant.dart';

class DeliveryPersonService {
  static final String _baseUrl = '${baseUri}DeliveryPerson';
  final Dio _dio;

  DeliveryPersonService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
          validateStatus: (status) => status != null && status < 500,
          headers: {'Content-Type': 'application/json'},
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

  Future<List<DeliveryPersonRequestModel>> fetchDeliveryPersonInfoById(
      int userId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/userId?userId=$userId',
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (response.data is List) {
          final data = response.data as List;
          return data
              .map((e) => DeliveryPersonRequestModel.fromJson(e))
              .toList();
        } else {
          throw Exception(
              'Unexpected response format: Status code ${response.statusCode}');
        }
      } else {
        throw Exception(
            'Failed to fetch delivery person. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<DeliveryPersonRequestModel>> fetchDeliveryPersonInfo(
      int userId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/data/$userId',
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        if (response.data is List) {
          final data = response.data as List;
          return data
              .map((e) => DeliveryPersonRequestModel.fromJson(e))
              .toList();
        } else {
          throw Exception(
              'Unexpected response format: Status code ${response.statusCode}');
        }
      } else {
        throw Exception(
            'Failed to fetch delivery person data. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> submitDeliveryPersonRequest({
    required String phone,
    required String address,
    required String cardNumber,
    required int userId,
  }) async {
    int retries = 3;
    while (retries > 0) {
      try {
        final data = {
          'phone': phone,
          'address': address,
          'cardNumber': cardNumber,
        };

        final response = await _dio.post(
          '$_baseUrl/submit-request',
          data: data,
          queryParameters: {'userid': userId},
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          throw Exception(
              'Failed to submit request: ${response.statusMessage}');
        }
        return;
      } on DioException catch (e) {
        retries--;
        if (retries == 0) {
          String errorMsg =
              'Network error in submitDeliveryPersonRequest: ${e.message}';
          if (e.response != null) {
            errorMsg += ' (Status: ${e.response?.statusCode})';
            if (e.response?.data != null) {
              errorMsg += ' (${e.response?.data})';
            }
          }
          throw Exception(errorMsg);
        }
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        throw Exception('Failed to submit request: $e');
      }
    }
  }

  Future<List<DeliveryPersonRequestModel>> getAllRequests() async {
    try {
      final response = await _dio.get('$_baseUrl/requests');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print('Raw response data: $data');
        return data
            .map((json) => DeliveryPersonRequestModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to fetch requests: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error in getAllRequests: $e');
      throw Exception('Failed to fetch requests: $e');
    }
  }

  Future<void> updateAvailability(int userId, bool isAvailable) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl/availability',
        data: {'isAvailable': isAvailable},
        queryParameters: {'userId': userId},
      );
      if (response.statusCode != 204) {
        throw Exception(
            'Failed to update availability: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error in updateAvailability: $e');
      throw Exception('Failed to update availability: $e');
    }
  }

  static createDeliveryPersonRequestModel(
      {required String phone,
      required String address,
      required String cardNumber,
      required requestStatus,
      required isAvailable,
      required userId}) {}
}

class DeliveryPersonRequestModel {
  int deliveryPersonId;
  String phone;
  String address;
  String cardNumber;
  String? requestStatus;
  bool? isAvailable;
  int? userId;
  String? name;
  String? email;

  DeliveryPersonRequestModel({
    this.deliveryPersonId = 0,
    this.phone = '',
    this.address = '',
    this.cardNumber = '',
    this.requestStatus,
    this.isAvailable,
    this.userId,
    this.name,
    this.email,
  });

  factory DeliveryPersonRequestModel.fromJson(Map<String, dynamic> json) {
    print('JSON Input: $json'); // Debug log to inspect raw JSON
    return DeliveryPersonRequestModel(
      deliveryPersonId: json['deliveryPesonId'] != null
          ? int.parse(json['deliveryPesonId'].toString())
          : json['DeliveryPesonId'] != null
              ? int.parse(json['DeliveryPesonId'].toString())
              : json['deliveryPersonId'] != null
                  ? int.parse(json['deliveryPersonId'].toString())
                  : 0,
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      cardNumber: json['cardNumber'] ?? '',
      requestStatus: json['requestStatus'] as String?,
      isAvailable: json['isAvailable'] as bool?,
      userId: (json['userId'] is int)
          ? json['userId']
          : int.tryParse(json['userId']?.toString() ?? '0'),
      name: json['name'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deliveryPersonId': deliveryPersonId, // Use correct key for serialization
      'phone': phone,
      'address': address,
      'cardNumber': cardNumber,
      'requestStatus': requestStatus,
      'isAvailable': isAvailable,
      'userId': userId,
      'name': name,
      'email': email,
    };
  }

  @override
  String toString() {
    return 'DeliveryPersonRequestModel(deliveryPersonId: $deliveryPersonId, phone: $phone, address: $address, cardNumber: $cardNumber, requestStatus: $requestStatus, isAvailable: $isAvailable, userId: $userId, name: $name, email: $email)';
  }
}
