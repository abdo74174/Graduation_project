import 'package:dio/dio.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/models/contact_us_model.dart';

class ContactUsService {
  static final String baseUrl = '${baseUri}ContactUs';
  late final Dio _dio;

  ContactUsService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => status! < 500,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🌐 [DIO REQUEST] ${options.method} ${options.uri}');
        print('Headers: ${options.headers}');
        print('Body: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ [DIO RESPONSE] Status: ${response.statusCode}');
        print('Data: ${response.data}');
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print('❌ [DIO ERROR] Type: ${e.type}');
        print('Error: ${e.message}');
        if (e.response != null) {
          print('Status: ${e.response?.statusCode}');
          print('Response Data: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ));
  }

  Future<bool> submitContactUsMessage(
      String problemType, String message, String? email) async {
    try {
      final response = await _dio.post(
        '',
        data: {
          'problemType': problemType,
          'message': message,
          'email': email,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Message submitted successfully');
        return true;
      } else {
        print('⚠️ Failed to submit message: Status ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      _handleDioError(e, 'submitContactUsMessage');
      return false;
    } catch (e) {
      print('❌ Unexpected error in submitContactUsMessage: $e');
      return false;
    }
  }

  Future<List<ContactUsModel>> getContactUsMessages() async {
    try {
      final response = await _dio.get('');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        print('✅ Fetched ${data.length} messages');
        return data.map((json) => ContactUsModel.fromJson(json)).toList();
      } else {
        print('⚠️ Failed to fetch messages: Status ${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      _handleDioError(e, 'getContactUsMessages');
      return [];
    } catch (e) {
      print('❌ Unexpected error in getContactUsMessages: $e');
      return [];
    }
  }

  void _handleDioError(DioException e, String methodName) {
    String errorMessage = '❌ [$methodName] ';
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage += 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage += 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage += 'Receive timeout';
        break;
      case DioExceptionType.badResponse:
        errorMessage +=
            'Bad response: ${e.response?.statusCode} ${e.response?.data}';
        break;
      case DioExceptionType.cancel:
        errorMessage += 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMessage += 'Connection error';
        break;
      case DioExceptionType.unknown:
        errorMessage += 'Unknown error: ${e.message}';
        break;
      default:
        errorMessage += 'Other error: ${e.type}';
    }
    print(errorMessage);
    if (e.response != null) {
      print('Response data: ${e.response?.data}');
    }
  }
}
