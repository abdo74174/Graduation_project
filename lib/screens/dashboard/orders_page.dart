import 'package:flutter/material.dart';

class OrdersPage extends StatelessWidget {
  // Sample data for orders
  final List<Map<String, String>> orders = [
    {"orderId": "ORD123", "productName": "Air Compressing Therapy Device", "status": "Shipped"},
    {"orderId": "ORD124", "productName": "AutoClave", "status": "Processing"},
    {"orderId": "ORD125", "productName": "Anesthesia Machine", "status": "Delivered"},
    {"orderId": "ORD126", "productName": "Heart Monitor", "status": "Shipped"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Orders")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: Text(order["productName"]!),
                subtitle: Text("Order ID: ${order["orderId"]!}"),
                trailing: Chip(
                  label: Text(order["status"]!),
                  backgroundColor: order["status"] == "Shipped"
                      ? Colors.green
                      : order["status"] == "Processing"
                          ? Colors.orange
                          : Colors.blue,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

