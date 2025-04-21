import 'package:graduation_project/Models/product_model.dart';

class Favourite {
  final int id;
  final String userId;
  final int productId;
  final ProductModel product;

  Favourite({
    required this.id,
    required this.userId,
    required this.productId,
    required this.product,
  });

  factory Favourite.fromJson(Map<String, dynamic> json) {
    return Favourite(
      id: json['id'],
      userId: json['userId'],
      productId: json['productId'],
      product: ProductModel.fromJson(json['product']),
    );
  }
}
