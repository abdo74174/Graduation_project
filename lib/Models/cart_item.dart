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

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      userId: json['userId'],
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'product': product.toJson(),
      'quantity': quantity,
    };
  }
}
