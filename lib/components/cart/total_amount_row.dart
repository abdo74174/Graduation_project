import 'package:flutter/material.dart';

class totalAmountRow extends StatelessWidget {
  totalAmountRow({super.key, totalAmount});
  dynamic totalAmount;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Total Amount',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('\$$totalAmount',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ],
    );
  }
}
