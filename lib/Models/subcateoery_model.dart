// ignore_for_file: unused_import

import 'dart:typed_data';
import 'product_model.dart';

class SubCategory {
  final int subCategoryId;
  final String name;
  final String description;
  final String image;
  final int categoryId;
  final List<ProductModel> products;
  static const String defultImage = "assets/images/bone1.jpg";
  SubCategory({
    required this.subCategoryId,
    required this.name,
    required this.description,
    this.image = defultImage,
    required this.categoryId,
    required this.products,
  });

  // factory SubCategory.fromJson(Map<String, dynamic> json) {
  //   return SubCategory(
  //     subCategoryId: json['subCategoryId'],
  //     name: json['name'],
  //     description: json['description'],
  //     image: Uint8List.fromList(List<int>.from(json['image'])),
  //     categoryId: json['categoryId'],
  //     products: (json['products'] as List)
  //         .map((e) => ProductModel.fromJson(e))
  //         .toList(),
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'subCategoryId': subCategoryId,
  //     'name': name,
  //     'description': description,
  //     'image': image,
  //     'categoryId': categoryId,
  //     'products': products.map((e) => e.toJson()).toList(),
  //   };
  // }
}
