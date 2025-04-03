import 'package:graduation_project/Models/product_model.dart';

class OrderDetail {
  final int id;
  final int orderId;
  final ProductModel product;
  final int quantity;
  final double totalPrice;

  OrderDetail({
    required this.id,
    required this.orderId,
    required this.product,
    required this.quantity,
    required this.totalPrice,
  });

  // factory OrderDetail.fromJson(Map<String, dynamic> json) => _$OrderDetailFromJson(json);
  // Map<String, dynamic> toJson() => _$OrderDetailToJson(this);
}
