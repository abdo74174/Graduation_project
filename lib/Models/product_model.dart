class Product {
  final int id;
  final int? CategoryId;
  final int subCategoryId;
  final String name;
  final String imageUrl;
  final double price;

  const Product({
    required this.id,
    this.CategoryId,
    required this.subCategoryId,
    required this.name,
    String? imageUrl,
    required this.price,
  }) : imageUrl = imageUrl ?? "assets/images/physical Therapy.jpg";
}
