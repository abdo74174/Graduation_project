import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LatestProductsCard extends StatelessWidget {
  final List<dynamic> products;

  const LatestProductsCard({required this.products, super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'latest_products'.tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            products.isEmpty
                ? Text('no_products_available'.tr())
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product['name'] ?? 'unknown'.tr()),
                        subtitle: Text(
                          '${'price'.tr()}: ${formatter.format(product['price'] ?? 0.0)}\n'
                          '${'created'.tr()}: ${DateFormat('MMM dd, yyyy hh:mm a').format(DateTime.parse(product['createdAt'] ?? DateTime.now().toIso8601String()).toLocal())}',
                        ),
                        leading:
                            const Icon(Icons.inventory_2, color: Colors.blue),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
