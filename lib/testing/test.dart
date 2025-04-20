// import 'package:flutter/material.dart';
// import 'package:graduation_project/Models/cart_item.dart';
// import 'package:graduation_project/Models/product_model.dart';
// import 'package:graduation_project/core/constants/constant.dart'; // Import your CartItem model

// class ShoppingCartPage extends StatefulWidget {
//   const ShoppingCartPage({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _ShoppingCartPageState createState() => _ShoppingCartPageState();
// }

// class _ShoppingCartPageState extends State<ShoppingCartPage> {
//   // Sample cart items
//   List<CartItem> cartItems = [
//     CartItem(
//       id: 1,
//       userId: 123,
//       product: ProductModel(
//         productId: 1,
//         name: 'Smartphone',
//         description: 'Latest model with advanced features.',
//         price: 999.99,
//         isNew: true,
//         discount: 10.0,
//         subCategoryId: 2,
//         categoryId: 1,
//         userId: 123,
//         images: ['http://example.com/image1.jpg'],
//       ),
//       quantity: 2,
//     ),
//     CartItem(
//       id: 2,
//       userId: 123,
//       product: ProductModel(
//         productId: 2,
//         name: 'Headphones',
//         description: 'Noise-cancelling wireless headphones.',
//         price: 299.99,
//         isNew: true,
//         discount: 5.0,
//         subCategoryId: 3,
//         categoryId: 2,
//         userId: 123,
//         images: ['http://example.com/image2.jpg'],
//       ),
//       quantity: 1,
//     ),
//   ];

//   double get subtotal => cartItems.fold(
//       0, (sum, item) => sum + item.product.price * item.quantity);

//   void _incrementQuantity(int index) {
//     setState(() {
//       cartItems[index].quantity++;
//     });
//   }

//   void _decrementQuantity(int index) {
//     setState(() {
//       if (cartItems[index].quantity > 1) {
//         cartItems[index].quantity--;
//       }
//     });
//   }

//   void _removeItem(int index) {
//     setState(() {
//       cartItems.removeAt(index);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'My Cart',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: ListView.builder(
//                 itemCount: cartItems.length,
//                 itemBuilder: (context, index) {
//                   final item = cartItems[index];
//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 16),
//                     child: Container(
//                       padding: EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         children: [
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(8),
//                             // child: Image.network(
//                             //   item.product.images.first,
//                             //   width: 60,
//                             //   height: 60,
//                             //   fit: BoxFit.cover,
//                             // ),

//                             child: Image.asset(
//                               width: 60,
//                               height: 60,
//                               "assets/images/offer.avif",
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                           SizedBox(width: 12),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   item.product.name,
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                                 SizedBox(height: 4),
//                                 Text(
//                                   item.product.description,
//                                   style: TextStyle(
//                                     color: Colors.grey,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                                 SizedBox(height: 8),
//                                 Row(
//                                   children: [
//                                     _quantityButton(
//                                       icon: Icons.remove,
//                                       onPressed: () =>
//                                           _decrementQuantity(index),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(
//                                           horizontal: 8.0),
//                                       child: Text(
//                                         '${item.quantity}',
//                                         style: TextStyle(fontSize: 16),
//                                       ),
//                                     ),
//                                     _quantityButton(
//                                       icon: Icons.add,
//                                       onPressed: () =>
//                                           _incrementQuantity(index),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Column(
//                             children: [
//                               GestureDetector(
//                                 onTap: () => _removeItem(index),
//                                 child: Icon(Icons.delete_outline,
//                                     color: Colors.red),
//                               ),
//                               SizedBox(height: 16),
//                               Text(
//                                 '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 16),
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             // Subtotal row
//             _buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
//             SizedBox(height: 8),
//             _buildPriceRow('Total', '\$${subtotal.toStringAsFixed(2)}',
//                 isBold: true),
//             SizedBox(height: 16),
//             // Checkout Button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: pkColor,
//                   padding: EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 child: Text(
//                   'Checkout',
//                   style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _quantityButton(
//       {required IconData icon, required VoidCallback onPressed}) {
//     return Container(
//       width: 30,
//       height: 30,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: IconButton(
//         padding: EdgeInsets.zero,
//         icon: Icon(icon, size: 18),
//         onPressed: onPressed,
//       ),
//     );
//   }

//   Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
// }
