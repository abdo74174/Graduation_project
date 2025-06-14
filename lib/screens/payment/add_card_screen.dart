import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderNameController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _saveCard() async {
    try {
      setState(() => _isProcessing = true);
      debugPrint("[AddCardScreen._saveCard] Starting card save process...");

      // Create a setup intent
      final setupIntent = await _createSetupIntent();
      debugPrint(
          "[AddCardScreen._saveCard] Setup intent created: ${setupIntent['client_secret']}");

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          setupIntentClientSecret: setupIntent['client_secret'],
          merchantDisplayName: 'Medical Store',
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'EG',
            testEnv: true,
          ),
          // Apple Pay disabled for testing (requires merchantIdentifier)
          applePay: null,
        ),
      );
      debugPrint("[AddCardScreen._saveCard] Payment sheet initialized");

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();
      debugPrint("[AddCardScreen._saveCard] Payment sheet presented");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('card_added_successfully'.tr())),
        );
        Navigator.pop(context, true); // Return success status
      }
    } on StripeException catch (e) {
      debugPrint(
          "[AddCardScreen._saveCard] StripeException: ${e.error.localizedMessage}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('failed_to_add_card'
                .tr(args: [e.error.localizedMessage ?? 'Unknown error'])),
          ),
        );
      }
    } on DioException catch (e) {
      debugPrint("[AddCardScreen._saveCard] DioException: ${e.message}");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('network_error'.tr(args: [e.message ?? 'Unknown error'])),
          ),
        );
      }
    } catch (e) {
      debugPrint("[AddCardScreen._saveCard] General Exception: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('failed_to_add_card'.tr(args: [e.toString()]))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<Map<String, dynamic>> _createSetupIntent() async {
    try {
      final dio = Dio();
      final userId = await _getUserId();
      debugPrint(
          "[AddCardScreen._createSetupIntent] Creating setup intent for userId: $userId");

      // Bypass SSL verification for development (remove in production)
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };

      final response = await dio.post(
        'https://10.0.2.2:7273/api/payments/create-setup-intent',
        data: {'customerId': int.parse(userId)}, // Convert userId to int
        options: Options(
          validateStatus: (status) =>
              status != null && status < 500, // Accept 200-499
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.data is! Map<String, dynamic>) {
        debugPrint(
            "[AddCardScreen._createSetupIntent] Invalid response: ${response.data}");
        throw Exception('Invalid API response format');
      }

      debugPrint(
          "[AddCardScreen._createSetupIntent] Response: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint(
          "[AddCardScreen._createSetupIntent] Setup intent creation failed: $e");
      throw Exception('Setup intent creation failed: $e');
    }
  }

  Future<String> _getUserId() async {
    try {
      final userId = await UserServicee().getUserId();
      if (userId == null || userId.isEmpty) {
        debugPrint("[AddCardScreen._getUserId] User ID not available");
        throw Exception('User ID not available');
      }
      debugPrint("[AddCardScreen._getUserId] User ID: $userId");
      return userId;
    } catch (e) {
      debugPrint("[AddCardScreen._getUserId] Failed to get user ID: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _cvvController.dispose();
    _cardHolderNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_new_card'.tr()),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'add_new_card'.tr(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cardHolderNameController,
              decoration: InputDecoration(
                labelText: 'card_holder_name'.tr(),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _cardNumberController,
              decoration: InputDecoration(
                labelText: 'card_number'.tr(),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryDateController,
                    decoration: InputDecoration(
                      labelText: 'expiry_date'.tr(),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    decoration: InputDecoration(
                      labelText: 'cvv'.tr(),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isProcessing ? null : _saveCard,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'add'.tr(),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
