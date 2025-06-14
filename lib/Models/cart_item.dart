import 'package:graduation_project/Models/product_model.dart';

class CartItems {
  final int id;
  final int cartId;
  final int productId;
  int quantity;
  final ProductModel product;

  CartItems({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.product,
  });

  factory CartItems.fromJson(Map<String, dynamic> json) {
    return CartItems(
      id: json['id'] as int? ?? 0, // Make sure it uses the correct key
      cartId: json['cartId'] as int? ?? 0,
      productId: json['productId'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 0,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : ProductModel.empty(), // Fallback to an empty product if null
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cartId': cartId,
        'productId': productId,
        'quantity': quantity,
        'product': product.toJson(),
      };
}
