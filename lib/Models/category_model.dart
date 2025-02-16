class Category {
  final int id;
  final String name;
  final String imageUrl;

  Category({required this.id, required this.name, String? imageUrl})
      : imageUrl = imageUrl ?? "assets/images/physical Therapy.jpg";
}
