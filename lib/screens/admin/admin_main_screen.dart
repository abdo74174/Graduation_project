import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/screens/coupon_management.dart';
import 'package:graduation_project/screens/contact_us/messages_list_page.dart';
import 'package:graduation_project/screens/delivery/admin_dashboard_page.dart.dart';
import 'package:graduation_project/screens/delivery/user_order_confirmation_page.dart';
import 'package:graduation_project/screens/pr_cat_sub.dart/addCatandSub.dart';
import 'package:graduation_project/screens/chat/chat_list_screen.dart';
import 'package:graduation_project/screens/dashboard/customers_page.dart';
import 'package:graduation_project/screens/dashboard/dashboard_screen.dart';
import 'package:graduation_project/screens/homepage.dart';

// Enhanced NavigationCard widget with modern design
class NavigationCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? cardColor;
  final Color? iconColor;

  const NavigationCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.cardColor,
    this.iconColor,
  }) : super(key: key);

  @override
  State<NavigationCard> createState() => _NavigationCardState();
}

class _NavigationCardState extends State<NavigationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _animationController.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.cardColor ?? Colors.white,
                    (widget.cardColor ?? Colors.white).withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? (widget.cardColor ?? Theme.of(context).primaryColor)
                            .withOpacity(0.3)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: _isHovered ? 20 : 10,
                    offset: Offset(0, _isHovered ? 8 : 4),
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (widget.iconColor ??
                                    Theme.of(context).primaryColor)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            widget.icon,
                            size: 32,
                            color: widget.iconColor ??
                                Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Welcome header widget
class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                  'Welcome Back, Admin!'.tr(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your application efficiently'.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time,
                          color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM dd, yyyy').format(DateTime.now()),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.admin_panel_settings,
              size: 48,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: 'Admin Dashboard'.tr(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF667eea),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      home: const AdminDashboardScreen(),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Color palette for cards
  final List<Color> cardColors = [
    const Color(0xFFE3F2FD), // Blue
    const Color(0xFFF3E5F5), // Purple
    const Color(0xFFE8F5E8), // Green
    const Color(0xFFFFF3E0), // Orange
    const Color(0xFFFFEBEE), // Red
    const Color(0xFFE0F2F1), // Teal
    const Color(0xFFF1F8E9), // Light Green
    const Color(0xFFFCE4EC), // Pink
  ];

  final List<Color> iconColors = [
    const Color(0xFF1976D2), // Blue
    const Color(0xFF7B1FA2), // Purple
    const Color(0xFF388E3C), // Green
    const Color(0xFFFF7043), // Orange
    const Color(0xFFE53935), // Red
    const Color(0xFF00796B), // Teal
    const Color(0xFF689F38), // Light Green
    const Color(0xFFAD1457), // Pink
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Admin Dashboard'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.logout, size: 20),
              ),
              tooltip: 'Logout',
              onPressed: () => _showLogoutDialog(context),
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const WelcomeHeader(),
                Text(
                  'Quick Actions'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount =
                        _getCrossAxisCount(constraints.maxWidth);
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _getNavigationItems().length,
                      itemBuilder: (context, index) {
                        final item = _getNavigationItems()[index];
                        return NavigationCard(
                          icon: item['icon'],
                          title: item['title'],
                          onTap: item['onTap'],
                          cardColor: cardColors[index % cardColors.length],
                          iconColor: iconColors[index % iconColors.length],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildQuickStats(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 900) return 4;
    if (width > 600) return 3;
    return 2;
  }

  List<Map<String, dynamic>> _getNavigationItems() {
    return [
      {
        'icon': Icons.analytics_outlined,
        'title': 'Analysis Dashboard'.tr(),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DashboardScreen()),
            ),
      },
      {
        'icon': Icons.home_outlined,
        'title': 'Homepage'.tr(),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HomePage()),
            ),
      },
      {
        'icon': Icons.category_outlined,
        'title': 'Category & Sub Category'.tr(),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddCategorySubCategoryPage()),
            ),
      },
      {
        'icon': Icons.admin_panel_settings_outlined,
        'title': 'Assign Admin'.tr(),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CustomersPage()),
            ),
      },
      {
        'icon': Icons.chat_outlined,
        'title': 'Chat List'.tr(),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatListPage()),
            ),
      },
      {
        'icon': Icons.discount_outlined,
        'title': 'Manage Coupons'.tr(),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CouponManagementPage()),
            ),
      },
      {
        'icon': Icons.message_outlined,
        'title': 'Contact US Messages'.tr(),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MessagesListPage()),
            ),
      },
      {
        'icon': Icons.delivery_dining_outlined,
        'title': 'Delivery Dashboard'.tr(),
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AdminDashboardPage()),
            ),
      },
    ];
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Overview'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.people_outline,
                  title: 'Total Users'.tr(),
                  value: '1,234',
                  color: const Color(0xFF667eea),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Orders'.tr(),
                  value: '567',
                  color: const Color(0xFF764ba2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.logout,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text('Logout'.tr()),
          ],
        ),
        // content: Text('Are you sure you want to logout?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomePage())),
            child: Text(
              'Cancel'.tr(),
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('Logout'.tr()),
          ),
        ],
      ),
    );

    if (confirm ?? false) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged out successfully'.tr()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        // Add navigation to login screen if needed
      }
    }
  }
}
