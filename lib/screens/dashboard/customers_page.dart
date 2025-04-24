import 'package:flutter/material.dart';

class CustomersPage extends StatelessWidget {
  // Sample data for customers
  final List<Map<String, String>> customers = [
    {"name": "John Doe", "email": "john.doe@example.com", "status": "Active"},
    {
      "name": "Jane Smith",
      "email": "jane.smith@example.com",
      "status": "Inactive"
    },
    {
      "name": "Michael Johnson",
      "email": "michael.johnson@example.com",
      "status": "Active"
    },
    {
      "name": "Emily Davis",
      "email": "emily.davis@example.com",
      "status": "Active"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Customers")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: customers.length,
          itemBuilder: (context, index) {
            final customer = customers[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: ListTile(
                title: Text(customer["name"]!),
                subtitle: Text(customer["email"]!),
                trailing: Chip(
                  label: Text(customer["status"]!),
                  backgroundColor: customer["status"] == "Active"
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
