import 'package:graduation_project/Models/subcateoery_model.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';

import 'product_model.dart';

class CategoryModel {
  final int categoryId;
  final String name;
  final String? image;
  final String description;
  final List<SubCategory> subCategories;
  final List<ProductModel> products;

  CategoryModel({
    required this.categoryId,
    required this.name,
    this.image,
    required this.description,
    required this.subCategories,
    required this.products,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['categoryId'] ?? 0,
      name: json['name']?.toString() ?? "No name", // تعديل الحقل هنا
      image: json['imageUrl']?.toString() ??
          defaultCategoryImage, // تعديل الحقل هنا
      description:
          json['description']?.toString() ?? "No description available",
      subCategories: (json['subCategories'] as List? ?? [])
          .map((e) => SubCategory.fromJson(e))
          .toList(),
      products: (json['products'] as List? ?? [])
          .map((e) => ProductModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'name': name,
      'image': image,
      'description': description,
      'subCategories': subCategories.map((e) => e.toJson()).toList(),
      'products': products.map((e) => e.toJson()).toList(),
    };
  }
}
