import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/components/productc/product.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/screens/product_page.dart';

class DiscountedProductsPage extends StatelessWidget {
  final List<ProductModel> products;

  const DiscountedProductsPage({Key? key, required this.products})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final discountedProducts =
        products.where((product) => product.discount > 50).toList();

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Special Offers'.tr(), style: TextStyle(color: Colors.white)),
        backgroundColor: pkColor,
      ),
      body: discountedProducts.isEmpty
          ? Center(
              child: Text(
                'No special offers available at the moment'.tr(),
                style: TextStyle(color: Colors.white),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: discountedProducts.length,
              itemBuilder: (context, index) {
                return ProductCard(
                  product: discountedProducts[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductPage(
                          product: discountedProducts[index],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
