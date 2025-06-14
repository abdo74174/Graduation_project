import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

class DeliveryPersonService {
  static const String _baseUrl = 'https://10.0.2.2:7273/api/DeliveryPerson';
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
              errorMsg += ' (Response: ${e.response?.data})';
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
}
