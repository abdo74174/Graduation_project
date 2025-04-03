// ignore_for_file: unused_import

import 'dart:typed_data';

import 'package:graduation_project/Models/subcateoery_model.dart';

import 'product_model.dart';

class Category {
  final int categoryId;
  final String name;
  final String image;
  final String description;
  final List<SubCategory> subCategories;
  final List<ProductModel> products;
  static const String defaultImage = "assets/images/bone1.jpg";
  Category({
    required this.categoryId,
    required this.name,
    this.image = defaultImage,
    required this.description,
    required this.subCategories,
    required this.products,
  });

  // factory Category.fromJson(Map<String, dynamic> json) {
  //   return Category(
  //     categoryId: json['categoryId'],
  //     name: json['name'],
  //     image: Uint8List.fromList(List<int>.from(json['image'])),
  //     description: json['description'],
  //     subCategories: (json['subCategories'] as List)
  //         .map((e) => SubCategory.fromJson(e))
  //         .toList(),
  //     products: (json['products'] as List)
  //         .map((e) => ProductModel.fromJson(e))
  //         .toList(),
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'categoryId': categoryId,
  //     'name': name,
  //     'image': image,
  //     'description': description,
  //     'subCategories': subCategories.map((e) => e.toJson()).toList(),
  //     'products': products.map((e) => e.toJson()).toList(),
  //   };
  // }
}
