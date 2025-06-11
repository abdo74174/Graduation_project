import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/dashboard/latest_products_card.dart';
import 'package:graduation_project/components/dashboard/sales_overview_card.dart';
import 'package:graduation_project/components/dashboard/stats_card.dart';
import 'package:graduation_project/screens/admin_product_review_screen.dart';
import 'package:graduation_project/screens/dashboard/customers_page.dart';
import 'package:graduation_project/screens/dashboard/orders_page.dart';
import 'package:graduation_project/screens/dashboard/products_page.dart';
import 'package:graduation_project/screens/dashboard/revenue_page.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:graduation_project/services/dashbord/dashbord_service.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  late Future<Map<String, dynamic>> _dashboardFuture;
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboardData();
  }

  Future<Map<String, dynamic>> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);
      final data = await _dashboardService.getDashboardSummary();
      setState(() => _isLoading = false);
      return data;
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorSnackBar('Failed to load dashboard data: $error');
      }
      rethrow;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
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
              titleMedium: const TextStyle(fontWeight: FontWeight.w600),
            ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'.tr()),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _dashboardFuture = _loadDashboardData();
                      });
                    },
              tooltip: 'Refresh Data'.tr(),
            ),
          ],
        ),
        body: FutureBuilder<Map<String, dynamic>>(
          future: _dashboardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading dashboard data...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data == null) {
              return _buildEmptyState();
            }

            final data = snapshot.data!;
            final productCount = data['productCount'] ?? 0;
            final userCount = data['userCount'] ?? 0;
            final orderCount = data['orderCount'] ?? 0;
            final productReviews = data['productReviewCount'] ?? 0;
            final pendingOrderCount = data['pendingOrderCount'] ?? 0;
            final totalRevenue = (data['totalRevenue'] != null)
                ? (data['totalRevenue'] is int
                    ? (data['totalRevenue'] as int).toDouble()
                    : (data['totalRevenue'] as double))
                : 0.0;
            final List<Map<String, dynamic>> latestProducts =
                (data['latestProducts'] as List<dynamic>?)
                        ?.cast<Map<String, dynamic>>() ??
                    [];

            // Calculate financial metrics
            final commission = totalRevenue * 0.04; // 4% commission rate
            final grossProfit = totalRevenue - commission;
            final averageOrderValue =
                orderCount > 0 ? totalRevenue / orderCount : 0.0;

            // Format as currency
            final formatter =
                NumberFormat.currency(locale: 'en_US', symbol: '\$');
            final formattedRevenue = formatter.format(totalRevenue);
            final formattedCommission = formatter.format(commission);
            final formattedGrossProfit = formatter.format(grossProfit);
            final formattedAvgOrderValue = formatter.format(averageOrderValue);

            // Stats data
            final stats = [
              {
                'title': 'Products'.tr(),
                'value': productCount.toString(),
                'icon': Icons.inventory,
                'color': Colors.blue,
                'onTap': () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductsPage()),
                    ),
              },
              {
                'title': 'Orders'.tr(),
                'value': orderCount.toString(),
                'icon': Icons.shopping_cart,
                'color': Colors.orange,
                'onTap': () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FutureBuilder<String>(
                        future: UserServicee()
                            .getUserId()
                            .then((value) => value ?? '0'),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          return OrdersPage();
                        },
                      ),
                    ),
                  );
                },
              },
              {
                'title': 'Users'.tr(),
                'value': userCount.toString(),
                'icon': Icons.people,
                'color': Colors.purple,
                'onTap': () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CustomersPage()),
                    ),
              },
              {
                'title': 'Product Reviews'.tr(),
                'value': productReviews.toString(),
                'icon': Icons.star,
                'color': Colors.yellow[700],
                'onTap': () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AdminProductReviewScreen()),
                    ),
              },
              {
                'title': 'Pending Orders'.tr(),
                'value': pendingOrderCount.toString(),
                'icon': Icons.hourglass_empty,
                'color': Colors.red,
                'onTap': () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => OrdersPage()),
                    ),
              },
              {
                'title': 'Avg Order Value'.tr(),
                'value': formattedAvgOrderValue,
                'icon': Icons.calculate,
                'color': Colors.teal,
                'onTap': () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RevenuePage()),
                    ),
              },
            ];

            // Financial summary data
            final financialStats = [
              {
                'title': 'Total Revenue'.tr(),
                'value': formattedRevenue,
                'icon': Icons.attach_money,
                'color': Colors.green,
                'onTap': () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RevenuePage()),
                    ),
              },
              {
                'title': 'Commission (4%)'.tr(),
                'value': formattedCommission,
                'icon': Icons.account_balance_wallet,
                'color': Colors.orange,
                'onTap': () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RevenuePage()),
                    ),
              },
              {
                'title': 'Gross Profit'.tr(),
                'value': formattedGrossProfit,
                'icon': Icons.trending_up,
                'color': Colors.blue,
                'onTap': () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RevenuePage()),
                    ),
              },
            ];

            // Filter latest products based on search query
            final filteredProducts =
                latestProducts.where((Map<String, dynamic> product) {
              final name = product['name']?.toString().toLowerCase() ?? '';
              final query = _searchQuery.toLowerCase();
              return name.contains(query);
            }).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Center(
                    child: Text(
                      'Dashboard Overview'.tr(),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats Cards
                  StatsCard(stats: stats),
                  const SizedBox(height: 24),
                  // Financial Summary
                  Text(
                    'Financial Summary'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: financialStats.length,
                    itemBuilder: (context, index) {
                      final stat = financialStats[index];
                      return GestureDetector(
                        onTap: stat['onTap'] as VoidCallback?,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (stat['color'] as Color)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      stat['icon'] as IconData,
                                      color: stat['color'] as Color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      stat['title'] as String,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                stat['value'] as String,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      (stat['color'] as Color).withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Sales Overview
                  SalesOverviewCard(totalRevenue: totalRevenue),
                  const SizedBox(height: 24),
                  // Latest Products Section
                  Text(
                    'Latest Products'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  // Search Bar
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search latest products...'.tr(),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Latest Products
                  LatestProductsCard(products: filteredProducts),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Error loading dashboard data'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _dashboardFuture = _loadDashboardData();
              });
            },
            icon: const Icon(Icons.refresh),
            label: Text('Retry'.tr()),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.data_usage, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No dashboard data available'.tr(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding products and orders to see insights'.tr(),
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
