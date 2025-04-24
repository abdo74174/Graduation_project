import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class CartItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final int price;
  final String oldPrice;
  final int quantity;
  final Function(int) onQuantityChanged;

  const CartItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.price,
    required this.oldPrice,
    required this.quantity,
    required this.onQuantityChanged,
    required product,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(imagePath, width: 100, height: 100, fit: BoxFit.cover),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${'currency_symbol'.tr()}$price',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 10),
            if (oldPrice.isNotEmpty)
              Text(
                '${'currency_symbol'.tr()}$oldPrice',
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'quantity'.tr(),
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => onQuantityChanged(quantity - 1),
              icon: const Icon(Icons.remove),
            ),
            Text(
              '$quantity',
              style: const TextStyle(fontSize: 16),
            ),
            IconButton(
              onPressed: () => onQuantityChanged(quantity + 1),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}
