// ignore_for_file: non_constant_identifier_names

class ProductModel {
  final int productId;
  final String name;
  final String description;
  final double price;
  final bool isNew;
  final bool isDeleted;
  final double discount;
  final int subCategoryId;
  final String address;
  final int categoryId;
  final int? guarantee;
  final int userId;
  final bool donation;
  final int StockQuantity;
  final bool installmentAvailable; // New field
  final List<String> images; // URLs of images
  static const String defaultProductImage = "assets/images/equip2.png";
  // Default image for product

  // Add id getter
  int get id => productId;

  ProductModel({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.isNew,
    required this.isDeleted,
    this.guarantee,
    required this.address,
    required this.donation,
    required this.discount,
    required this.subCategoryId,
    required this.categoryId,
    required this.installmentAvailable,
    required this.StockQuantity,
    required this.userId,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    String parseStringField(dynamic field) {
      if (field is String) {
        return field;
      } else if (field is Map) {
        // Attempt to extract a common language key, or fallback
        return field['en'] as String? ??
            field.values.firstWhere((v) => v is String, orElse: () => '')
                as String? ??
            '';
      }
      return '';
    }

    return ProductModel(
      productId: json['productId'] ?? 0,
      name: parseStringField(json['name']),
      description: parseStringField(json['description']),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      isNew: json['isNew'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      address: json['address'] ?? "unknownAddress",
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      subCategoryId: json['subCategoryId'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      donation: json['donation'] ?? false,
      guarantee: json['guarantee'] ?? 0,
      installmentAvailable: json['installmentAvailable'] ?? false,
      StockQuantity: json['stockQuantity'] ?? 0, // lowercase!
      userId: json['userId'] ?? 0,
      images: List<String>.from(
          json['imageUrls'] ?? [defaultProductImage, defaultProductImage]),
    );
  }

  ProductModel.empty()
      : productId = 0,
        name = 'Unknown',
        description = '',
        price = 0,
        StockQuantity = 0,
        isNew = false,
        isDeleted = false,
        donation = false,
        guarantee = 12,
        discount = 0,
        address = "unKnownAddress",
        subCategoryId = 0,
        categoryId = 0,
        userId = 0,
        installmentAvailable = false,
        images = [];

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'description': description,
      'price': price,
      'isNew': isNew,
      'isDeleted': isDeleted,
      'guarantee': guarantee,
      'discount': discount,
      "address": address,
      'subCategoryId': subCategoryId,
      'donation': donation, // ✅ Add this
      'categoryId': categoryId,
      'installmentAvailable': installmentAvailable,
      'StockQuantity': StockQuantity,
      'userId': userId,
      'imageUrls': images,
    };
  }
}
