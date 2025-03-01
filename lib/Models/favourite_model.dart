import 'package:graduation_project/Models/product_model.dart';

class Favorite {
  final int id;
  final int userId;
  final Product product;

  Favorite({required this.id, required this.userId, required this.product});

  // factory Favorite.fromJson(Map<String, dynamic> json) => _$FavoriteFromJson(json);
  // Map<String, dynamic> toJson() => _$FavoriteToJson(this);
}
