import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/components/dashboard/latest_products_card.dart';
import 'package:graduation_project/components/dashboard/sales_overview_card.dart';
import 'package:graduation_project/components/dashboard/stats_card.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/screens/admin_product_review_screen.dart';
import 'package:graduation_project/screens/dashboard/customers_page.dart';
import 'package:graduation_project/screens/dashboard/orders_page.dart';
import 'package:graduation_project/screens/dashboard/products_page.dart';
import 'package:graduation_project/screens/dashboard/revenue_page.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:graduation_project/services/dashbord/dashbord_service.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

// Define MonthlyRevenue class
class MonthlyRevenue {
  final String month;
  final double revenue;

  MonthlyRevenue(this.month, this.revenue);
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final DashboardService _dashboardService = DashboardService();
  late Future<Map<String, dynamic>> _dashboardFuture;
  bool _isLoading = false;
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AnimationController _refreshController; // Already marked as late

  // New features
  bool _showFinancialDetails = false;
  String _selectedTimePeriod = 'This Month';
  final List<String> _timePeriods = [
    'Today',
    'This Week',
    'This Month',
    'This Year'
  ];
  @override
  void initState() {
    super.initState();

    // Initialize controllers first
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Then load data
    _dashboardFuture = _loadDashboardData();
    _animationController.forward();
  }

  Future<Map<String, dynamic>> _loadDashboardData() async {
    try {
      setState(() => _isLoading = true);
      await _refreshController.forward(); // No need to check isAnimating first
      final data = await _dashboardService.getDashboardSummary();
      setState(() => _isLoading = false);
      _refreshController.reset();
      return data ?? {};
    } catch (error) {
      setState(() => _isLoading = false);
      if (_refreshController.status != AnimationStatus.dismissed) {
        _refreshController.reset();
      }
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
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.indigo.shade50,
            Colors.purple.shade50,
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back!'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.trending_up, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Dashboard Active'.tr(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.dashboard,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodSelector() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _timePeriods.map((period) {
            final isSelected = _selectedTimePeriod == period;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimePeriod = period;
                  _dashboardFuture =
                      _loadDashboardData(); // Refresh data for new period
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade600 : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? Colors.blue.shade600
                        : Colors.grey.shade300,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  period.tr(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final quickActions = [
      {
        'title': 'Add Product'.tr(),
        'icon': Icons.add_box,
        'color': Colors.green,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => ProductsPage())),
      },
      {
        'title': 'View Orders'.tr(),
        'icon': Icons.list_alt,
        'color': Colors.orange,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => OrdersPage())),
      },
      {
        'title': 'Analytics'.tr(),
        'icon': Icons.analytics,
        'color': Colors.purple,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => RevenuePage())),
      },
      {
        'title': 'Settings'.tr(),
        'icon': Icons.settings,
        'color': Colors.grey,
        'onTap': () {
          // Navigate to settings
        },
      },
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: quickActions.length,
              itemBuilder: (context, index) {
                final action = quickActions[index];
                return GestureDetector(
                  onTap: action['onTap'] as VoidCallback?,
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (action['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            action['icon'] as IconData,
                            color: action['color'] as Color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          action['title'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedFinancialCard(Map<String, dynamic> stat, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: GestureDetector(
              onTap: stat['onTap'] as VoidCallback?,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (stat['color'] as Color).withOpacity(0.1),
                      (stat['color'] as Color).withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (stat['color'] as Color).withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (stat['color'] as Color).withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (stat['color'] as Color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            stat['icon'] as IconData,
                            color: stat['color'] as Color,
                            size: 28,
                          ),
                        ),
                        Icon(
                          Icons.trending_up,
                          color: Colors.green.shade600,
                          size: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      stat['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat['value'] as String,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: stat['color'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceIndicators(Map<String, dynamic> data) {
    final orderCount = data['orderCount'] ?? 0;
    final userCount = data['userCount'] ?? 0;
    final productCount = data['productCount'] ?? 0;

    // Mock growth percentages (replace with real calculations if available)
    final orderGrowth = 12.5;
    final userGrowth = 8.3;
    final productGrowth = 15.2;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Performance Overview'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.trending_up,
                        color: Colors.green.shade600, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+12.5%',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildPerformanceItem(
                  'Orders'.tr(),
                  orderCount.toString(),
                  orderGrowth,
                  Icons.shopping_cart,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPerformanceItem(
                  'Users'.tr(),
                  userCount.toString(),
                  userGrowth,
                  Icons.people,
                  Colors.purple,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPerformanceItem(
                  'Products'.tr(),
                  productCount.toString(),
                  productGrowth,
                  Icons.inventory,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(
      String title, String value, double growth, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              growth > 0 ? Icons.arrow_upward : Icons.arrow_downward,
              color: growth > 0 ? Colors.green : Colors.red,
              size: 12,
            ),
            Text(
              '${growth.abs()}%',
              style: TextStyle(
                fontSize: 10,
                color: growth > 0 ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        cardColor: Colors.white,
        textTheme: Theme.of(context).textTheme.copyWith(
              bodyMedium: const TextStyle(color: Colors.black87),
              titleMedium: const TextStyle(fontWeight: FontWeight.w600),
              titleLarge:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text('Dashboard'.tr()),
          actions: [
            RotationTransition(
              turns: _refreshController,
              child: IconButton(
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
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Handle notifications
              },
              tooltip: 'Notifications'.tr(),
            ),
          ],
        ),
        body: Stack(
          children: [
            _buildGradientBackground(),
            FutureBuilder<Map<String, dynamic>>(
              future: _dashboardFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                } else if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                final List<MonthlyRevenue> monthlyData =
                    (data['monthlyRevenue'] as List<dynamic>?)
                            ?.map((item) => MonthlyRevenue(
                                item['month']?.toString() ?? '',
                                (item['revenue'] as num?)?.toDouble() ?? 0.0))
                            .toList() ??
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
                final formattedAvgOrderValue =
                    formatter.format(averageOrderValue);

                // Stats data
                final stats = [
                  {
                    'title': 'Products'.tr(),
                    'value': productCount.toString(),
                    'icon': Icons.inventory,
                    'color': Colors.blue,
                    'onTap': () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProductsPage()),
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
                          MaterialPageRoute(
                              builder: (context) => CustomersPage()),
                        ),
                  },
                  {
                    'title': 'Product Reviews'.tr(),
                    'value': productReviews.toString(),
                    'icon': Icons.star,
                    'color': Colors.yellow[700] ?? Colors.yellow,
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
                          MaterialPageRoute(
                              builder: (context) => RevenuePage()),
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
                          MaterialPageRoute(
                              builder: (context) => RevenuePage()),
                        ),
                  },
                  {
                    'title': 'Commission (4%)'.tr(),
                    'value': formattedCommission,
                    'icon': Icons.account_balance_wallet,
                    'color': Colors.orange,
                    'onTap': () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RevenuePage()),
                        ),
                  },
                  {
                    'title': 'Gross Profit'.tr(),
                    'value': formattedGrossProfit,
                    'icon': Icons.trending_up,
                    'color': Colors.blue,
                    'onTap': () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RevenuePage()),
                        ),
                  },
                ];

                // Filter latest products based on search query
                final filteredProducts = latestProducts.where((product) {
                  final name = product['name']?.toString().toLowerCase() ?? '';
                  final query = _searchQuery.toLowerCase();
                  return name.contains(query);
                }).toList();

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _dashboardFuture = _loadDashboardData();
                      });
                    },
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome Card
                          _buildWelcomeCard(),

                          // Time Period Selector
                          _buildTimePeriodSelector(),

                          // Quick Actions
                          _buildQuickActions(),

                          // Performance Overview
                          _buildPerformanceIndicators(data),

                          // Stats Cards
                          StatsCard(stats: stats),
                          const SizedBox(height: 32),

                          // Financial Summary
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Financial Summary'.tr(),
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showFinancialDetails =
                                        !_showFinancialDetails;
                                  });
                                },
                                icon: Icon(
                                  _showFinancialDetails
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 16,
                                  color: Theme.of(context).primaryColor,
                                ),
                                label: Text(
                                  _showFinancialDetails
                                      ? 'Hide Details'.tr()
                                      : 'Show Details'.tr(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: pkColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: _showFinancialDetails
                                ? GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 1.3,
                                    ),
                                    itemCount: financialStats.length,
                                    itemBuilder: (context, index) {
                                      final stat = financialStats[index];
                                      return _buildEnhancedFinancialCard(
                                          stat, index);
                                    },
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 32),

                          // Sales Overview
                          SalesOverviewCard(
                            totalRevenue: totalRevenue,
                            monthlyData: [],
                          ),

                          const SizedBox(height: 32),

                          // Latest Products Section
                          Text(
                            'Latest Products'.tr(),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),

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
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
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
