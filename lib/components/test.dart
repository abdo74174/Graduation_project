// import 'package:flutter/material.dart';
// import 'package:graduation_project/Models/category_model.dart';
// import 'package:graduation_project/Models/product_model.dart';
// import 'package:graduation_project/Models/subcateoery_model.dart';
// import 'package:graduation_project/components/Category_view.dart';
// import 'package:graduation_project/components/product.dart';
// import 'package:graduation_project/components/subcategory.dart';

// // Category Model
// class Category {
//   final int id;
//   final String name;
//   final String imageUrl;

//   Category({required this.id, required this.name, String? imageUrl})
//       : imageUrl = imageUrl ?? "assets/images/Furniture.jpg";
// }

// // SubCategory Model
// class SubCategory {
//   final int id;
//   final int categoryId;
//   final String name;

//   SubCategory({required this.id, required this.categoryId, required this.name});
// }

// // Product Model
// class Product {
//   final int id;
//   final int subCategoryId;
//   final String name;
//   final String imageUrl;
//   final double price;

//   Product({
//     required this.id,
//     required this.subCategoryId,
//     required this.name,
//     String? imageUrl,
//     required this.price,
//   }) : imageUrl = imageUrl ?? "assets/images/physical Therapy.jpg";
// }

// class CategoryScreen extends StatefulWidget {
//   @override
//   _CategoryScreenState createState() => _CategoryScreenState();
// }

// class _CategoryScreenState extends State<CategoryScreen> {
//   int? selectedCategoryId;
//   int? selectedSubCategoryId;

//   @override
//   Widget build(BuildContext context) {
//     List<SubCategory> filteredSubCategories = selectedCategoryId == null
//         ? []
//         : subCategories
//             .where((sub) => sub.categoryId == selectedCategoryId)
//             .toList();

//     List<Product> filteredProducts = selectedSubCategoryId == null
//         ? []
//         : products
//             .where((prod) => prod.subCategoryId == selectedSubCategoryId)
//             .toList();

//     return Scaffold(
//       appBar: AppBar(title: Text("Categories")),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Categories List
//             SizedBox(
//               height: 160,
//               width: double.infinity,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: categories.length,
//                 itemBuilder: (context, index) {
//                   return CategoryView(
//                     category: categories[index],
//                     onTap: () {
//                       setState(() {
//                         selectedCategoryId = categories[index].id;
//                         selectedSubCategoryId = null;
//                       });
//                     },
//                   );
//                 },
//               ),
//             ),

//             Divider(
//               color: Colors.grey,
//               thickness: 1,
//             ),
//             SizedBox(height: 10),
//             // SubCategories List
//             if (filteredSubCategories.isNotEmpty)
//               SizedBox(
//                 height: 200, // Reduce height to fit images properly
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: filteredSubCategories.length,
//                   itemBuilder: (context, index) {
//                     return SubCategoryView(
//                       subCategory: filteredSubCategories[index],
//                       onTap: () {
//                         setState(() {
//                           selectedSubCategoryId =
//                               filteredSubCategories[index].id;
//                         });
//                       },
//                     );
//                   },
//                 ),
//               ),

//             SizedBox(height: 10),

//             // Products Grid
//             Padding(
//               padding: EdgeInsets.all(8.0),
//               child: GridView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   childAspectRatio: 0.8,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                 ),
//                 itemCount: filteredProducts.length,
//                 itemBuilder: (context, index) {
//                   return ProductCard(product: filteredProducts[index]);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
