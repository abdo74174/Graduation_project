import 'package:dio/dio.dart';
import 'package:graduation_project/core/constants/constant.dart';

class DashboardService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUri, // change to your real base URL
      headers: {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer YOUR_TOKEN' // if using JWT
      },
    ),
  );

  Future<Map<String, dynamic>> getDashboardSummary() async {
    try {
      final response = await _dio.get('/dashboard/summary');
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load dashboard summary');
      }
    } catch (e) {
      print('Error fetching dashboard summary: $e');
      rethrow;
    }
  }
}
