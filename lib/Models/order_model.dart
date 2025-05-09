import 'package:graduation_project/Models/order_details_model.dart';

class OrderModel {
  final int orderId;
  final String userName;
  final DateTime orderDate;
  final String status;
  final double totalPrice;
  final List<OrderItemModel> items;

  OrderModel({
    required this.orderId,
    required this.userName,
    required this.orderDate,
    required this.status,
    required this.totalPrice,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'],
      userName: json['userName'],
      orderDate: DateTime.parse(json['orderDate']),
      status: json['status'],
      totalPrice: json['totalPrice'].toDouble(),
      items: (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
    );
  }
}
