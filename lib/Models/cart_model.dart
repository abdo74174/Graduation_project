import 'package:graduation_project/Models/cart_item.dart';

class CartModel {
  final int id;
  final String userId;
  final List<CartItem> cartItems;

  CartModel({
    required this.id,
    required this.userId,
    required this.cartItems,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['cartItems'] is List<dynamic>
        ? json['cartItems'] as List<dynamic>
        : []; // Handle both cases for cartItems

    final parsedItems = rawList
        .map((e) => e is Map<String, dynamic> ? CartItem.fromJson(e) : null)
        .whereType<CartItem>()
        .toList();

    return CartModel(
      id: json['id'] as int? ?? 0, // Make sure it uses the correct key
      userId: (json['userId'] is String)
          ? json['userId'] as String
          : json['userId'].toString(), // Ensure userId is always a String
      cartItems: parsedItems,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'cartItems': cartItems.map((ci) => ci.toJson()).toList(),
      };
}
