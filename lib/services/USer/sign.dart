import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class USerService {
  final Dio dio;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  USerService()
      : dio = Dio(BaseOptions(
          baseUrl: '${baseUri}MedBridge',
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        )) {
    // Note: For production, ensure a valid SSL certificate is used.
    // For local development, you may need to trust a self-signed certificate.
    // Avoid disabling certificate verification in production.
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      // Temporarily allow self-signed certificates for local development
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
  }

  Future<List<String>> fetchWorkTypes() async {
    try {
      final response = await dio.get('/work-types');
      if (response.statusCode == 200) {
        return List<String>.from(response.data['workTypes']).toSet().toList();
      } else {
        print(
            'Failed to fetch work types. Status code: ${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      return [];
    } catch (e) {
      print('Unexpected error: $e');
      return [];
    }
  }

  Future<List<String>> fetchSpecialties() async {
    try {
      final response = await dio.get('/specialties');
      print('Specialties response: \${response.data}'); // Add this line
      if (response.statusCode == 200) {
        return List<String>.from(response.data['specialties']).toSet().toList();
      } else {
        print(
            'Failed to fetch specialties. Status code: \${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      print('DioException: \${e.message}');
      return [];
    } catch (e) {
      print('Unexpected error: \$e');
      return [];
    }
  }

  Future<bool> updateRoleAndSpecialist({
    required String email,
    required String? kindOfWork,
    String? medicalSpecialist,
  }) async {
    try {
      final response = await dio.patch(
        '/User/info/$email',
        data: {
          'kindOfWork': kindOfWork,
          'medicalSpecialist': medicalSpecialist,
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update role. Status code: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      return false;
    } catch (e) {
      print('Error updating role: $e');
      return false;
    }
  }

  Future<UserModel?> fetchUserByEmail(String email) async {
    try {
      final encodedEmail = Uri.encodeComponent(email);
      final url = '/User/$encodedEmail';
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
      print('DioException: ${e.message}');
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

  Future<UserModel?> fetchUserById(int userId) async {
    try {
      final url = '/User/$userId';
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
      print('DioException: ${e.message}');
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

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
    bool isAdmin = false,
  }) async {
    try {
      // Firebase signup
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Store user data in Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'username': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Backend signup
        final formData = FormData.fromMap({
          'Name': name,
          'Email': email,
          'Password': password,
          'ConfirmPassword': confirmPassword,
          'IsAdmin': isAdmin,
        });

        final response = await dio.post(
          '/User/signup',
          data: formData,
          options: Options(
            contentType: 'multipart/form-data',
          ),
        );

        if (response.statusCode != 200) {
          print(
              'Backend signup failed: ${response.statusCode} - ${response.data}');
          throw Exception('Backend signup failed: ${response.data['message']}');
        }

        // Save user ID and email
        final prefs = await SharedPreferences.getInstance();
        final userId = response.data['id']?.toString() ?? user.uid;
        await prefs.setString('user_id', userId);
        await prefs.setString('email', email);
        print(
            'Signup success: ${response.data}, user_id: $userId saved to SharedPreferences');
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase signup error: ${e.code} - ${e.message}');
      throw Exception(e.message);
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ??
          e.response?.data?.toString() ??
          'Signup failed';
      print('Backend signup error: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('Unexpected signup error: $e');
      throw Exception('Signup failed: $e');
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      // Firebase login
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Backend login
      final formData = FormData.fromMap({
        'email': email,
        'password': password,
      });

      final response = await dio.post(
        '/User/signin', // Corrected to match backend endpoint
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          headers: {
            'X-Firebase-Locale': 'en', // Avoid null header warning
          },
        ),
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final kindOfWork = response.data['kindOfWork'];
        final medicalSpecialist = response.data['medicalSpecialist'];
        final isAdmin = response.data['isAdmin'];
        final userId = response.data['id']?.toString();

        if (token != null && token is String) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('kindOfWork', kindOfWork ?? 'Doctor');
          if (medicalSpecialist != null) {
            await prefs.setString('medicalSpecialist', medicalSpecialist);
          } else {
            await prefs.remove('medicalSpecialist');
          }
          await prefs.setBool('isAdmin', isAdmin ?? false);
          await prefs.setString('email', email);
          await prefs.setString('user_id', userId ?? userCredential.user!.uid);
          print('Login success: token=$token, user_id=$userId');
          return true;
        } else {
          print('Error: Token missing or invalid in response');
          return false;
        }
      } else {
        print(
            'Error: Server responded with status ${response.statusCode}: ${response.data}');
        return false;
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuth error: ${e.code} - ${e.message}');
      return false;
    } on DioException catch (e) {
      final errorMessage = e.response?.data['message'] ??
          e.response?.data?.toString() ??
          'Server error';
      print('Backend error: $errorMessage');
      print('Full response: ${e.response?.data}');
      return false;
    } catch (e) {
      print('Unexpected error: $e');
      return false;
    }
  }

  Future<void> updateUserProfile({
    required String email,
    required String name,
    String? profileImage,
    String? phone,
    String? address,
    String? medicalSpecialist,
  }) async {
    try {
      Map<String, dynamic> formDataMap = {
        'Email': email,
        'Name': name,
        'MedicalSpecialist': medicalSpecialist,
        'Phone': phone,
        'Address': address,
      };

      if (profileImage != null) {
        if (profileImage.startsWith('data:image')) {
          final bytes = base64Decode(profileImage.split(',').last);
          formDataMap['profileImage'] = MultipartFile.fromBytes(
            bytes,
            filename: 'profileImage.jpg',
          );
        } else {
          final file = File(profileImage);
          if (await file.exists()) {
            formDataMap['profileImage'] = await MultipartFile.fromFile(
              profileImage,
              filename: profileImage.split('/').last,
            );
          } else {
            print('❌ Profile image file does not exist: $profileImage');
            return;
          }
        }
      }

      final formData = FormData.fromMap(formDataMap);
      final response = await dio.put(
        '/User/$email',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      print('✅ Update successful: ${response.data}');
    } on DioException catch (e) {
      print('❌ Update error: ${e.message}');
      if (e.response != null) {
        print('Status Code: ${e.response?.statusCode}');
        print('Response Data: ${e.response?.data}');
      }
      throw Exception(e.message);
    }
  }

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
  }

  Future<void> clearEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
  }
}
