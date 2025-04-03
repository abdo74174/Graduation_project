import 'package:graduation_project/Models/product_model.dart';

class CartItem {
  final int id;
  final int userId;
  final ProductModel product;
  int quantity;

  CartItem({
    required this.id,
    required this.userId,
    required this.product,
    required this.quantity,
  });

  // factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);
  // Map<String, dynamic> toJson() => _$CartItemToJson(this);
}
