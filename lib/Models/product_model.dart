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
    required this.userId,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['productId'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      isNew: json['isNew'],
      discount: (json['discount'] as num).toDouble(),
      subCategoryId: json['subCategoryId'],
      categoryId: json['categoryId'],
      userId: json['userId'],
      images: List<String>.from(json['imageUrls'] ?? []),
    );
  }

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
      'userId': userId,
      'images': images,
    };
  }
}
