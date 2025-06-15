import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/screens/delivery/delivery_person_profile_page.dart';

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

//   static createDeliveryPersonRequestModel(
//       {required String phone,
//       required String address,
//       required String cardNumber,
//       required requestStatus,
//       required isAvailable,
//       required userId}) {}
// }

// class DeliveryPersonRequestModel {
//   String phone;
//   String address;
//   String cardNumber;
//   String? requestStatus;
//   bool? isAvailable;
//   int? userId;

//   DeliveryPersonRequestModel({
//     this.phone = '',
//     this.address = '',
//     this.cardNumber = '',
//     this.requestStatus,
//     this.isAvailable,
//     this.userId,
//   });

//   factory DeliveryPersonRequestModel.fromJson(Map<String, dynamic> json) {
//     return DeliveryPersonRequestModel(
//       phone: json['phone'] ?? '',
//       address: json['address'] ?? '',
//       cardNumber: json['cardNumber'] ?? '',
//       requestStatus: json['requestStatus'],
//       isAvailable: json['isAvailable'] as bool?,
//       userId: (json['userId'] is int)
//           ? json['userId']
//           : int.tryParse(json['userId']?.toString() ?? '0'),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'phone': phone,
//       'address': address,
//       'cardNumber': cardNumber,
//       'requestStatus': requestStatus,
//       'isAvailable': isAvailable,
//       'userId': userId,
//     };
//   }

//   @override
//   String toString() {
//     return 'DeliveryPersonRequestModel(phone: $phone, address: $address, cardNumber: $cardNumber, requestStatus: $requestStatus, isAvailable: $isAvailable, userId: $userId)';
//   }
}
