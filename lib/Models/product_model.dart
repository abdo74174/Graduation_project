class Product {
  final int id;
  final int subCategoryId;
  final String name;
  final String imageUrl;
  final double price;

  Product({
    required this.id,
    required this.subCategoryId,
    required this.name,
    String? imageUrl,
    required this.price,
  }) : imageUrl = imageUrl ?? "assets/images/physical Therapy.jpg";
}
