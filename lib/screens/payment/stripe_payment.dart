// import 'dart:math' as Logger show log;

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:graduation_project/Models/cart_item.dart';
// import 'package:graduation_project/screens/payment/PaymentSuccessfulscreen.dart';
// import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
// import 'package:graduation_project/services/payment/payment_service.dart';

// class StripePaymentScreen extends StatefulWidget {
//   final double total;
//   final List<CartItems> cartItems;

//   const StripePaymentScreen({
//     super.key,
//     required this.total,
//     required this.cartItems,
//   });

//   @override
//   State<StripePaymentScreen> createState() => _StripePaymentScreenState();
// }

// class _StripePaymentScreenState extends State<StripePaymentScreen> {
//   bool _isProcessing = false;
//   CardFieldInputDetails? _cardDetails;
//   final PaymentService _paymentService = PaymentService();
//   int? userId;

//   @override
//   void initState() {
//     super.initState();
//     Logger.log('StripePaymentScreen.initState' as num);
//     getUserId();
//   }

//   Future getUserId() async {
//     const method = 'StripePaymentScreen.getUserId';
//     final id = await UserServicee().getUserId();
//     if (id == null || id.isEmpty) {
//       Logger.log('User ID not available' as num);
//       throw Exception('User ID not available');
//     }
//     userId = int.parse(id);
//     Logger.log(method, 'Set userId: $userId');
//   }

//   Future<bool> _processPayment() async {
//     const method = 'StripePaymentScreen._processPayment';
//     Logger.log(method, 'Starting payment process');

//     try {
//       setState(() => _isProcessing = true);

//       if (userId == null) {
//         Logger.log(method, 'User ID is null');
//         throw Exception('User ID not available');
//       }

//       final paymentIntent = await _paymentService.createPaymentIntent(
//         customerId: userId!,
//         amount: (widget.total + 5.0),
//         currency: 'egp',
//       );
//       Logger.log(method, 'Payment intent created: ${paymentIntent['id']}');

//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntent['client_secret'],
//           merchantDisplayName: 'Medical Store',
//           allowsDelayedPaymentMethods: true,
//           style: ThemeMode.light,
//           googlePay: const PaymentSheetGooglePay(
//             merchantCountryCode: 'EG',
//             testEnv: true,
//           ),
//           applePay: const PaymentSheetApplePay(
//             merchantCountryCode: 'EG',
//           ),
//         ),
//       );
//       Logger.log(method, 'Payment sheet initialized');

//       await Stripe.instance.presentPaymentSheet();
//       Logger.log(method, 'Payment sheet presented');

//       final paymentStatus = await _paymentService.verifyPayment(
//         paymentIntentId: paymentIntent['id'],
//       );
//       Logger.log(method, 'Payment status: ${paymentStatus['status']}');

//       if (paymentStatus['status'] == 'succeeded') {
//         await _paymentService.savePayment(
//           userId: userId.toString(),
//           amount: widget.total + 5.0,
//           paymentIntentId: paymentIntent['id'],
//           cartItems: widget.cartItems,
//         );
//         Logger.log(method, 'Payment saved successfully');
//         return true;
//       }
//       return false;
//     } catch (e, stackTrace) {
//       Logger.log(method, 'Payment failed: $e\n$stackTrace');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('payment_failed'.tr(args: [e.toString()]))),
//         );
//       }
//       return false;
//     } finally {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//         Logger.log(method, 'Payment process completed');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     const method = 'StripePaymentScreen.build';
//     Logger.log(method, 'Building UI');

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('stripe_payment'.tr()),
//         backgroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'payment_details'.tr(),
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             CardField(
//               onCardChanged: (card) {
//                 setState(() {
//                   _cardDetails = card;
//                 });
//               },
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 labelText: 'card_details'.tr(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey.shade300),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('total'.tr(), style: const TextStyle(fontSize: 18)),
//                   Text(
//                     '${(widget.total + 5.0).toStringAsFixed(2)} EGP',
//                     style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             const Spacer(),
//             ElevatedButton(
//               onPressed: _isProcessing || _cardDetails?.complete != true
//                   ? null
//                   : () async {
//                       final success = await _processPayment();
//                       if (success && mounted) {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const PaymentSuccessScreen(),
//                           ),
//                         );
//                       }
//                     },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF4285F4),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: _isProcessing
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : Text(
//                       'pay_now'.tr(),
//                       style: const TextStyle(color: Colors.white, fontSize: 16),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
