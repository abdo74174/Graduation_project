class SubCategory {
  final int id;
  final int categoryId;
  final String name;
  final String? Desc;

  SubCategory(
      {required this.id,
      required this.categoryId,
      required this.name,
      this.Desc});
}
