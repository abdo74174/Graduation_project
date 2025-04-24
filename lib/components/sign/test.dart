// // ignore_for_file: unused_element

// import 'package:flutter/material.dart';

// // ignore: duplicate_ignore
// // ignore: unused_element
// Widget _buildImageSection() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(
//         "Product Images",
//         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//       ),
//       SizedBox(height: 10),
//       SizedBox(
//         height: 100,
//         child: ListView(
//           scrollDirection: Axis.horizontal,
//           children: [
//             _buildImageItem('assets/images/photo.jpg'),
//             _buildImageItem('assets/images/photo2.jpg'),
//             _buildImageItem('assets/images/photo3.jpg'),
//           ],
//         ),
//       ),
//     ],
//   );
// }

// Widget _buildImageItem(String imagePath) {
//   return Container(
//     width: 80,
//     height: 80,
//     margin: EdgeInsets.only(right: 10),
//     decoration: BoxDecoration(
//       border: Border.all(color: Colors.grey.shade300),
//       borderRadius: BorderRadius.circular(10),
//       color: Colors.grey.shade200,
//       image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
//     ),
//   );
// }

// Widget _buildPricingSection(
//   TextEditingController priceController,
//   TextEditingController comparePriceController,
//   TextEditingController discountController,
// ) {
//   return Container(
//     padding: EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       border: Border.all(color: Colors.grey.shade300),
//       borderRadius: BorderRadius.circular(10),
//       boxShadow: [
//         BoxShadow(
//           color: const Color.fromARGB(255, 255, 255, 255),
//           blurRadius: 3,
//           spreadRadius: 2,
//         ),
//       ],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Pricing",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         SizedBox(height: 10),
//         Row(
//           children: [
//             Expanded(child: _buildTextField("Price", priceController)),
//             SizedBox(width: 10),
//             Expanded(
//               child: _buildTextField(
//                 "Compare at Price",
//                 comparePriceController,
//                 isStrikethrough: true,
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 10),
//         _buildTextField("Discount", discountController, isPercentage: true),
//         SizedBox(height: 10),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: [
//             _buildButton("Discard", Colors.white, Colors.black, true),
//             SizedBox(width: 10),
//             _buildButton("Schedule", Colors.blue.shade100, Colors.black),
//             SizedBox(width: 10),
//             _buildButton("Add Product", Colors.blue, Colors.white),
//           ],
//         ),
//       ],
//     ),
//   );
// }

// Widget _buildTextField(
//   String label,
//   TextEditingController controller, {
//   bool isPercentage = false,
//   bool isStrikethrough = false,
// }) {
//   return TextField(
//     controller: controller,
//     decoration: InputDecoration(
//       labelText: label,
//       labelStyle: TextStyle(color: Colors.grey.shade600),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade400),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade400),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade600, width: 2),
//       ),
//       suffixText: isPercentage ? "%" : null,
//     ),
//     style: TextStyle(
//       color: Colors.grey.shade800,
//       decoration:
//           isStrikethrough ? TextDecoration.lineThrough : TextDecoration.none,
//     ),
//     keyboardType: TextInputType.number,
//   );
// }

// Widget _buildButton(
//   String text,
//   Color bgColor,
//   Color textColor, [
//   bool isOutlined = false,
// ]) {
//   return ElevatedButton(
//     onPressed: () {},
//     style: ElevatedButton.styleFrom(
//       backgroundColor: bgColor,
//       foregroundColor: textColor,
//       side: isOutlined ? BorderSide(color: Colors.black) : BorderSide.none,
//     ),
//     child: Text(text),
//   );
// }

// // ignore: duplicate_ignore
// // ignore: unused_element
// Widget _buildDescriptionField(dynamic descriptionController) {
//   return TextField(
//     controller: descriptionController,
//     maxLines: 4,
//     decoration: InputDecoration(
//       labelText: "Product Description",
//       labelStyle: TextStyle(color: Colors.grey.shade600),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade400),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade400),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade600, width: 2),
//       ),
//     ),
//     style: TextStyle(color: Colors.grey.shade800),
//   );
// }

// Widget _buildDropdown(String label, List<String> options) {
//   return DropdownButtonFormField<String>(
//     items:
//         options
//             .map(
//               (option) => DropdownMenuItem(value: option, child: Text(option)),
//             )
//             .toList(),
//     onChanged: (value) {},
//     decoration: InputDecoration(
//       labelText: label,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: Colors.grey.shade400),
//       ),
//     ),
//   );
// }
