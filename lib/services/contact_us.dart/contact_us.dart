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

  Future<Map<String, dynamic>> submitContactUsMessage(
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Message submitted successfully');
        return {'success': true, 'message': 'message_submitted_successfully'};
      } else {
        print('⚠️ Failed to submit message: Status ${response.statusCode}');
        return {
          'success': false,
          'message': 'failed_to_submit_message_status_${response.statusCode}'
        };
      }
    } on DioException catch (e) {
      final errorDetails = _handleDioError(e, 'submitContactUsMessage');
      return {'success': false, 'message': errorDetails};
    } catch (e) {
      print('❌ Unexpected error in submitContactUsMessage: $e');
      return {'success': false, 'message': 'unexpected_error'};
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

  String _handleDioError(DioException e, String methodName) {
    String errorMessage = '❌ [$methodName] ';
    String userMessage = 'an_error_occurred';

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage += 'Connection timeout';
        userMessage = 'connection_timed_out';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage += 'Send timeout';
        userMessage = 'request_timed_out';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage += 'Receive timeout';
        userMessage = 'server_response_timed_out';
        break;
      case DioExceptionType.badResponse:
        errorMessage +=
            'Bad response: ${e.response?.statusCode} ${e.response?.data}';
        if (e.response?.statusCode == 400 &&
            e.response?.data['Errors'] != null) {
          userMessage = (e.response?.data['Errors'] as List).join(', ');
        } else {
          userMessage = 'invalid_server_response';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage += 'Request cancelled';
        userMessage = 'request_cancelled';
        break;
      case DioExceptionType.connectionError:
        errorMessage += 'Connection error';
        userMessage = 'unable_to_connect';
        break;
      case DioExceptionType.unknown:
        errorMessage += 'Unknown error: ${e.message}';
        userMessage = 'unexpected_error';
        break;
      default:
        errorMessage += 'Other error: ${e.type}';
    }
    print(errorMessage);
    if (e.response != null) {
      print('Response data: ${e.response?.data}');
    }
    return userMessage;
  }
}
