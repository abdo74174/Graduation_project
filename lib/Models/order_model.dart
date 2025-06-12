class OrderModel {
  final int orderId;
  final String userName;
  final DateTime orderDate;
  final String status;
  final double totalPrice;
  final int? userId; // Changed to int? to handle potential null values
  final List<OrderItemModel> items;

  OrderModel({
    this.userId,
    required this.orderId,
    required this.userName,
    required this.orderDate,
    required this.status,
    required this.totalPrice,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      userId: json['userId'] as int? ?? 0, // Default to 0 if null or missing
      orderId: json['orderId'] as int,
      userName: json['userName'] as String? ?? 'Unknown',
      orderDate: DateTime.parse(json['orderDate'] as String),
      status: json['status'] as String? ?? 'Pending',
      totalPrice: (json['totalPrice'] as num).toDouble(),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) =>
                  OrderItemModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'orderId': orderId,
      'userName': userName,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
      'totalPrice': totalPrice,
      'items': items.map((item) => item.toJson()).toList(),
    };
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
      productName: json['productName'] as String? ?? 'Unknown',
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}
