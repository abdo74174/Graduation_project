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
      productName: json['productName'],
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
    );
  }
}
