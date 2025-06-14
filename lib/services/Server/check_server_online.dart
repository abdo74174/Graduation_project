// lib/services/Server/check_server_online.dart

import 'package:dio/dio.dart';
import 'package:graduation_project/core/constants/constant.dart';

class CheckServerOnline {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Returns true if GET /api/Health/status returns HTTP 200 within 10 s.
  Future<bool> checkServer() async {
    try {
      final resp = await _dio.get('${baseUri}Health/status');
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
