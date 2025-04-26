import 'package:flutter/material.dart';
import '../../components/dashboard/sales_overview_card.dart';
import '../../components/dashboard/latest_products_card.dart';
import '../../components/dashboard/stats_card.dart';

class DashboardScreen extends StatelessWidget {
  final List<Map<String, dynamic>> stats = [
    {
      "title": "Products",
      "value": 120,
      "icon": Icons.inventory,
      "color": Colors.blue
    },
    {
      "title": "Orders",
      "value": 75,
      "icon": Icons.shopping_cart,
      "color": Colors.orange
    },
    {
      "title": "Revenue",
      "value": "\$3,200",
      "icon": Icons.attach_money,
      "color": Colors.green
    },
    {
      "title": "Customers",
      "value": 58,
      "icon": Icons.people,
      "color": Colors.purple
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          titleTextStyle: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardColor: Colors.white,
        textTheme: Theme.of(context).textTheme.copyWith(
              bodyMedium: const TextStyle(color: Colors.black87),
              titleMedium: const TextStyle(fontWeight: FontWeight.bold),
            ),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text("Dashboard")),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Header
              Center(
                child: const Text(
                  "Dashboard Overview",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              // Stats Cards
              StatsCard(stats: stats), // Stats Cards
              const SizedBox(height: 24),
              // Sales Overview
              SalesOverviewCard(),
              const SizedBox(height: 24),
              // Latest Products
              LatestProductsCard(),
            ],
          ),
        ),
      ),
    );
  }
}
