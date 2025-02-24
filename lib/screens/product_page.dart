// import 'package:flutter/material.dart';

// class ProductPage extends StatelessWidget {
//   const ProductPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Dental Chair"),
//         backgroundColor: const Color.fromARGB(255, 193, 197, 197),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16.0),
//         children: [
//           Image.asset('assets/images/photo1.jpg', height: 250),
//           SizedBox(height: 10),
//           Text(
//             "Dental Chair",
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           Text(
//             "Dental Treatment Chair with built-in Curing Light - Black - UA43T5300AUXEG",
//             textAlign: TextAlign.center,
//             style: TextStyle(color: Colors.grey),
//           ),
//           SizedBox(height: 10),
//           Text(
//             "\$400",
//             style: TextStyle(
//                 fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
//           ),
//           Text(
//             "List price: \$500",
//             style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey,
//                 decoration: TextDecoration.lineThrough),
//           ),
//           SizedBox(height: 10),
//           Text(
//             "Best Seller",
//             style: TextStyle(
//                 fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 20),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               ElevatedButton(
//                 onPressed: () {

//                 },
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//                 child: Text("Add To Cart"),
//               ),
//               ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
//                 child: Text("Buy Now"),
//               ),
//             ],
//           ),
//           SizedBox(height: 20),
//           Text(
//             "Products related to this item:",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 10),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 RelatedProduct(
//                     imagePath: 'assets/images/photo2.jpg',
//                     name: "Dental Stool"),
//                 SizedBox(width: 20),
//                 RelatedProduct(
//                     imagePath: 'assets/images/photo3.jpg',
//                     name: "Dental Light"),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class RelatedProduct extends StatelessWidget {
//   final String imagePath;
//   final String name;

//   const RelatedProduct({super.key, required this.imagePath, required this.name});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Image.asset(imagePath, height: 80),
//         SizedBox(height: 5),
//         Text(name, style: TextStyle(fontSize: 14)),
//       ],
//     );
//   }
// }
