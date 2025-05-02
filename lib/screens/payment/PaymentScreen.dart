import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/screens/payment/PaymentSuccessfulscreen,dart';

class Paymentscreen extends StatelessWidget {
  const Paymentscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null,
      body: Column(
        children: [
          SizedBox(
            height: 60,
          ),
          Center(
            child: Text(
              "Payment".tr(),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Subtotal".tr(),
                style: TextStyle(fontSize: 30),
              ),
              Text(
                "\$70.00",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Shipping".tr(),
                style: TextStyle(fontSize: 30),
              ),
              Text(
                "\$5.00",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 35,
          ),
          Divider(
            indent: 60,
            endIndent: 60,
            thickness: .4,
            color: Colors.grey,
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                "Total",
                style: TextStyle(fontSize: 30),
              ),
              Text(
                "\$75.00",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 50,
          ),
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

          // Add New Card Button
          Center(
            child: TextButton(
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => const AddPaymentScreen()),
                // );
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
          SizedBox(
            height: 50,
          ),
          SizedBox(
            width: 200,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (c) {
                  return PaymentSuccessScreen();
                }));
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
