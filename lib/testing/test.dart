// import 'package:flutter/material.dart';
// import 'package:graduation_project/Models/product_model.dart';
// import 'package:graduation_project/components/productc/product.dart';
// import 'package:graduation_project/components/productc/product_images.dart';
// import 'package:graduation_project/core/constants/constant.dart';
// import 'package:graduation_project/core/constants/dummy_static_data.dart';
// import 'package:graduation_project/services/Cart/cart_service.dart';
// import 'package:graduation_project/services/Product/product_service.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:graduation_project/services/Product/recommendation_service.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:graduation_project/services/Rating/rating_service.dart';
// import 'package:graduation_project/services/User/sign.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:graduation_project/routes.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class ProductPage extends StatefulWidget {
//   const ProductPage({super.key, required this.product});
//   final ProductModel product;

//   @override
//   State<ProductPage> createState() => _ProductPageState();
// }

// class _ProductPageState extends State<ProductPage> {
//   double getDiscountedPrice(ProductModel product) {
//     double discountedPrice =
//         product.price - (product.price * product.discount / 100);
//     discountedPrice = (discountedPrice * 100).toInt() / 100;
//     return discountedPrice;
//   }

//   List<ProductModel> products = [];
//   bool _isLoading = true;
//   bool _isCommentsLoading = false;
//   bool _showDummy = false;
//   double _userRating = 3.0;
//   double _averageRating = 0.0;
//   int _totalReviews = 0;
//   TextEditingController _commentController = TextEditingController();
//   List<Map<String, dynamic>> _comments = [];

//   @override
//   void initState() {
//     super.initState();
//     loadRecommendations();
//     fetchAverageRatingAndComments();
//     Future.delayed(Duration(seconds: 7), () {
//       if (mounted && products.isEmpty) {
//         setState(() {
//           _showDummy = true;
//           _isLoading = false;
//         });
//       }
//     });
//   }

//   Future<void> loadRecommendations() async {
//     try {
//       final fetchedProducts = await RecommendationService()
//           .fetchRecommendations(widget.product.productId);
//       if (mounted) {
//         setState(() {
//           products = fetchedProducts.cast<ProductModel>();
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<String> getEmailFromUserId(String userId) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('email') ?? '';
//   }

//   Future<void> fetchAverageRatingAndComments() async {
//     setState(() {
//       _isCommentsLoading = true;
//     });
//     try {
//       final ratings = await RatingService()
//           .getRatings(productId: widget.product.productId.toString());
      
//       if (ratings.isNotEmpty) {
//         double total = ratings.fold(
//             0.0, (sum, item) => sum + (item['ratingValue'] as int).toDouble());
//         setState(() {
//           _averageRating = total / ratings.length;
//           _totalReviews = ratings.length;
//         });
//         _comments = await Future.wait(ratings.map((item) async {
//           final email = await getEmailFromUserId(item['userId']);
//           final userData = await USerService().fetchUserByEmail(email);
          
//           return {
//             'comment': item['comment']?.isNotEmpty == true
//                 ? item['comment']
//                 : 'No comment provided',
//             'rating': item['ratingValue'],
//             'userName': userData?.name ?? 'Anonymous',
//             'profileImage': userData?.profileImage ?? null,
//             'date': DateTime.now().subtract(Duration(days: Random().nextInt(30))),
//           };
//         }).toList());
//       } else {
//         setState(() {
//           _comments = [];
//           _averageRating = 0.0;
//           _totalReviews = 0;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _comments = [];
//         _averageRating = 0.0;
//         _totalReviews = 0;
//       });
//     } finally {
//       setState(() {
//         _isCommentsLoading = false;
//       });
//     }
//   }

//   void _submitRating() async {
//     if (_userRating == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please select a rating'.tr())),
//       );
//       return;
//     }

//     try {
//       await RatingService().submitRating(
//         productId: widget.product.productId.toString(),
//         userId: 'user123',
//         rating: _userRating.toInt(),
//         comment:
//             _commentController.text.isNotEmpty ? _commentController.text : null,
//       );
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//             content: Text('Rating and comment submitted successfully!'.tr())),
//       );
//       _commentController.clear();
//       setState(() {
//         _userRating = 0.0;
//       });
//       await fetchAverageRatingAndComments();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to submit rating: $e'.tr())),
//       );
//     }
//   }

//   Widget _buildProductDetailsSection(Color textColor, Color backgroundColor) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 15,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 Icons.info_outline,
//                 color: pkColor,
//                 size: 24,
//               ),
//               SizedBox(width: 8),
//               Text(
//                 'Product Details'.tr(),
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: textColor,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
          
//           // Stock Status
//           _buildEnhancedDetailRow(
//             icon: Icons.inventory_2_outlined,
//             label: 'Stock Availability',
//             value: widget.product.StockQuantity > 0 
//                 ? '${widget.product.StockQuantity} items available'
//                 : 'Out of stock',
//             textColor: textColor,
//             valueColor: widget.product.StockQuantity > 0 ? Colors.green : Colors.red,
//           ),
          
//           // Location
//           _buildEnhancedDetailRow(
//             icon: Icons.location_on_outlined,
//             label: 'Location',
//             value: widget.product.address.isNotEmpty ? widget.product.address : 'Location not specified',
//             textColor: textColor,
//           ),
          
//           // Guarantee
//           _buildEnhancedDetailRow(
//             icon: Icons.verified_user_outlined,
//             label: 'Warranty',
//             value: widget.product.guarantee != null && widget.product.guarantee! > 0
//                 ? '${widget.product.guarantee} months warranty'
//                 : 'No warranty included',
//             textColor: textColor,
//             valueColor: widget.product.guarantee != null && widget.product.guarantee! > 0 
//                 ? Colors.green : textColor.withOpacity(0.7),
//           ),
          
//           // Installment
//           _buildEnhancedDetailRow(
//             icon: Icons.payment_outlined,
//             label: 'Payment Options',
//             value: widget.product.installmentAvailable 
//                 ? 'Installment available'
//                 : 'Full payment only',
//             textColor: textColor,
//             valueColor: widget.product.installmentAvailable ? Colors.blue : textColor.withOpacity(0.7),
//           ),
          
//           // Condition
//           _buildEnhancedDetailRow(
//             icon: widget.product.isNew ? Icons.new_releases_outlined : Icons.recycling_outlined,
//             label: 'Condition',
//             value: widget.product.isNew ? 'Brand New' : 'Used/Pre-owned',
//             textColor: textColor,
//             valueColor: widget.product.isNew ? Colors.green : Colors.orange,
//           ),
          
//           // Price Info
//           if (widget.product.discount > 0)
//             _buildEnhancedDetailRow(
//               icon: Icons.local_offer_outlined,
//               label: 'Discount',
//               value: '${widget.product.discount.toStringAsFixed(0)}% OFF',
//               textColor: textColor,
//               valueColor: Colors.red,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEnhancedDetailRow({
//     required IconData icon,
//     required String label,
//     required String value,
//     required Color textColor,
//     Color? valueColor,
//   }) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 8),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: textColor.withOpacity(0.03),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: textColor.withOpacity(0.1),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: pkColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: pkColor,
//               size: 20,
//             ),
//           ),
//           SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: textColor.withOpacity(0.7),
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: valueColor ?? textColor,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEnhancedRatingSection(Color textColor, Color backgroundColor) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Rating Summary
//           Row(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     _averageRating.toStringAsFixed(1),
//                     style: TextStyle(
//                       fontSize: 48,
//                       fontWeight: FontWeight.bold,
//                       color: textColor,
//                     ),
//                   ),
//                   Row(
//                     children: List.generate(5, (index) {
//                       return Icon(
//                         index < _averageRating.floor() ? Icons.star : Icons.star_border,
//                         color: Colors.amber,
//                         size: 20,
//                       );
//                     }),
//                   ),
//                   Text(
//                     '$_totalReviews reviews',
//                     style: TextStyle(
//                       color: textColor.withOpacity(0.7),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(width: 24),
//               Expanded(
//                 child: Column(
//                   children: List.generate(5, (index) {
//                     int starCount = 5 - index;
//                     int count = _comments.where((c) => c['rating'] == starCount).length;
//                     double percentage = _totalReviews > 0 ? count / _totalReviews : 0;
                    
//                     return Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 2),
//                       child: Row(
//                         children: [
//                           Text('$starCount', style: TextStyle(color: textColor)),
//                           Icon(Icons.star, size: 16, color: Colors.amber),
//                           SizedBox(width: 8),
//                           Expanded(
//                             child: Container(
//                               height: 8,
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[300],
//                                 borderRadius: BorderRadius.circular(4),
//                               ),
//                               child: FractionallySizedBox(
//                                 alignment: Alignment.centerLeft,
//                                 widthFactor: percentage,
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: Colors.amber,
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 8),
//                           Text('$count', style: TextStyle(color: textColor, fontSize: 12)),
//                         ],
//                       ),
//                     );
//                   }),
//                 ),
//               ),
//             ],
//           ),
          
//           SizedBox(height: 24),
//           Divider(color: textColor.withOpacity(0.2)),
//           SizedBox(height: 16),
          
//           // Add Rating Section
//           Text(
//             'Rate this product'.tr(),
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: textColor,
//             ),
//           ),
//           SizedBox(height: 12),
          
//           Row(
//             children: [
//               Text('Your rating: ', style: TextStyle(color: textColor)),
//               RatingBar.builder(
//                 initialRating: _userRating,
//                 minRating: 1,
//                 allowHalfRating: false,
//                 itemCount: 5,
//                 itemSize: 30,
//                 itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
//                 onRatingUpdate: (rating) {
//                   setState(() {
//                     _userRating = rating;
//                   });
//                 },
//               ),
//             ],
//           ),
          
//           SizedBox(height: 16),
//           TextField(
//             controller: _commentController,
//             maxLines: 3,
//             style: TextStyle(color: textColor),
//             decoration: InputDecoration(
//               labelText: 'Write your review'.tr(),
//               labelStyle: TextStyle(color: textColor.withOpacity(0.7)),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: textColor.withOpacity(0.3)),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: pkColor),
//               ),
//             ),
//           ),
          
//           SizedBox(height: 16),
//           Center(
//             child: ElevatedButton(
//               onPressed: _submitRating,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: pkColor,
//                 padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: Text(
//                 'Submit Review'.tr(),
//                 style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCommentsSection(Color textColor, Color backgroundColor) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Customer Reviews'.tr(),
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: textColor,
//             ),
//           ),
//           SizedBox(height: 16),
//           _isCommentsLoading
//               ? Center(child: CircularProgressIndicator())
//               : _comments.isEmpty
//                   ? Container(
//                       padding: EdgeInsets.all(20),
//                       child: Column(
//                         children: [
//                           Icon(Icons.rate_review_outlined, size: 48, color: textColor.withOpacity(0.5)),
//                           SizedBox(height: 8),
//                           Text(
//                             'No reviews yet'.tr(),
//                             style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 16),
//                           ),
//                           Text(
//                             'Be the first to review this product!'.tr(),
//                             style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 14),
//                           ),
//                         ],
//                       ),
//                     )
//                   : Column(
//                       children: _comments.map((comment) => Container(
//                         margin: EdgeInsets.only(bottom: 16),
//                         padding: EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: textColor.withOpacity(0.1)),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             CircleAvatar(
//                               backgroundImage: comment['profileImage'] != null &&
//                                       comment['profileImage'].startsWith('http')
//                                   ? NetworkImage(comment['profileImage'])
//                                   : AssetImage('assets/images/user (1).png') as ImageProvider,
//                               radius: 20,
//                             ),
//                             SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Text(
//                                         comment['userName'],
//                                         style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: textColor,
//                                         ),
//                                       ),
//                                       Row(
//                                         children: List.generate(5, (index) {
//                                           return Icon(
//                                             index < comment['rating'] ? Icons.star : Icons.star_border,
//                                             color: Colors.amber,
//                                             size: 16,
//                                           );
//                                         }),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     comment['comment'],
//                                     style: TextStyle(color: textColor),
//                                   ),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     '2 days ago', // You can format comment['date'] here
//                                     style: TextStyle(
//                                       color: textColor.withOpacity(0.5),
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       )).toList(),
//                     ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     Color backgroundColor = isDark ? Color(0xFF333333) : Color(0xFFF8F9FA);
//     Color cardBackgroundColor = isDark ? Color(0xFF404040) : Colors.white;
//     Color textColor = isDark ? Colors.white : Color(0xFF333333);
//     Color priceColor = isDark ? Colors.white : Colors.black;
//     Color saleBadgeColor = isDark ? pkColor.withOpacity(0.7) : pkColor;
//     Color dividerColor = isDark ? Colors.white30 : Colors.grey;

//     return Scaffold(
//       backgroundColor: backgroundColor,
//       appBar: null,
//       body: Stack(
//         children: [
//           ListView(
//             padding: EdgeInsets.only(bottom: 120),
//             children: [
//               // Product images carousel
//               SizedBox(
//                 height: 400,
//                 child: PageView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: widget.product.images.isEmpty
//                       ? 1
//                       : widget.product.images.length,
//                   itemBuilder: (context, index) {
//                     final fullImageUrl = widget.product.images.isEmpty
//                         ? defaultProductImage
//                         : widget.product.images[index];

//                     return ImageWidget(
//                       productId: widget.product.productId,
//                       image: fullImageUrl,
//                     );
//                   },
//                 ),
//               ),

//               // Product Name and Sale Badge
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Text(
//                         widget.product.name,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: textColor,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                     if (widget.product.discount > 0)
//                       Container(
//                         decoration: BoxDecoration(
//                           color: saleBadgeColor,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         width: 100,
//                         height: 40,
//                         child: Center(
//                           child: Text(
//                             tr('product_page.on_sale'),
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),

//               // Rating and Review Section
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Color(0xFFEDEDED),
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       width: 100,
//                       height: 40,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Padding(
//                               padding: EdgeInsets.all(4),
//                               child: Icon(
//                                 Icons.star,
//                                 color: Color(0xFFFFD700),
//                                 size: 25,
//                               ),
//                             ),
//                             SizedBox(width: 5),
//                             Text(
//                               _averageRating.toStringAsFixed(1),
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                                 color: textColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 7),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 20, vertical: 10),
//                             decoration: BoxDecoration(
//                               color: widget.product.isNew
//                                   ? Color(0xff4CAF50)
//                                   : Color(0xff607D8B),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               widget.product.isNew ? "New".tr() : "Used".tr(),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           SizedBox(width: 5),
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: 8),
//                   ],
//                 ),
//               ),

//               // Product Description
//               Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Description'.tr(),
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: textColor,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       widget.product.description,
//                       style: TextStyle(fontSize: 16, color: textColor),
//                     ),
//                   ],
//                 ),
//               ),

//               // Product Details Section
//               _buildProductDetailsSection(textColor, cardBackgroundColor),

//               // Divider
//               Divider(color: dividerColor, thickness: .5),

//               // Related Products
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Text(
//                   tr('product_page.related_products'),
//                   style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: textColor),
//                 ),
//               ),

//               SizedBox(height: 20),

//               // Horizontal List of Related Products
//               SizedBox(
//                 height: 300,
//                 child: _isLoading
//                     ? Center(child: CircularProgressIndicator())
//                     : _showDummy || products.isEmpty
//                         ? ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: dummyProducts.length,
//                             itemBuilder: (context, index) {
//                               return Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 15),
//                                 child: ProductCard(
//                                   product: dummyProducts[index],
//                                   onTap: () {
//                                     Navigator.pushNamed(
//                                       context,
//                                       AppRoutes.productPage,
//                                       arguments: ProductPageArguments(
//                                           product: dummyProducts[index]),
//                                     );
//                                   },
//                                 ),
//                               );
//                             },
//                           )
//                         : ListView.builder(
//                             scrollDirection: Axis.horizontal,
//                             itemCount: products.length,
//                             itemBuilder: (context, index) {
//                               return Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 15),
//                                 child: ProductCard(
//                                   product: products[index],
//                                   onTap: () {
//                                     Navigator.pushNamed(
//                                       context,
//                                       AppRoutes.productPage,
//                                       arguments: ProductPageArguments(
//                                           product: products[index]),
//                                     );
//                                   },
//                                 ),
//                               );
//                             },
//                           ),
//               ),

//               SizedBox(height: 20),

//               // Enhanced Rating Section
//               _buildEnhancedRatingSection(textColor, cardBackgroundColor),

//               // Comments Section
//               _buildCommentsSection(textColor, cardBackgroundColor),

//               SizedBox(height: 20),
//             ],
//           ),

//           // Bottom Bar with Add to Cart Button
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: Container(
//               height: 120,
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               decoration: BoxDecoration(
//                 color: cardBackgroundColor,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.1),
//                     blurRadius: 10,
//                     offset: Offset(0, -2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   // Price and Discounted Price
//                   Flexible(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         widget.product.discount > 0
//                             ? Text(
//                                 "${widget.product.price} EGP ",
//                                 style: TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                   color: pTexColor,
//                                   decoration: TextDecoration.lineThrough,
//                                   decorationColor: Colors.red,
//                                   decorationThickness: 2,
//                                 ),
//                               )
//                             : SizedBox.shrink(),
//                         Text(
//                           "${getDiscountedPrice(widget.product)} EGP ",
//                           style: TextStyle(
//                             fontSize: 28,
//                             fontWeight: FontWeight.bold,
//                             color: priceColor,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   // Add to Cart Button
//                   SizedBox(
//                     width: 200,
//                     height: 60,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         CartService().addToCart(
//                           widget.product.productId,
//                           1,
//                         );
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                               content: Text(tr('product_page.add_to_cart'))),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: pkColor,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 32,
//                           vertical: 16,
//                         ),
//                       ),
//                       child: Text(
//                         tr('product_page.add_to_cart'),
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }