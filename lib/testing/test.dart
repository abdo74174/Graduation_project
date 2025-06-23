import 'package:dio/dio.dart';
import 'package:graduation_project/core/constants/constant.dart';

class ShippingService {
  final Dio _dio = Dio(BaseOptions(baseUrl: baseUri));

  Future<Map<String, double>> getShippingPrices() async {
    try {
      final response = await _dio.get('ShippingPrice');
      final List<dynamic> data = response.data;
      return {
        for (var item in data) item['governorate']: item['price'].toDouble()
      };
    } catch (e) {
      throw Exception('Failed to fetch shipping prices: $e');
    }
  }

//   Future<Map<String, dynamic>> createPaymentIntent({
//     required double amount,
//     required String currency,
//     required int customerId,
//   }) async {
//     try {
//       final response = await _dio.post('Payment/CreateIntent', data: {
//         'amount': amount * 100, // Convert to cents
//         'currency': currency,
//         'customerId': customerId,
//       });
//       return response.data;
//     } catch (e) {
//       throw Exception('Failed to create payment intent: $e');
//     }
//   }

//   Future<Map<String, dynamic>> verifyPayment({
//     required String paymentIntentId,
//   }) async {
//     try {
//       final response = await _dio.get('Payment/Verify/$paymentIntentId');
//       return response.data;
//     } catch (e) {
//       throw Exception('Failed to verify payment: $e');
//     }
//   }

//   Future<Map<String, dynamic>> getCustomerCards(int customerId) async {
//     try {
//       final response = await _dio.get('Payment/Cards/$customerId');
//       return response.data;
//     } catch (e) {
//       throw Exception('Failed to fetch customer cards: $e');
//     }
//   }
}
