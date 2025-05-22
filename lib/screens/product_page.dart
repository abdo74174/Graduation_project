import 'package:flutter/material.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/components/productc/product.dart';
import 'package:graduation_project/components/productc/product_images.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/services/Cart/car_service.dart';
import 'package:graduation_project/services/Product/product_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/services/Product/recommendation_service.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, required this.product});
  final ProductModel product;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  double getDiscountedPrice(ProductModel product) {
    double discountedPrice =
        product.price - (product.price * product.discount / 100);
    discountedPrice = (discountedPrice * 100).toInt() / 100;
    return discountedPrice;
  }

  List<ProductModel> products = [];
  // List<ProductModel> recommendedProducts = [];
  bool _isLoading = true;
  bool _showDummy = false;

  @override
  void initState() {
    super.initState();
    loadRecommendations();
    Future.delayed(Duration(seconds: 7), () {
      if (mounted && products.isEmpty) {
        setState(() {
          _showDummy = true;
          _isLoading = false;
        });
      }
    });
  }

  // Future<void> loadProducts() async {
  //   try {
  //     final fetchedProducts = await ProductService().fetchAllProducts();
  //     if (mounted) {
  //       setState(() {
  //         products = fetchedProducts;
  //         _isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     print("⚠️ Error loading products: $e");
  //     if (mounted) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     }
  //   }
  // }

  Future<void> loadRecommendations() async {
    try {
      final fetchedProducts = await RecommendationService()
          .fetchRecommendations(widget.product.productId);
      if (mounted) {
        setState(() {
          products = fetchedProducts.cast<ProductModel>();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("⚠️ Error loading recommendations: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor = isDark ? Color(0xFF333333) : Color(0xFFF8F9FA);
    Color textColor = isDark ? Colors.white : Color(0xFF333333);
    Color priceColor = isDark ? Colors.white : Colors.black;
    Color saleBadgeColor = isDark ? pkColor.withOpacity(0.7) : pkColor;
    Color dividerColor = isDark ? Colors.white30 : Colors.grey;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: null,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(bottom: 120),
            children: [
              // Product images carousel
              SizedBox(
                height: 400,
                child: PageView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.product.images.isEmpty
                      ? 1
                      : widget.product.images.length,
                  itemBuilder: (context, index) {
                    final fullImageUrl = widget.product.images.isEmpty
                        ? defaultProductImage
                        : widget.product.images[index];

                    return ImageWidget(
                      productId: widget.product.productId,
                      image: fullImageUrl,
                    );
                  },
                ),
              ),

              // Product Name and Sale Badge
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: saleBadgeColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      width: 100,
                      height: 40,
                      child: Center(
                        child: Text(
                          tr('product_page.on_sale'),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Rating and Review Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      width: 100,
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.star,
                                color: Color(0xFFFFD700),
                                size: 25,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              "4.8",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 7),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      width: 100,
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.thumb_up,
                                color: pkColor,
                                size: 25,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              "94",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(tr('product_page.reviews'),
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),

              // Product Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.product.description,
                  style: TextStyle(fontSize: 16, color: textColor),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Divider
              Divider(color: dividerColor, thickness: .5),

              // Related Products
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  tr('product_page.related_products'),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor),
                ),
              ),

              SizedBox(height: 20),

              // Horizontal List of Related Products
              SizedBox(
                height: 300,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _showDummy || products.isEmpty
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: dummyProducts.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: ProductCard(
                                  product: dummyProducts[index],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ProductPage(
                                              product: dummyProducts[index]);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 15),
                                child: ProductCard(
                                  product: products[index],
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ProductPage(
                                              product: products[index]);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),

          // Bottom Bar with Add to Cart Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price and Discounted Price
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "\$${widget.product.price}",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Colors.red,
                            decorationThickness: 2,
                          ),
                        ),
                        Text(
                          "\$${getDiscountedPrice(widget.product)}",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Add to Cart Button
                  SizedBox(
                    width: 200,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        CartService().addToCart(
                          widget.product.productId,
                          2,
                        );
                        showSnackbar(context, tr('product_page.add_to_cart'));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pkColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        tr('product_page.add_to_cart'),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
