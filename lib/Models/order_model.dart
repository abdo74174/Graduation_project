import 'package:graduation_project/Models/order_details_model.dart';

class Order {
  final int id;
  final int userId;
  final double totalPrice;
  final String status;
  final DateTime orderDate;
  final List<OrderDetail> orderDetails;

  Order({
    required this.id,
    required this.userId,
    required this.totalPrice,
    required this.status,
    required this.orderDate,
    required this.orderDetails,
  });

  // factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  // Map<String, dynamic> toJson() => _$OrderToJson(this);
}
