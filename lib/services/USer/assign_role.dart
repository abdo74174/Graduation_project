import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

// Admin API Service
class AdminApiService {
  final Dio _dio;

  AdminApiService()
      : _dio = Dio(BaseOptions(
          baseUrl: 'https://10.0.2.2:7273/api/Admin',
          connectTimeout: Duration(seconds: 30),
          receiveTimeout: Duration(seconds: 30),
        )) {
    // Bypass SSL for local dev (remove in production)
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };

    // Logging interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  /// Fetch all users
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Add a new admin
  Future<Response> addAdmin(int id) async {
    try {
      return await _dio.put(
        '/add-admin',
        queryParameters: {
          'id': id,
        },
      );
    } catch (e) {
      if (e is DioException) {}
      throw _handleError(e);
    }
  }

  /// Delete an admin by ID
  Future<Response> deleteAdmin(int id) async {
    try {
      final response = await _dio.put('/delete-admin/$id');
      print("Delete admin response: ${response.statusCode} - ${response.data}");
      return response;
    } catch (e) {
      if (e is DioError) {
        print("DioError occurred:");
        print("Status code: ${e.response?.statusCode}");
        print("Data: ${e.response?.data}");
      } else {
        print("Unexpected error: $e");
      }
      throw e;
    }
  }

  /// Block a user by ID
  Future<Response> blockUser(int id) async {
    try {
      return await _dio.post('/block-user/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> unblockUser(int id) async {
    try {
      return await _dio.post('/Un_block-user/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Deactivate a user by ID
  Future<Response> deactivateUser(int id) async {
    try {
      return await _dio.post('/deactivate-user/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Deactivate a user by ID
  Future<Response> activateUser(int id) async {
    try {
      return await _dio.post('/Activate-user/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Error handler
  Exception _handleError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception(
              'Connection timed out. Please check your internet connection.');
        case DioExceptionType.connectionError:
          return Exception(
              'Connection lost. Please check your internet connection.');
        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          final data = e.response?.data;
          if (statusCode == 404) {
            return Exception('Resource not found');
          } else if (statusCode == 401) {
            return Exception('Unauthorized access');
          } else if (data != null && data is Map) {
            return Exception(data['message'] ?? 'Server error occurred');
          }
          return Exception('Server error occurred');
        default:
          return Exception('An unexpected error occurred');
      }
    }
    return AppException('An unexpected error occurred');
  }
}

// Custom Exceptions
class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

class ServerException extends AppException {
  ServerException(String message) : super(message);
}

class TimeoutException extends AppException {
  TimeoutException(String message) : super(message);
}
