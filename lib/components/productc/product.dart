import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/core/constants/constant.dart';

class _Dim {
  static const double cardWidth = 180;
  static const double cardHeight = 380;
  static const double borderRadius = 12;
  static const double imageHeight = 120;
  static const double badgePaddingH = 8;
  static const double badgePaddingV = 4;
  static const double badgeFontSize = 12;
  static const double titleFontSize = 13;
  static const double priceFontSize = 15;
  static const double iconSize = 16;
  static const double buttonHeight = 30;
  static const double buttonFontSize = 12;
  static const double paddingSmall = 4;
  static const double paddingMedium = 8;
  static const double shadowBlur = 8;
  static const Offset shadowOffset = Offset(0, 2);
}

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final bool isOwner;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isOwner = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onDelete,
      child: Container(
        width: _Dim.cardWidth,
        height: _Dim.cardHeight,
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(_Dim.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: _Dim.shadowBlur,
              offset: _Dim.shadowOffset,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image and sale badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(_Dim.borderRadius),
                    topRight: Radius.circular(_Dim.borderRadius),
                  ),
                  child: product.images?.isNotEmpty == true
                      ? Image.network(
                          product.images[0],
                          width: double.infinity,
                          height: _Dim.imageHeight,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            defaultProductImage,
                            width: double.infinity,
                            height: _Dim.imageHeight,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          defaultProductImage,
                          width: double.infinity,
                          height: _Dim.imageHeight,
                          fit: BoxFit.cover,
                        ),
                ),
                if (product.discount > 0)
                  Positioned(
                    top: _Dim.paddingSmall,
                    left: _Dim.paddingSmall,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: _Dim.badgePaddingH,
                        vertical: _Dim.badgePaddingV,
                      ),
                      decoration: BoxDecoration(
                        color: pkColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${product.discount} ${'OFF'.tr()}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _Dim.badgeFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Product details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(_Dim.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: _Dim.titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: _Dim.paddingSmall),
                    // Product description
                    Text(
                      product.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: _Dim.titleFontSize - 1,
                        color: isDark ? Colors.white70 : Colors.black54,
                        height: 1.1,
                      ),
                    ),
                    const Spacer(),
                    // Price and button section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (product.discount > 0)
                          Text(
                            '${'currency_symbol'.tr()}${(product.price ?? 0).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: _Dim.priceFontSize - 2,
                              decoration: TextDecoration.lineThrough,
                              color: isDark ? Colors.white38 : Colors.black38,
                            ),
                          ),
                        Text(
                          '${'currency_symbol'.tr()}${((product.price ?? 0) * (1 - (product.discount ?? 0) / 100)).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: _Dim.priceFontSize,
                            fontWeight: FontWeight.bold,
                            color: pkColor,
                          ),
                        ),
                        if (!isOwner) ...[
                          SizedBox(height: _Dim.paddingSmall),
                          SizedBox(
                            width: double.infinity,
                            height: _Dim.buttonHeight,
                            child: ElevatedButton(
                              onPressed: onTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: pkColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 4 : 6,
                                ),
                              ),
                              child: Text(
                                'add_to_cart'.tr(),
                                style: TextStyle(
                                  fontSize: _Dim.buttonFontSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
