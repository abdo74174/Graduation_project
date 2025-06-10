import 'package:flutter/material.dart';
import 'package:graduation_project/screens/admin_product_review_screen.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:graduation_project/services/dashbord/dashbord_service.dart';
import 'package:intl/intl.dart'; // For formatting currency
import '../../components/dashboard/sales_overview_card.dart';
import '../../components/dashboard/latest_products_card.dart';
import '../../components/dashboard/stats_card.dart';
import 'package:graduation_project/screens/dashboard/products_page.dart';
import 'package:graduation_project/screens/dashboard/orders_page.dart';
import 'package:graduation_project/screens/dashboard/customers_page.dart';

class DashboardScreen extends StatelessWidget {
  final DashboardService _dashboardService = DashboardService();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
        body: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardService.getDashboardSummary(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No data available'));
            }

            final data = snapshot.data!;
            final productCount = data['productCount'] ?? 0;
            final userCount = data['userCount'] ?? 0;
            final orderCount = data['orderCount'] ?? 0;
            final productReviews = data['productReviewCount'] ?? 0;
            final totalRevenue = (data['totalRevenue'] != null)
                ? (data['totalRevenue'] is int
                    ? (data['totalRevenue'] as int).toDouble()
                    : (data['totalRevenue'] as double))
                : 0.0;
            final latestProducts = data['latestProducts'] ?? [];

            // Format revenue as currency
            final formatter =
                NumberFormat.currency(locale: 'en_US', symbol: '\$');
            final formattedRevenue = formatter.format(totalRevenue);

            // Update stats list with fetched data
            final stats = [
              {
                "title": "Products",
                "value": productCount.toString(),
                "icon": Icons.inventory,
                "color": Colors.blue,
                "onTap": () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProductsPage()));
                },
              },
              {
                "title": "Orders",
                "value": orderCount.toString(),
                "icon": Icons.shopping_cart,
                "color": Colors.orange,
                "onTap": () async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FutureBuilder<String>(
                                future: UserServicee()
                                    .getUserId()
                                    .then((value) => value ?? "0"),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  return OrdersPage();
                                },
                              )));
                },
              },
              {
                "title": "Revenue",
                "value": formattedRevenue,
                "icon": Icons.attach_money,
                "color": Colors.green,
                "onTap": () {
                  // No specific page for revenue, leaving it as a placeholder or could navigate to a sales report.
                },
              },
              {
                "title": "Users",
                "value": userCount.toString(),
                "icon": Icons.people,
                "color": Colors.purple,
                "onTap": () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CustomersPage()));
                },
              },
              {
                "title": "Product Review",
                "value": productReviews.toString(),
                "icon": Icons.production_quantity_limits,
                "color": Colors.purple,
                "onTap": () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminProductReviewScreen()));
                },
              },
            ];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard Header
                  const Center(
                    child: Text(
                      "Dashboard Overview",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats Cards
                  StatsCard(stats: stats),
                  const SizedBox(height: 24),
                  // Sales Overview
                  SalesOverviewCard(totalRevenue: totalRevenue),
                  const SizedBox(height: 24),
                  // Latest Products
                  LatestProductsCard(products: latestProducts),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
