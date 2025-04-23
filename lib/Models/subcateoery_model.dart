import 'package:graduation_project/Models/product_model.dart';

class SubCategory {
  static const String defaultSubCategoryImage = "assets/images/subCategory.jpg";

  final int subCategoryId;
  final String name;
  final String description;
  final String image;
  final int categoryId;
  final List<ProductModel> products;

  SubCategory({
    required this.subCategoryId,
    required this.name,
    required this.description,
    required this.image,
    required this.categoryId,
    required this.products,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      subCategoryId: json['subCategoryId'],
      name: json['name'],
      description: json['description'],
      image: (json['imageUrl']?.isNotEmpty ?? false)
          ? json['imageUrl']
          : defaultSubCategoryImage,
      categoryId: json['categoryId'],
      products: (json['products'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subCategoryId': subCategoryId,
      'name': name,
      'description': description,
      'image': image,
      'categoryId': categoryId,
      'products': products.map((e) => e.toJson()).toList(),
    };
  }
}
