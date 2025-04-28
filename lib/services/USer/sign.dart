import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart'; // مهم للـ HttpClientAdapter

class USerService {
  final Dio dio;

  // Create a single instance of Dio with base URL
  USerService()
      : dio = Dio(BaseOptions(
          baseUrl: 'https://10.0.2.2:7273/api/MedBridge', // Use base URL here
          headers: {'Content-Type': 'application/json'},
        )) {
    // Configure the HTTP client to ignore certificate errors
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) =>
              true; // Ignore SSL certificate
      return client;
    };
  }

  // Fetch user data by email
  Future<UserModel?> fetchUserByEmail(String email) async {
    try {
      final encodedEmail = Uri.encodeComponent(email);
      final url =
          '/User/$encodedEmail'; // Use relative URL, since base URL is already set
      print('Fetching from: $url');

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        print('User data: ${response.data}');
        return UserModel.fromJson(response.data);
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

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    const String url = '/User/signIn'; // relative path

    final formData = FormData.fromMap({
      'email': email,
      'password': password,
    });

    try {
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      print(
          "===================================================================");
      print(response.data.toString());
      print(
          "__+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
      print(response.data.runtimeType);

      if (response.statusCode == 200) {
        print('SignIn success: ${response.data}');

        // 👇 استخراج التوكن (حسب شكل الـ response)
        final token = response.data['token']; // غيرها حسب السيرفر بيرجع إيه

        if (token != null && token is String) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          print("0000000000000000000000000000000000000000000000000000");
          print('Token saved to SharedPreferences: $token');
          print("0000000000000000000000000000000000000000000000000000");
        } else {
          print('Token not found in response!');
          return false;
        }

        return true;
      } else {
        print('SignIn failed: ${response.statusCode} - ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      final errorMessage =
          e.response?.data['errors'] ?? e.response?.data ?? "SignIn failed";
      print("SignIn error: $errorMessage");
      return false;
    } catch (e) {
      print('Unexpected login error: $e');
      return false;
    }
  }

  Future<bool> updateRoleAndSpecialist({
    required String email,
    String? role,
    String? medicalSpecialist,
  }) async {
    final Map<String, dynamic> payload = {};
    if (role != null) payload['role'] = role;
    if (medicalSpecialist != null) {
      payload['medicalSpecialist'] = medicalSpecialist;
    }

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

  Future<void> updateUserProfile({
    required String email,
    required String name,
    required String medicalSpecialist,
    String? profileImage,
    String? phone,
    String? address,
  }) async {
    try {
      Map<String, dynamic> formDataMap = {
        'Email': email,
        'Name': name,
        'MedicalSpecialist': medicalSpecialist,
      };

      if (phone != null) {
        formDataMap['Phone'] = phone;
      }
      if (address != null) {
        formDataMap['Address'] = address;
      }

      if (profileImage != null) {
        if (profileImage.startsWith('data:image')) {
          // Extract the Base64 part after the comma
          final bytes = base64Decode(profileImage.split(',').last);
          formDataMap['profileImage'] = MultipartFile.fromBytes(
            bytes,
            filename: 'profileImage.jpg',
          );
        } else {
          // Handle regular file path
          final file = File(profileImage);
          if (await file.exists()) {
            formDataMap['profileImage'] = await MultipartFile.fromFile(
              profileImage,
              filename: profileImage.split('/').last,
            );
          } else {
            print("❌ Profile image file does not exist: $profileImage");
            return; // Exit early if the file doesn't exist
          }
        }
      }

      final formData = FormData.fromMap(formDataMap);
      final response = await dio.put(
        '/User/$email',
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      print("✅ Update successful: ${response.data}");
    } on DioException catch (e) {
      print("❌ Update error: ${e.message}");
      if (e.response != null) {
        print("Status Code: ${e.response?.statusCode}");
        print("Response Data: ${e.response?.data}");
      }
    }
  }
}
