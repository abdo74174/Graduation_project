import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoogleSignInService {
  final String _baseUrl = 'https://10.0.2.2:7273/api/MedBridge';
  final Dio _dio;
  final GoogleSignIn _googleSignIn;
  final FirebaseAuth _auth;

  GoogleSignInService()
      : _dio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        )),
        _googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
          serverClientId:
              'YOUR_WEB_CLIENT_ID', // Replace with Web Client ID for backend
        ),
        _auth = FirebaseAuth.instance {
    // Allow self-signed certificates for local development (remove in production)
    (_dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('Dio Request: ${options.method} ${options.uri}');
        print('Dio Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Dio Response: Status ${response.statusCode}');
        print('Dio Response Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('Dio Error: ${e.message}');
        print('Dio Error Response: ${e.response?.data}');
        return handler.next(e);
      },
    ));
  }

  Future<Map<String, dynamic>> signInWithGoogle() async {
    print('Starting Google Sign-In...');
    try {
      // Sign out to ensure fresh login
      print('Clearing previous sessions...');
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Check if already signed in
      bool isSignedIn = await _googleSignIn.isSignedIn();
      print('Is user already signed in? $isSignedIn');

      // Initiate Google Sign-In
      print('Opening Google Sign-In dialog...');
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google Sign-In cancelled by user');
        throw Exception('Google Sign-In cancelled by user');
      }
      print('Google User: ${googleUser.email}, ID: ${googleUser.id}');

      // Get Google authentication details
      print('Fetching Google auth details...');
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        print('Failed to get ID token');
        throw Exception('Failed to get ID token');
      }
      print('ID Token received: ${idToken.substring(0, 20)}...');

      // Sign in with Firebase
      print('Signing in with Firebase...');
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        print('Firebase sign-in failed');
        throw Exception('Firebase sign-in failed');
      }
      print('Firebase User: ${firebaseUser.email}, UID: ${firebaseUser.uid}');

      // Send ID token to backend
      final url = '$_baseUrl/signin/google';
      print('Sending ID token to backend: $url');
      final response = await _dio.post(
        url,
        data: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        print('Backend response: $data');

        if (data['status'] == 'new_user') {
          print('New user detected, needs profile completion');
          return data;
        }

        // Store user data
        final prefs = await SharedPreferences.getInstance();
        print('Storing user data in SharedPreferences...');
        await prefs.setString('user_id', data['id'].toString());
        await prefs.setString('token', data['token'] ?? '');
        await prefs.setString('email', data['email'] ?? '');
        await prefs.setString('kindOfWork', data['kindOfWork'] ?? 'Doctor');
        if (data['medicalSpecialist'] != null) {
          await prefs.setString('medicalSpecialist', data['medicalSpecialist']);
        }
        await prefs.setBool('isAdmin', data['isAdmin'] ?? false);
        await prefs.setBool('isLoggedIn', true);
        print('User data stored successfully');

        return data;
      } else {
        print('Backend error: ${response.data}');
        throw Exception('Google Sign-In failed: ${response.data}');
      }
    } on PlatformException catch (e) {
      print(
          'PlatformException: Code=${e.code}, Message=${e.message}, Details=${e.details}');
      if (e.code == 'sign_in_failed' &&
          e.message?.contains('ApiException: 10') == true) {
        print(
            'DEVELOPER_ERROR: Check SHA-1, package name, and Client ID in Google Cloud/Firebase Console');
      }
      throw Exception('Google Sign-In error: ${e.message}');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: Code=${e.code}, Message=${e.message}');
      throw Exception('Firebase sign-in error: ${e.message}');
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      print('DioException response: ${e.response?.data}');
      throw Exception('Google Sign-In error: ${e.message}');
    } catch (e) {
      print('Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> completeGoogleProfile({
    required String email,
    required String phone,
    required String address,
    String? medicalSpecialist,
  }) async {
    print('Completing Google profile for $email...');
    try {
      final url = '$_baseUrl/signin/google/complete-profile';
      print('Sending profile data to: $url');
      final response = await _dio.post(
        url,
        data: jsonEncode({
          'email': email,
          'phone': phone,
          'address': address,
          'medicalSpecialist': medicalSpecialist,
        }),
      );

      if (response.statusCode == 200) {
        print('Profile completed successfully: ${response.data}');
        final userData = await _fetchUserData(email);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userData['id'].toString());
        await prefs.setString('token', userData['token'] ?? '');
        await prefs.setString('email', userData['email'] ?? '');
        await prefs.setString('kindOfWork', userData['kindOfWork'] ?? 'Doctor');
        if (userData['medicalSpecialist'] != null) {
          await prefs.setString(
              'medicalSpecialist', userData['medicalSpecialist']);
        }
        await prefs.setBool('isAdmin', userData['isAdmin'] ?? false);
        await prefs.setBool('isLoggedIn', true);
        print('User data stored after profile completion');
      } else {
        print('Profile completion failed: ${response.data}');
        throw Exception('Failed to complete profile: ${response.data}');
      }
    } on DioException catch (e) {
      print('DioException during profile completion: ${e.message}');
      print('DioException response: ${e.response?.data}');
      throw Exception('Profile completion error: ${e.message}');
    } catch (e) {
      print('Unexpected error during profile completion: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchUserData(String email) async {
    print('Fetching user data for $email...');
    try {
      final response = await _dio.get('$_baseUrl/User/$email');
      if (response.statusCode == 200) {
        print('User data fetched: ${response.data}');
        return response.data as Map<String, dynamic>;
      } else {
        print('Failed to fetch user data: ${response.data}');
        throw Exception('Failed to fetch user data: ${response.data}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      throw Exception('Error fetching user data: $e');
    }
  }

  Future<void> signOut() async {
    print('Signing out...');
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('Signed out and cleared SharedPreferences');
    } catch (e) {
      print('Error during sign out: $e');
      throw Exception('Error during sign out: $e');
    }
  }
}
