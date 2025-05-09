import 'package:flutter/material.dart';
import 'package:graduation_project/Models/cart_item.dart';
import 'package:graduation_project/screens/payment/PaymentSuccessfulscreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/services/Order/order_service.dart';

class Paymentscreen extends StatelessWidget {
  final double total;
  final List<CartItem> cartItems;

  const Paymentscreen(
      {super.key, required this.total, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: Column(
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
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  int userId = 1; // Replace with actual user ID
                  List<Map<String, dynamic>> items = cartItems
                      .map((item) => {
                            'productId': item.productId,
                            'quantity': item.quantity,
                          })
                      .toList();

                  await OrderService().createOrder(userId, items);
                  Navigator.push(context, MaterialPageRoute(builder: (c) {
                    return PaymentSuccessScreen();
                  }));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to create order: $e')),
                  );
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
                'pay_now'.tr(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
