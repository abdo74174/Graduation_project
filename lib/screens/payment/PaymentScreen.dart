import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/cart_item.dart';
import 'package:graduation_project/screens/payment/PaymentSuccessfulscreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/services/Cart/car_service.dart';
import 'package:graduation_project/services/Order/order_service.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';

class Paymentscreen extends StatefulWidget {
  final double total;
  final List<CartItem> cartItems;

  const Paymentscreen(
      {super.key, required this.total, required this.cartItems});

  @override
  State<Paymentscreen> createState() => _PaymentscreenState();
}

class _PaymentscreenState extends State<Paymentscreen> {
  String _selectedPaymentMethod = 'card';

  Future<bool> _processPayment(BuildContext context, double amount) async {
    try {
      // Initialize Stripe with your publishable key
      Stripe.publishableKey = 'your_stripe_publishable_key_here';
      await Stripe.instance.applySettings();

      // Create a payment intent on your server
      final paymentIntent = await _createPaymentIntent(amount);

      // Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Your Store Name',
          allowsDelayedPaymentMethods: true,
        ),
      );

      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
      return false;
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent(double amount) async {
    // Implement this function to call your backend to create a payment intent
    // Example using Dio or http to call your server
    // This is a placeholder; replace with your actual backend endpoint
    final dio = Dio();
    final response = await dio.post(
      'https://your-backend-api.com/create-payment-intent',
      data: {
        'amount': (amount * 100).toInt(), // Amount in cents
        'currency': 'usd',
      },
    );

    return response.data;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.total;
    final cartItems = widget.cartItems;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: ListView(
        children: [
          const SizedBox(height: 60),
          Center(
            child: Text(
              "Payment".tr(),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Subtotal".tr(), style: const TextStyle(fontSize: 30)),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 30, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Shipping".tr(), style: const TextStyle(fontSize: 30)),
              const Text(
                "\$5.00",
                style: TextStyle(fontSize: 30, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 35),
          const Divider(
            indent: 60,
            endIndent: 60,
            thickness: 0.4,
            color: Colors.grey,
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Text("Total", style: TextStyle(fontSize: 30)),
              Text(
                "\$${(total + 5.0).toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 30),
              ),
            ],
          ),
          const SizedBox(height: 50),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 40),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/0/04/Visa.svg',
                  width: 40,
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.credit_card),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '•••• •••• •••• 4242',
                    style: TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: TextButton(
              onPressed: () {
                // Navigate to add new card screen if needed
              },
              child: SizedBox(
                width: 200,
                child: Row(
                  children: [
                    const Icon(Icons.add, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text('add_new_card'.tr(),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 24,
                        )),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          // Payment method selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Select Payment Method".tr(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                ListTile(
                  title: Text("Pay with Card".tr()),
                  leading: Radio<String>(
                    value: 'card',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value!;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: Text("Pay when Shipped (Cash on Delivery)".tr()),
                  leading: Radio<String>(
                    value: 'cod',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) {
                      setState(() {
                        _selectedPaymentMethod = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: TextButton(
              onPressed: () {
                // Navigate to add new card screen if needed
              },
              child: SizedBox(
                width: 200,
                child: Row(
                  children: [
                    const Icon(Icons.add, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text('add_new_card'.tr(),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 24,
                        )),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () async {
                bool paymentSuccessful = false;
                if (_selectedPaymentMethod == 'card') {
                  paymentSuccessful =
                      await _processPayment(context, total + 5.0);
                } else {
                  paymentSuccessful = true; // Assume COD always succeeds
                }
                if (paymentSuccessful) {
                  try {
                    int userId = int.parse(await UserServicee().getUserId() ??
                        '0'); // Replace with actual user ID
                    List<Map<String, dynamic>> items = cartItems
                        .map((item) => {
                              'productId': item.productId,
                              'quantity': item.quantity,
                            })
                        .toList();

                    await OrderService().createOrder(userId, items);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) {
                          return const PaymentSuccessScreen();
                        },
                      ),
                    ).then((_) async {
                      for (var item in items) {
                        await CartService().deleteFromCart(item['productId']);
                      }
                      setState(() {
                        widget.cartItems.clear();
                      });
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to create order: \$e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4285F4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _selectedPaymentMethod == 'card'
                    ? 'pay_now'.tr()
                    : 'confirm_order'.tr(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
