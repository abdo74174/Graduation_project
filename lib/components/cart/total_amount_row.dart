import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class TotalAmountRow extends StatelessWidget {
  final double totalAmount;

  const TotalAmountRow({
    super.key,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'cart_total'.tr(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '\$${totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
