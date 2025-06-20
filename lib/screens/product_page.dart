import 'package:flutter/material.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/components/productc/product.dart';
import 'package:graduation_project/components/productc/product_images.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/services/Cart/cart_service.dart';
import 'package:graduation_project/services/Product/product_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/services/Product/recommendation_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:graduation_project/services/Rating/rating_service.dart';
import 'package:graduation_project/services/User/sign.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  bool _isLoading = true;
  bool _isCommentsLoading = false;
  bool _showDummy = false;
  double _userRating = 3.0;
  double _averageRating = 0.0;
  TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];

  @override
  void initState() {
    super.initState();
    loadRecommendations();
    fetchAverageRatingAndComments();
    Future.delayed(Duration(seconds: 7), () {
      if (mounted && products.isEmpty) {
        setState(() {
          _showDummy = true;
          _isLoading = false;
        });
      }
    });
  }

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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<String> getEmailFromUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? '';
  }

  Future<void> fetchAverageRatingAndComments() async {
    setState(() {
      _isCommentsLoading = true;
    });
    try {
      final ratings = await RatingService()
          .getRatings(productId: widget.product.productId.toString());
      // Debug log
      if (ratings.isNotEmpty) {
        double total = ratings.fold(
            0.0, (sum, item) => sum + (item['ratingValue'] as int).toDouble());
        setState(() {
          _averageRating = total / ratings.length;
        });
        _comments = await Future.wait(ratings.map((item) async {
          final email = await getEmailFromUserId(item['userId']);
          final userData = await USerService().fetchUserByEmail(email);
          // Debug log
          return {
            'comment': item['comment']?.isNotEmpty == true
                ? item['comment']
                : 'No comment provided',
            'rating': item['ratingValue'],
            'userName': userData?.name ?? 'Anonymous',
            'profileImage': userData?.profileImage ??
                null, // Changed to null to trigger local asset
          };
        }).toList());
        // Debug log
      } else {
        setState(() {
          _comments = [];
        });
      }
    } catch (e) {
      setState(() {
        _comments = [];
      });
    } finally {
      setState(() {
        _isCommentsLoading = false;
      });
    }
  }

  void _submitRating() async {
    try {
      await RatingService().submitRating(
        productId: widget.product.productId.toString(),
        userId: 'user123', // Ensure this is a string
        rating: _userRating.toInt(),
        comment:
            _commentController.text.isNotEmpty ? _commentController.text : null,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Rating and comment submitted successfully!'.tr())),
      );
      _commentController.clear();
      setState(() {
        _userRating = 0.0;
      });
      // Refresh comments after submission
      await fetchAverageRatingAndComments();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: $e'.tr())),
      );
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
                              _averageRating.toStringAsFixed(1),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color:
                                  widget.product.isNew ? pkColor : Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.product.isNew ? "New".tr() : "Used".tr(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(width: 5),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
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
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.productPage,
                                      arguments: ProductPageArguments(
                                          product: dummyProducts[index]),
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
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.productPage,
                                      arguments: ProductPageArguments(
                                          product: products[index]),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
              ),

              // Rating and Comment Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rate this product'.tr(),
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    RatingBar.builder(
                      initialRating: _userRating,
                      minRating: 1,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemBuilder: (context, _) =>
                          Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (rating) {
                        setState(() {
                          _userRating = rating;
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Leave a comment'.tr(),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitRating,
                        child: Text('Submit'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pkColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                        ),
                      ),
                    ),

                    // Comments Section
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Comments'.tr(),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          _isCommentsLoading
                              ? Center(child: CircularProgressIndicator())
                              : _comments.isEmpty
                                  ? Text('No comments yet.'.tr(),
                                      style: TextStyle(color: Colors.grey))
                                  : Column(
                                      children: _comments
                                          .map((comment) => Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 5),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundImage: comment[
                                                                      'profileImage'] !=
                                                                  null &&
                                                              comment['profileImage']
                                                                  .startsWith(
                                                                      'http')
                                                          ? NetworkImage(comment[
                                                              'profileImage'])
                                                          : AssetImage(
                                                                  'assets/images/user (1).png')
                                                              as ImageProvider,
                                                      radius: 20,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              comment[
                                                                  'userName'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text(
                                                              'Rating: ${comment['rating']}',
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold)),
                                                          Text(comment[
                                                              'comment']),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                    ),
                        ],
                      ),
                    ),
                  ],
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
                        widget.product.discount > 0
                            ? Text(
                                "${widget.product.price} EGP ",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.red,
                                  decorationThickness: 2,
                                ),
                              )
                            : Text(
                                "No Discount",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                        Text(
                          "${getDiscountedPrice(widget.product)} EGP ",
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
                          1,
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(tr('product_page.add_to_cart'))),
                        );
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
