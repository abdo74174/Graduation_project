import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:graduation_project/Models/user_model.dart'; // مهم للـ HttpClientAdapter

class USerService {
  final Dio dio;

  // Create a single instance of Dio with base URL
  USerService()
      : dio = Dio(BaseOptions(
          baseUrl: 'https://10.0.2.2:7273/api/MedBridge', // Use base URL here
          headers: {'Content-Type': 'application/json'},
        )) {
    // Configure the HTTP client to ignore certificate errors
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              true; // Ignore SSL certificate
      return client;
    };
  }

  // Fetch user data by email
  Future<User?> fetchUserByEmail(String email) async {
    try {
      final encodedEmail = Uri.encodeComponent(email);
      final url =
          '/User/$encodedEmail'; // Use relative URL, since base URL is already set
      print('Fetching from: $url');

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        print('User data: ${response.data}');
        return User.fromJson(response.data);
      } else {
        print('Failed to fetch user. Status code: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('DioException: $e');
      if (e.response != null) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  // User signup
  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    const String url = '/User/signup'; // Use relative URL

    final formData = FormData.fromMap({
      'Name': name,
      'Email': email,
      'Password': password,
      'ConfirmPassword': confirmPassword,
    });

    try {
      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        print('Signup success: ${response.data}');
      } else {
        print('Signup failed: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('Signup error: $e');
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['errors'] ?? e.response?.data ?? "Signup failed";
      print("Signup error: $errorMessage");
    }
  }

  // User login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    const String url = '/User/signIn'; // Use relative URL

    final formData = FormData.fromMap({
      'Email': email,
      'Password': password,
    });

    try {
      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      if (response.statusCode == 200) {
        print('SignIn success: ${response.data}');
      } else {
        print('SignIn failed: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      print('SignIn error: $e');
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['errors'] ?? e.response?.data ?? "SignIn failed";
      print("SignIn error: $errorMessage");
    }
  }

  Future<bool> updateRoleAndSpecialist({
    required String email,
    String? role,
    String? medicalSpecialist,
  }) async {
    final Map<String, dynamic> payload = {};
    if (role != null) payload['role'] = role;
    if (medicalSpecialist != null)
      payload['medicalSpecialist'] = medicalSpecialist;

    try {
      final response = await dio.patch(
        '/User/info/$email', // relative to baseUrl :contentReference[oaicite:0]{index=0}
        data: payload,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      // Log error details if you need to debug
      print('❌ PATCH error: ${e.response?.statusCode} ${e.response?.data}');
      return false;
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String email,
    required String name,
    required String password,
    required String medicalSpecialist,
    File? profileImage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'Email': email,
        'Name': name,
        'Password': password,
        'MedicalSpecialist': medicalSpecialist,
        if (profileImage != null)
          'profileImage': await MultipartFile.fromFile(profileImage.path,
              filename: profileImage.path.split('/').last),
      });

      final response = await dio.put(
        '/User/$email', // Use relative URL
        data: formData,
        options: Options(headers: {
          "Content-Type": "multipart/form-data",
        }),
      );

      print("✅ Update successful: ${response.data}");
    } on DioException catch (e) {
      print("❌ Update error: $e");
    }
  }
}
