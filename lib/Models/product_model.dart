// @JsonSerializable()
class Product {
  final int id;
  final int? categoryId;
  final int subCategoryId;
  final String name;
  late final String imageUrl;
  final double price;
  final int quantity;

  Product({
    required this.id,
    this.categoryId,
    required this.subCategoryId,
    required this.name,
    String? imageUrl,
    required this.price,
    this.quantity = 1,
  }) {
    this.imageUrl = imageUrl ?? "assets/images/equip4.png";
  }

  // Convert JSON to Product object
  // factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

  // Convert Product object to JSON
  //Map<String, dynamic> toJson() => _$ProductToJson(this);
}
