import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:http/io_client.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart'; // For token storage

class CouponService {
  late final Dio _dio;

  CouponService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUri, // e.g., 'https://10.0.2.2:7273/api/'
      headers: {'Content-Type': 'application/json'},
      connectTimeout: const Duration(seconds: 10), // Increased timeout
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Bypass self-signed certificate for development
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        return HttpClient()
          ..badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
      },
    );
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token'); // Adjust key as needed
  }

  Future<Map<String, dynamic>?> validateCoupon(String code) async {
    try {
      final token = await _getToken();
      print('Validating coupon: ${baseUri}coupons/validate/$code');
      final response = await _dio.get(
        'coupons/validate/$code',
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      print('Response: ${response.statusCode} ${response.data}');
      if (response.statusCode == 200) {
        return response.data;
      } else if (response.statusCode == 400 || response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to validate coupon: ${response.statusCode}');
      }
    } catch (e) {
      print('Error validating coupon: $e');
      throw Exception('Error validating coupon: $e');
    }
  }

  Future<bool> useCoupon(String code) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        'coupons/use/$code',
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error using coupon: $e');
    }
  }

  Future<bool> createCoupon(String code, double discountPercent) async {
    try {
      final token = await _getToken();
      final response = await _dio.post(
        'coupons',
        data: {
          'code': code,
          'discountPercent': discountPercent,
        },
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error creating coupon: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllCoupons() async {
    try {
      final token = await _getToken();
      final response = await _dio.get(
        'coupons',
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Failed to fetch coupons');
      }
    } catch (e) {
      throw Exception('Error fetching coupons: $e');
    }
  }

  Future<bool> updateCoupon(int id, String code, double discountPercent) async {
    try {
      final token = await _getToken();
      final response = await _dio.put(
        'coupons/$id',
        data: {
          'id': id,
          'code': code,
          'discountPercent': discountPercent,
        },
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error updating coupon: $e');
    }
  }

  Future<bool> deleteCoupon(int id) async {
    try {
      final token = await _getToken();
      final response = await _dio.delete(
        'coupons/$id',
        options: Options(headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting coupon: $e');
    }
  }
}
