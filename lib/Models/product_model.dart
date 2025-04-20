// ignore_for_file: non_constant_identifier_names

class ProductModel {
  final int productId;
  final String name;
  final String description;
  final double price;
  final bool isNew;
  final double discount;
  final int subCategoryId;
  final int categoryId;
  final int userId;
  final int StockQuantity;
  final List<String> images; // URLs of images

  ProductModel({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.isNew,
    required this.discount,
    required this.subCategoryId,
    required this.categoryId,
    required this.StockQuantity,
    required this.userId,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isNew: json['isNew'] ?? false,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      subCategoryId: json['subCategoryId'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      StockQuantity: json['stockQuantity'] ?? 0, // lowercase!
      userId: json['userId'] ?? 0,
      images: List<String>.from(json['imageUrls'] ?? []),
    );
  }
  ProductModel.empty()
      : productId = 0,
        name = 'Unknown',
        description = '',
        price = 0,
        StockQuantity = 0,
        isNew = false,
        discount = 0,
        subCategoryId = 0,
        categoryId = 0,
        userId = 0,
        images = [];
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'description': description,
      'price': price,
      'isNew': isNew,
      'discount': discount,
      'subCategoryId': subCategoryId,
      'categoryId': categoryId,
      'StockQuantity': StockQuantity,
      'userId': userId,
      'imageUrls': images,
    };
  }
}
