class OrderModel {
  final int orderId;
  final int userId;
  final String userName;
  final int? deliveryPersonId;
  final String? deliveryPersonName;
  final String address;
  final DateTime orderDate;
  final String status;
  final double totalPrice;
  final List<OrderItemModel> items;
  final bool userConfirmedShipped;
  final bool deliveryPersonConfirmedShipped;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.address,
    this.deliveryPersonId,
    this.deliveryPersonName,
    required this.orderDate,
    required this.status,
    required this.totalPrice,
    required this.items,
    required this.userConfirmedShipped,
    required this.deliveryPersonConfirmedShipped,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] ?? 0,
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? 'Unknown',
      address: json['address'] ?? 'Unknown',
      deliveryPersonId: json['deliveryPersonId'],
      deliveryPersonName: json['deliveryPersonName'] ?? 'Unassigned',
      orderDate: DateTime.parse(json['orderDate'] ?? DateTime.now().toString()),
      status: json['status'] ?? 'Pending',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      userConfirmedShipped: json['userConfirmedShipped'] ?? false,
      deliveryPersonConfirmedShipped:
          json['deliveryPersonConfirmedShipped'] ?? false,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class OrderItemModel {
  final String productName;
  final int quantity;
  final double unitPrice;

  OrderItemModel({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productName: json['productName'] ?? 'Unknown',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
