import 'package:flutter/material.dart';
import 'package:graduation_project/Models/product_model.dart';

class _Dim {
  static const double cardWidth = 160;
  static const double borderRadius = 16;
  static const double imageHeight = 110;
  static const double badgePaddingH = 6;
  static const double badgePaddingV = 2;
  static const double badgeFontSize = 10;
  static const double titleFontSize = 13;
  static const double iconSize = 12;
  static const double buttonHeight = 30;
  static const double buttonFontSize = 12;
  static const double paddingSmall = 6;
  static const double paddingMedium = 8;
  static const double shadowBlur = 6;
  static const Offset shadowOffset = Offset(0, 3);
}

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _Dim.paddingMedium,
        vertical: _Dim.paddingMedium / 2,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_Dim.borderRadius),
        child: Container(
          width: _Dim.cardWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_Dim.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.grey.shade100],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: _Dim.shadowBlur,
                offset: _Dim.shadowOffset,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image + Badge
              Stack(
                children: [
                  ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(_Dim.borderRadius),
                      ),
                      child: Image.network(
                        product.images.isNotEmpty
                            ? product.images[0]
                            : 'https://via.placeholder.com/150',
                        height: _Dim.imageHeight,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          height: _Dim.imageHeight,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.broken_image,
                            size: _Dim.imageHeight / 3,
                            color: Color(0xff3B8FDA),
                          ),
                        ),
                      )),
                  Positioned(
                    top: _Dim.paddingSmall,
                    right: _Dim.paddingSmall,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: _Dim.badgePaddingH,
                        vertical: _Dim.badgePaddingV,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xff3B8FDA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "\$${product.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: _Dim.badgeFontSize,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Info + Button
              Padding(
                padding: const EdgeInsets.all(_Dim.paddingSmall),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: _Dim.titleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: _Dim.paddingSmall),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star,
                            size: _Dim.iconSize, color: Colors.amber),
                        const SizedBox(width: _Dim.paddingSmall / 2),
                        Text(
                          product.discount.toStringAsFixed(1),
                          style: TextStyle(fontSize: _Dim.iconSize),
                        ),
                      ],
                    ),
                    const SizedBox(height: _Dim.paddingSmall),
                    SizedBox(
                      height: _Dim.buttonHeight,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(_Dim.borderRadius / 2),
                          ),
                          elevation: 1,
                          backgroundColor: Colors.blueAccent,
                        ),
                        child: Text(
                          "Buy",
                          style: TextStyle(
                            fontSize: _Dim.buttonFontSize,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
