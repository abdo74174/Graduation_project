class Category {
  final int id;
  final String name;
  late final String imageUrl;
  final String? Desc;

  Category(
      {required this.id, required this.name, String? imageUrl, this.Desc}) {
    this.imageUrl = imageUrl ?? "assets/images/ct-scan (1) 1.jpg";
  }

  // // Convert JSON to Category object
  // factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  // // Convert Category object to JSON
  // Map<String, dynamic> toJson() => _$CategoryToJson(this);
}
