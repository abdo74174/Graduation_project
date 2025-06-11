import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart' show IOHttpClientAdapter;
import 'package:flutter/foundation.dart';

class ForgotPasswordService {
  final Dio dio;

  ForgotPasswordService({required this.dio}) {
    debugPrint('Initial Dio base URL: ${dio.options.baseUrl}');

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

    dio.interceptors.clear();
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('Sending request to ${options.uri}');
        debugPrint('Request data: ${options.data}');
        debugPrint('Base URL: ${dio.options.baseUrl}');
        debugPrint('Full URL: ${options.uri.toString()}');
        if (options.uri.toString().contains('https://https') ||
            options.uri.toString().contains(':7273/api/:7273')) {
          debugPrint('ERROR: Malformed URL detected: ${options.uri}');
          throw DioException(
            requestOptions: options,
            error: 'Malformed URL: ${options.uri}',
            type: DioExceptionType.badResponse,
          );
        }
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
                'Server returned HTML instead of JSON. Check API endpoint configuration.',
            type: DioExceptionType.badResponse,
            response: response,
          ));
        }
        return handler.next(response);
      },
      onError: (DioException error, handler) {
        debugPrint(
            'Error occurred: ${error.message}, response: ${error.response?.data}');
        debugPrint('Error details: ${error.toString()}');
        return handler.next(error);
      },
    ));
  }

  Future<Map<String, dynamic>> sendOtp(String email) async {
    if (email.isEmpty) {
      debugPrint('Error: Email is empty in sendOtp');
      return {
        'success': false,
        'message': 'Email is required',
      };
    }

    try {
      debugPrint('Preparing to send OTP for email: $email');
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
        debugPrint('Invalid server response format: ${response.data}');
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
      debugPrint('Error details: ${e.message}');
      String errorMessage = 'Network error';
      if (e.response != null) {
        if (e.response!.data.toString().contains('<html>')) {
          errorMessage = 'Server configuration issue - received HTML response';
        } else if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? 'Request failed';
        } else {
          errorMessage = e.message ?? 'Unknown network error';
        }
      } else {
        errorMessage =
            'Failed to connect to server. Check network or server status.';
      }
      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp(
      String email, String otp, String newPassword) async {
    if (email.isEmpty) {
      debugPrint('Error: Email is empty in verifyOtp');
      return {
        'success': false,
        'message': 'Email is required',
      };
    }

    if (otp.isEmpty) {
      debugPrint('Error: OTP is empty in verifyOtp');
      return {
        'success': false,
        'message': 'OTP is required',
      };
    }

    try {
      debugPrint('Preparing to verify OTP for email: $email');
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
      debugPrint('Error details: ${e.message}');
      String errorMessage = 'Network error occurred. Please try again.';
      if (e.response != null) {
        if (e.response!.data.toString().contains('<html>')) {
          errorMessage = 'Server configuration issue - received HTML response';
        } else if (e.response!.data is Map) {
          errorMessage = e.response!.data['message'] ?? 'Request failed';
        } else {
          errorMessage = e.message ?? 'Unknown network error';
        }
      } else {
        errorMessage =
            'Failed to connect to server. Check network or server status.';
      }
      final errorResult = {
        'success': false,
        'message': errorMessage,
      };
      debugPrint('Verify OTP error result: $errorResult');
      return errorResult;
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return {
        'success': false,
        'message': 'Unexpected error: $e',
      };
    }
  }
}
