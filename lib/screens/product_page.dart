import 'package:flutter/material.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/components/productc/product.dart';
import 'package:graduation_project/components/productc/product_images.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/Cart/car_service.dart';
import 'package:graduation_project/services/Product/product_service.dart';

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

  @override
  void initState() {
    super.initState();
    ProductService().fetchAllProducts().then((fetchedProducts) {
      setState(() {
        products = fetchedProducts;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
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
                  itemCount: widget.product.images.length,
                  itemBuilder: (context, index) {
                    final fullImageUrl = widget.product.images[index];
                    return ImageWidget(
                        productId: widget.product.productId,
                        image: fullImageUrl); // Custom widget to display image
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
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: pkColor, // Sale Badge Color
                        borderRadius: BorderRadius.circular(16),
                      ),
                      width: 100,
                      height: 40,
                      child: Center(
                        child: Text(
                          "% On Sale",
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
                                color: Color(0xFF333333),
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
                                // color: Color(0xFF008000), // Green Color
                                color: pkColor, // Green Color
                                size: 25,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              "94",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text("12 reviews", style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),

              // Product Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  widget.product.description,
                  style: TextStyle(fontSize: 16),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Divider
              Divider(color: Colors.grey, thickness: .5),

              // Related Products
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Products Related to This Item:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              // Horizontal List of Related Products
              SizedBox(
                height: 300,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: ProductCard(
                        product: products[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return ProductPage(product: products[index]);
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
                            color: Colors.grey,
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
                            color: Colors.black,
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
                        showSnackbar(context, "Added To Cart Successfully");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pkColor, // Green color for the button
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: Text(
                        "Add To Cart",
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

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
