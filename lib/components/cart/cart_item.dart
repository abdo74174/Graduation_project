import 'package:flutter/material.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(imagePath, width: 100, height: 100, fit: BoxFit.cover),
        const SizedBox(height: 5),
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('\$$price',
                style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(width: 10),
            if (oldPrice.isNotEmpty)
              Text('\$$oldPrice',
                  style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
