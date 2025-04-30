import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart' show IOHttpClientAdapter;
import 'package:flutter/foundation.dart';

class ForgotPasswordService {
  final Dio dio;

  ForgotPasswordService({required this.dio}) {
    dio.options = BaseOptions(
      baseUrl: 'https://10.0.2.2:7273/api/ForgotPassword',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => status! < 500,
    );

    if (!kIsWeb) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final HttpClient client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('Sending request to ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
            'Received response: ${response.statusCode}, data: ${response.data}');
        if (response.data != null &&
            response.data.toString().contains('<html>')) {
          return handler.reject(DioException(
            requestOptions: response.requestOptions,
            error:
                'Server returned HTML instead of JSON. Check your API endpoint configuration.',
            type: DioExceptionType.badResponse,
            response: response,
          ));
        }
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        debugPrint(
            'Error occurred: ${error.message}, response: ${error.response?.data}');
        return handler.next(error);
      },
    ));
  }

  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await dio.post(
        '/send-otp',
        data: {'email': email},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveDataWhenStatusError: true,
          validateStatus: (status) => status == 200,
        ),
      );

      debugPrint('Send OTP response data: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        return {
          'success': false,
          'message': 'Invalid server response format',
        };
      }

      return {
        'success': response.data['success'] ?? false,
        'message': response.data['message'] ?? 'OTP sent successfully',
      };
    } on DioException catch (e) {
      debugPrint('Send OTP error response: ${e.response?.data}');
      String errorMessage = 'Network error';
      if (e.response != null) {
        if (e.response!.data.toString().contains('<html>')) {
          errorMessage = 'Server configuration issue - received HTML response';
        } else if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? 'Request failed';
        }
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp(
      String email, String otp, String newPassword) async {
    try {
      final passwordRegex = RegExp(
          r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$');
      if (!passwordRegex.hasMatch(newPassword)) {
        return {
          'success': false,
          'message':
              'Password must contain 8+ chars, 1 letter, 1 number, and 1 special character',
        };
      }

      final response = await dio.post(
        '/verify-otp',
        data: {
          'Email': email,
          'Otp': otp,
          'NewPassword': newPassword,
        },
        options: Options(
          validateStatus: (status) => status == 200,
        ),
      );

      debugPrint('Verify OTP raw response data: ${response.data}');

      if (response.data is! Map<String, dynamic>) {
        debugPrint('Invalid server response format: ${response.data}');
        return {
          'success': false,
          'message': 'Invalid server response format',
        };
      }

      final responseData = response.data as Map<String, dynamic>;
      final result = {
        'success': responseData['success'] ?? false,
        'message': responseData['message'] ?? 'Password reset successful',
        'customToken': responseData['customToken'] as String?,
      };

      debugPrint('Verify OTP processed response: $result');
      return result;
    } on DioException catch (e) {
      debugPrint('Verify OTP error response: ${e.response?.data}');
      String errorMessage = 'Network error occurred. Please try again.';
      if (e.response != null) {
        if (e.response!.data.toString().contains('<html>')) {
          errorMessage = 'Server configuration issue - received HTML response';
        } else if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? 'Request failed';
        }
      }
      final errorResult = {
        'success': false,
        'message': errorMessage,
      };
      debugPrint('Verify OTP error result: $errorResult');
      return errorResult;
    }
  }
}
