import 'package:graduation_project/Models/product_model.dart';

class SubCategory {
  final int subCategoryId;
  final String name;
  final String description;
  final String image;
  final int categoryId;
  final List<ProductModel> products;

  static const String defaultImage = "assets/images/bone1.jpg";

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
          : defaultImage,
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
