class ProductModel {
  final int productId;
  final String name;
  final String description;
  final double price;
  final bool isNew;
  final double discount;
  final int subCategoryId;
  final int categoryId;
  final String image;
  final int userId;

  // Default Image URL
  static const String defaultImage = "assets/images/ct-scan (1) 1.jpg";

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
    this.image = defaultImage, // Set default image
  });

  // factory ProductModel.fromJson(Map<String, dynamic> json) {
  //   return ProductModel(
  //     productId: json['productId'],
  //     name: json['name'],
  //     description: json['description'],
  //     price: (json['price'] as num).toDouble(),
  //     isNew: json['isNew'],
  //     discount: (json['discount'] as num).toDouble(),
  //     subCategoryId: json['subCategoryId'],
  //     categoryId: json['categoryId'],
  //     userId: json['userId'],
  //     image: json['image'] ?? defaultImage, // Use provided image or default
  //   );
  // }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'productId': productId,
  //     'name': name,
  //     'description': description,
  //     'price': price,
  //     'isNew': isNew,
  //     'discount': discount,
  //     'subCategoryId': subCategoryId,
  //     'categoryId': categoryId,
  //     'userId': userId,
  //     'image': image,
  //   };
  // }
}
