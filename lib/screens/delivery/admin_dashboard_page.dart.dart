import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:graduation_project/Models/order_model.dart';
import 'package:graduation_project/services/admin_dashboard.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:ui';
import 'package:flutter/services.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage>
    with TickerProviderStateMixin {
  final AdminDeliveryService _deliveryService = AdminDeliveryService();
  final ScrollController _scrollController = ScrollController();

  List<OrderModel> _orders = [];
  List<DeliveryPersonModel> _deliveryPersons = [];
  List<DeliveryPersonRequestModel> _requests = [];
  Map<String, dynamic> _orderStats = {};
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String _errorMessage = '';
  String _selectedAddress = 'Sohag';
  int _page = 1;
  final int _pageSize = 20;
  bool _hasMoreOrders = true;
  bool _isInitialLoad = true;

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late AnimationController _cardController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _cardAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _fetchData();
    _startAnimations();
    _scrollController.addListener(_onScroll);
    SystemChannels.navigation.setMethodCallHandler((call) async {
      if (call.method == 'popRoute') {
        return true;
      }
      return false;
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Curves.elasticOut,
      ),
    );
  }

  void _startAnimations() {
    _animationController.forward();
    _pulseController.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _cardController.forward();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreOrders) {
      _fetchMoreOrders();
    }
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _page = 1;
      _hasMoreOrders = true;
    });
    try {
      final orders =
          await _deliveryService.getAllOrders(page: _page, pageSize: _pageSize);
      final deliveryPersons =
          await _deliveryService.getAvailableDeliveryPersons(_selectedAddress);
      final requests = await _deliveryService.getDeliveryPersonRequests();
      final stats = await _deliveryService.getOrderStatistics();
      if (mounted) {
        setState(() {
          _orders = orders;
          _deliveryPersons = deliveryPersons;
          _requests = requests;
          _orderStats = stats;
          _isLoading = false;
          _isInitialLoad = false;
          _hasMoreOrders = orders.length == _pageSize;
        });
      }
    } catch (e) {
      debugPrint('AdminDashboardPage: Error fetching data: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().tr();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchMoreOrders() async {
    if (_isLoadingMore || !_hasMoreOrders || !mounted) return;
    setState(() {
      _isLoadingMore = true;
    });
    try {
      final newOrders = await _deliveryService.getAllOrders(
          page: _page + 1, pageSize: _pageSize);
      if (mounted) {
        setState(() {
          _page++;
          _orders.addAll(newOrders);
          _isLoadingMore = false;
          _hasMoreOrders = newOrders.length == _pageSize;
        });
      }
    } catch (e) {
      debugPrint('AdminDashboardPage: Error fetching more orders: $e');
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
        _showCustomSnackBar(
          'Failed to load more orders: $e'.tr(),
          Colors.red,
          Icons.error,
        );
      }
    }
  }

  void _showCustomSnackBar(String message, Color color, IconData icon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildGradientBackground() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [Colors.grey[900]!, Colors.grey[850]!, Colors.grey[900]!]
              : [Colors.grey[50]!, Colors.white, Colors.grey[100]!],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      floating: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.1),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                ),
              ),
            ),
          ),
        ),
        title: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: Text(
                'Admin Dashboard'.tr(),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey[800]!.withOpacity(0.8)
              : Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.2)),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          tooltip: 'Back'.tr(),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[800]!.withOpacity(0.8)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: Icon(Icons.refresh,
                color: isDark ? Colors.white : Colors.black87),
            onPressed: _fetchData,
            tooltip: 'Refresh Data'.tr(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(bool isDark, Color primaryColor) {
    final data = _orderStats.entries
        .toList()
        .asMap()
        .entries
        .map((entry) => PieChartSectionData(
              color: _getStatusColor(entry.value.key),
              value: (entry.value.value as num).toDouble(),
              title: '${entry.value.key}\n${entry.value.value}',
              radius: 80,
              titleStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ))
        .toList();

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          Colors.grey[800]!.withOpacity(0.9),
                          Colors.grey[850]!.withOpacity(0.7)
                        ]
                      : [
                          Colors.white.withOpacity(0.9),
                          Colors.grey[50]!.withOpacity(0.8)
                        ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border:
                    Border.all(color: primaryColor.withOpacity(0.1), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Statistics'.tr(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 250,
                      child: data.isEmpty
                          ? Center(
                              child: Text(
                                'No data available'.tr(),
                                style: TextStyle(
                                  color:
                                      isDark ? Colors.white70 : Colors.black54,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : PieChart(
                              PieChartData(
                                sections: data,
                                centerSpaceRadius: 50,
                                sectionsSpace: 4,
                                borderData: FlBorderData(show: false),
                              ),
                              swapAnimationDuration:
                                  const Duration(milliseconds: 500),
                              swapAnimationCurve: Curves.easeInOutQuint,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _orderStats.entries
                          .map((entry) => _buildEnhancedStatusChip(
                              entry.key, isDark, entry.value.toString()))
                          .toList(),
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

  Widget _buildSearchFilter(bool isDark, Color primaryColor) {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              Colors.grey[800]!.withOpacity(0.7),
                              Colors.grey[850]!.withOpacity(0.5)
                            ]
                          : [
                              Colors.white.withOpacity(0.8),
                              Colors.grey[50]!.withOpacity(0.6)
                            ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: primaryColor.withOpacity(0.2), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Filter by Address'.tr(),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: primaryColor),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onSubmitted: (value) {
                      if (!mounted) return;
                      setState(() {
                        _selectedAddress = value.isEmpty ? 'Sohag' : value;
                      });
                      _fetchData();
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage(bool isDark) {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardAnimation.value,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.2),
                        Colors.red.withOpacity(0.1)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Error: $_errorMessage'.tr(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestCard(
      DeliveryPersonRequestModel request, bool isDark, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(
          milliseconds: _isInitialLoad && index < 5 ? 300 + (index * 50) : 0),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.grey[800]!.withOpacity(0.9),
                    Colors.grey[850]!.withOpacity(0.7)
                  ]
                : [
                    Colors.white.withOpacity(0.9),
                    Colors.grey[50]!.withOpacity(0.8)
                  ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.1), width: 1),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            leading: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _getStatusColor(request.status).withOpacity(0.8),
                          _getStatusColor(request.status).withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color:
                              _getStatusColor(request.status).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.person_rounded,
                        color: Colors.white, size: 20),
                  ),
                );
              },
            ),
            title: Text(
              request.name,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Status: ${request.status}'.tr(),
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing: _buildEnhancedStatusChip(request.status, isDark),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.email_rounded,
                        'Email: ${request.email}'.tr(), isDark),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.phone_rounded,
                        'Phone: ${request.phone}'.tr(), isDark),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.location_on_rounded,
                        'Address: ${request.address}'.tr(), isDark),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        Icons.credit_card_rounded,
                        'Card Number: ${request.cardNumber ?? 'N/A'}'.tr(),
                        isDark),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        Icons.calendar_today_rounded,
                        'Created At: ${request.createdAt?.toString() ?? 'N/A'}'
                            .tr(),
                        isDark),
                    if (request.cardImageUrl != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.image_rounded,
                        'Card Image Available'.tr(),
                        isDark,
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.visibility, color: Colors.blue),
                          onPressed: () {
                            // Implement image viewing logic
                          },
                        ),
                      ),
                    ],
                    if (request.heraImageUrl != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.image_rounded,
                        'Hera Image Available'.tr(),
                        isDark,
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.visibility, color: Colors.blue),
                          onPressed: () {
                            // Implement image viewing logic
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        if (request.status.toLowerCase() != 'pending')
                          _buildActionButton(
                            'Set to Pending'.tr(),
                            Colors.grey[600]!,
                            () async {
                              try {
                                await _deliveryService
                                    .handleDeliveryPersonRequest(
                                        request.id, 'pending');
                                if (mounted) {
                                  _showCustomSnackBar(
                                    'Request set to pending successfully'.tr(),
                                    Colors.green,
                                    Icons.check_circle,
                                  );
                                  await _fetchData();
                                }
                              } catch (e) {
                                if (mounted) {
                                  _showCustomSnackBar(
                                    'Failed to set request to pending: $e'.tr(),
                                    Colors.red,
                                    Icons.error,
                                  );
                                }
                              }
                            },
                          ),
                        if (request.status.toLowerCase() != 'approved')
                          _buildActionButton(
                            'Approve'.tr(),
                            Colors.green[600]!,
                            () async {
                              try {
                                await _deliveryService
                                    .handleDeliveryPersonRequest(
                                        request.id, 'approve');
                                if (mounted) {
                                  _showCustomSnackBar(
                                    'Request approved successfully'.tr(),
                                    Colors.green,
                                    Icons.check_circle,
                                  );
                                  await _fetchData();
                                }
                              } catch (e) {
                                if (mounted) {
                                  _showCustomSnackBar(
                                    'Failed to approve request: $e'.tr(),
                                    Colors.red,
                                    Icons.error,
                                  );
                                }
                              }
                            },
                          ),
                        if (request.status.toLowerCase() != 'rejected')
                          _buildActionButton(
                            'Reject'.tr(),
                            Colors.red[600]!,
                            () async {
                              try {
                                await _deliveryService
                                    .handleDeliveryPersonRequest(
                                        request.id, 'reject');
                                if (mounted) {
                                  _showCustomSnackBar(
                                    'Request rejected successfully'.tr(),
                                    Colors.green,
                                    Icons.check_circle,
                                  );
                                  await _fetchData();
                                }
                              } catch (e) {
                                if (mounted) {
                                  _showCustomSnackBar(
                                    'Failed to reject request: $e'.tr(),
                                    Colors.red,
                                    Icons.error,
                                  );
                                }
                              }
                            },
                          ),
                        _buildActionButton(
                          'Contact'.tr(),
                          Theme.of(context).primaryColor,
                          () {
                            // Implement contact logic
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, bool isDark, int index) {
    final availableDeliveryPersons = _deliveryPersons
        .where((dp) =>
            dp.address.toLowerCase() == order.address.toLowerCase() &&
            dp.requestStatus == 'Approved' &&
            dp.isAvailable)
        .toList();

    final shouldAnimate = _isInitialLoad && index < 5;

    return shouldAnimate
        ? TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(opacity: value, child: child),
              );
            },
            child:
                _buildOrderCardContent(order, isDark, availableDeliveryPersons),
          )
        : _buildOrderCardContent(order, isDark, availableDeliveryPersons);
  }

  Widget _buildOrderCardContent(OrderModel order, bool isDark,
      List<DeliveryPersonModel> availableDeliveryPersons) {
    bool isAssigning = false; // Track assignment state

    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.grey[800]!.withOpacity(0.9),
                  Colors.grey[850]!.withOpacity(0.7)
                ]
              : [
                  Colors.white.withOpacity(0.9),
                  Colors.grey[50]!.withOpacity(0.8)
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor.withOpacity(0.8),
                  Theme.of(context).primaryColor.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.local_shipping_rounded,
                color: Colors.white, size: 20),
          ),
          title: Text(
            'Order #${order.orderId}'.tr(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(Icons.person_rounded,
                    'User: ${order.userName}'.tr(), isDark),
                const SizedBox(height: 6),
                _buildDetailRow(
                    Icons.person_pin_rounded,
                    'Delivery: ${order.deliveryPersonName ?? 'Unassigned'}'
                        .tr(),
                    isDark),
                const SizedBox(height: 6),
                _buildDetailRow(
                    Icons.attach_money_rounded,
                    'Total: ${order.totalPrice.toStringAsFixed(2)} EGP'.tr(),
                    isDark),
                const SizedBox(height: 6),
                _buildDetailRow(Icons.location_on_rounded,
                    'Address: ${order.address}'.tr(), isDark),
              ],
            ),
          ),
          trailing: _buildEnhancedStatusChip(order.status, isDark),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...order.items.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey[700]!.withOpacity(0.3)
                            : Colors.grey[100]!.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                Colors.grey[300]!,
                                Colors.grey[200]!
                              ]),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.fastfood_rounded,
                                color: Colors.grey[600], size: 24),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Qty: ${item.quantity} • ${item.unitPrice.toStringAsFixed(2)} EGP'
                                      .tr(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey[700]!.withOpacity(0.3)
                          : Colors.grey[100]!.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assign Delivery:'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        availableDeliveryPersons.isEmpty
                            ? Text(
                                'No available delivery persons for this address'
                                    .tr(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              )
                            : StatefulBuilder(
                                builder: (context, setState) {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: DropdownButton<int>(
                                          isExpanded: true,
                                          value: order.deliveryPersonId,
                                          hint: Text(
                                            'Select Delivery Person'.tr(),
                                            style: TextStyle(
                                                color: isDark
                                                    ? Colors.grey[400]
                                                    : Colors.grey[600]),
                                          ),
                                          onChanged: isAssigning
                                              ? null
                                              : (value) async {
                                                  if (value == null || !mounted)
                                                    return;
                                                  final selectedPerson =
                                                      _deliveryPersons
                                                          .firstWhere((dp) =>
                                                              dp.id == value);

                                                  if (selectedPerson
                                                              .requestStatus !=
                                                          'Approved' ||
                                                      !selectedPerson
                                                          .isAvailable) {
                                                    if (mounted) {
                                                      _showCustomSnackBar(
                                                        'Selected delivery person is not approved or available'
                                                            .tr(),
                                                        Colors.red,
                                                        Icons.error,
                                                      );
                                                    }
                                                    return;
                                                  }

                                                  final confirm =
                                                      await showDialog<bool>(
                                                    context: context,
                                                    builder: (context) =>
                                                        _buildConfirmDialog(
                                                      title:
                                                          'Confirm Assignment'
                                                              .tr(),
                                                      content:
                                                          'Assign this order to ${selectedPerson.name} at ${order.address}?'
                                                              .tr(),
                                                      confirmText:
                                                          'Confirm'.tr(),
                                                      cancelText: 'Cancel'.tr(),
                                                      confirmColor:
                                                          Theme.of(context)
                                                              .primaryColor,
                                                    ),
                                                  );

                                                  if (confirm == true &&
                                                      mounted) {
                                                    setState(() =>
                                                        isAssigning = true);
                                                    try {
                                                      await _deliveryService
                                                          .assignDeliveryPerson(
                                                              order.orderId,
                                                              value);
                                                      if (mounted) {
                                                        _showCustomSnackBar(
                                                          'Delivery person assigned successfully'
                                                              .tr(),
                                                          Colors.green,
                                                          Icons.check_circle,
                                                        );
                                                        await _fetchData();
                                                      }
                                                    } catch (e) {
                                                      if (mounted) {
                                                        _showCustomSnackBar(
                                                          'Failed to assign delivery person: $e'
                                                              .tr(),
                                                          Colors.red,
                                                          Icons.error,
                                                        );
                                                      }
                                                    } finally {
                                                      if (mounted) {
                                                        setState(() =>
                                                            isAssigning =
                                                                false);
                                                      }
                                                    }
                                                  }
                                                },
                                          items: availableDeliveryPersons
                                              .map((dp) {
                                            return DropdownMenuItem<int>(
                                              value: dp.id,
                                              child: Text(
                                                '${dp.name} (${dp.phone})'.tr(),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isDark
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            fontSize: 14,
                                          ),
                                          dropdownColor: isDark
                                              ? Colors.grey[800]
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                        ),
                                      ),
                                      if (isAssigning)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, bool isDark,
      {Widget? trailing}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildEnhancedStatusChip(String status, bool isDark, [String? value]) {
    Color chipColor = _getStatusColor(status);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  chipColor.withOpacity(0.8),
                  chipColor.withOpacity(0.6)
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: chipColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              value != null
                  ? '$status: $value'.toUpperCase()
                  : status.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 4,
        shadowColor: color.withOpacity(0.3),
      ),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.3),
      ),
    );
  }
Widget _buildConfirmDialog({
  required String title,
  required String content,
  required String confirmText,
  required String cancelText,
  required Color confirmColor,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.grey[800]!.withOpacity(0.9),
                      Colors.grey[850]!.withOpacity(0.7)
                    ]
                  : [
                      Colors.white.withOpacity(0.9),
                      Colors.grey[50]!.withOpacity(0.8)
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(false),
                    child: Text(
                      cancelText,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context, rootNavigator: true).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      elevation: 4,
                      shadowColor: confirmColor.withOpacity(0.3),
                    ),
                    child: Text(
                      confirmText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'assigned':
        return Colors.indigo;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEnhancedLoadingState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildModernAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildShimmerCard(height: 300, borderRadius: 24),
              const SizedBox(height: 24),
              _buildShimmerCard(height: 80, borderRadius: 20),
              const SizedBox(height: 16),
              _buildShimmerCard(height: 200, borderRadius: 24),
              const SizedBox(height: 24),
              _buildShimmerCard(height: 200, borderRadius: 24),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerCard(
      {required double height, required double borderRadius}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  Widget _buildEnhancedEmptyState(bool isDark, String message) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            height: 280,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.grey[800]!.withOpacity(0.5),
                        Colors.grey[850]!.withOpacity(0.3)
                      ]
                    : [
                        Colors.white.withOpacity(0.8),
                        Colors.grey[50]!.withOpacity(0.6)
                      ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey.withOpacity(0.3),
                          Colors.grey.withOpacity(0.1)
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'pull_to_refresh'.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent, elevation: 0),
      ),
      child: Scaffold(
        body: Stack(
          children: [
            _buildGradientBackground(),
            _isLoading
                ? _buildEnhancedLoadingState()
                : CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildModernAppBar(),
                      SliverToBoxAdapter(
                        child: RefreshIndicator(
                          onRefresh: _fetchData,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatisticsCard(isDark, primaryColor),
                              const SizedBox(height: 24),
                              _buildSearchFilter(isDark, primaryColor),
                              const SizedBox(height: 24),
                              if (_errorMessage.isNotEmpty)
                                _buildErrorMessage(isDark),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                          child: _buildSectionTitle(
                              'Delivery Person Requests'.tr(), isDark)),
                      _requests.isEmpty
                          ? SliverToBoxAdapter(
                              child: _buildEnhancedEmptyState(
                                  isDark, 'No requests found'.tr()),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildRequestCard(
                                    _requests[index], isDark, index),
                                childCount: _requests.length,
                              ),
                            ),
                      SliverToBoxAdapter(child: const SizedBox(height: 24)),
                      SliverToBoxAdapter(
                          child:
                              _buildSectionTitle('Assign Orders'.tr(), isDark)),
                      _orders.isEmpty
                          ? SliverToBoxAdapter(
                              child: _buildEnhancedEmptyState(
                                  isDark, 'No orders found'.tr()),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => _buildOrderCard(
                                    _orders[index], isDark, index),
                                childCount: _orders.length,
                              ),
                            ),
                      if (_isLoadingMore)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                                child: CircularProgressIndicator(
                                    color: primaryColor)),
                          ),
                        ),
                      SliverToBoxAdapter(child: const SizedBox(height: 24)),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _cardController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
