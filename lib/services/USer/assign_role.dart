import 'package:dio/dio.dart';

// Admin API Service
class AdminApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://10.0.2.2:7273/api/admin', // Replace with your API URL
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ));

  AdminApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add authentication headers if needed
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        return handler.next(e);
      },
    ));
  }

  /// Fetches all users from the backend
  Future<List<dynamic>> getUsers() async {
    try {
      final response = await _dio.get('/users');
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Adds a new admin with the provided email and password
  Future<Response> addAdmin(String email, String password) async {
    try {
      return await _dio.post('/add-admin', data: {
        'email': email,
        'password': password,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Deletes an admin by ID
  Future<Response> deleteAdmin(int id) async {
    try {
      return await _dio.delete('/delete-admin/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Blocks a user by ID
  Future<Response> blockUser(int id) async {
    try {
      return await _dio.post('/block-user/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Deactivates a user by ID
  Future<Response> deactivateUser(int id) async {
    try {
      return await _dio.post('/deactivate-user/$id');
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Handles Dio errors and converts them to custom exceptions
  Exception _handleError(dynamic e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException('Connection timed out');
        case DioExceptionType.badResponse:
          final message =
              e.response?.data['message'] ?? 'Server error occurred';
          return ServerException(message);
        case DioExceptionType.cancel:
          return AppException('Request cancelled');
        default:
          return NetworkException('Network error occurred');
      }
    }
    return AppException('An unexpected error occurred');
  }
}

// Exception classes
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
