import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/order_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/elivery_person_service.dart';
import 'package:graduation_project/services/order/order_service.dart';
import 'package:shimmer/shimmer.dart';

class UserOrderStatusPage extends StatefulWidget {
  final int userId; // Add userId parameter
  const UserOrderStatusPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserOrderStatusPageState createState() => _UserOrderStatusPageState();
}

class _UserOrderStatusPageState extends State<UserOrderStatusPage>
    with SingleTickerProviderStateMixin {
  final OrderService _orderService = OrderService();
  final DeliveryPersonService _deliveryPersonService =
      DeliveryPersonService(); // Initialize service
  int? _deliveryPersonId;
  DeliveryPersonRequestModel? _deliveryPerson;
  String? _requestStatus;
  bool _isAvailable = false;
  List<OrderModel> _orders = [];
  List<OrderModel> _filteredOrdersShipped = [];
  List<OrderModel> _filteredOrdersOther = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isUpdatingStatus = false;

  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'All';
  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
    'Assigned',
  ];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
    _searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      // Fetch delivery person data
      final deliveryList = await _deliveryPersonService
          .fetchDeliveryPersonInfoById(widget.userId);
      DeliveryPersonRequestModel? profile;
      int? fetchedDeliveryPersonId;

      if (deliveryList != null && deliveryList.isNotEmpty) {
        profile = deliveryList.first;
        fetchedDeliveryPersonId = profile.userId;
        print("Delivery person ID: $fetchedDeliveryPersonId");
      } else {
        print("No delivery person found for userId ${widget.userId}");
        setState(() {
          _errorMessage = 'error_no_delivery_person'.tr();
        });
        return;
      }

      // Fetch orders if deliveryPersonId is available
      List<OrderModel> orders = [];
      if (fetchedDeliveryPersonId != null) {
        try {
          orders = await _orderService
              .getOrdersByDeliveryPerson(fetchedDeliveryPersonId);
          print(
              'Orders fetched for deliveryPersonId $fetchedDeliveryPersonId: $orders');
        } catch (e) {
          print('Error fetching orders: $e');
          setState(() {
            _errorMessage = 'error_fetching_orders'.tr();
          });
        }
      }

      setState(() {
        _deliveryPerson = profile;
        _deliveryPersonId = fetchedDeliveryPersonId;
        _requestStatus = profile?.requestStatus;
        _isAvailable = profile?.isAvailable ?? false;
        _orders = orders;
        _filterOrders();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _errorMessage =
            'error_fetching_profile'.tr(namedArgs: {'error': e.toString()});
        _isLoading = false;
      });
    }
  }

  Future<void> _updateOrderStatus(int orderId, String newStatus) async {
    if (_deliveryPersonId == null) {
      setState(() {
        _errorMessage = 'error_delivery_person_id_not_found'.tr();
      });
      return;
    }

    setState(() {
      _isUpdatingStatus = true;
      _errorMessage = '';
    });

    try {
      await _orderService.updateOrderStatus(
          orderId, _deliveryPersonId!, newStatus);
      await _fetchData(); // Refresh orders after status update
      setState(() {
        _isUpdatingStatus = false;
      });
    } catch (e) {
      String errorKey = 'error_generic';
      if (e.toString().contains('Status: 403')) {
        errorKey = 'error_not_assigned';
      } else if (e.toString().contains('Status: 400')) {
        errorKey = 'error_invalid_status';
      } else if (e.toString().contains('Status: 404')) {
        errorKey = 'error_order_not_found';
      }
      setState(() {
        _errorMessage = errorKey.tr(namedArgs: {'error': e.toString()});
        _isUpdatingStatus = false;
      });
    }
  }

  void _filterOrders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOrdersShipped = _orders.where((order) {
        final matchesQuery =
            order.orderId.toString().toLowerCase().contains(query) ||
                order.status.toLowerCase().contains(query);
        final matchesStatus = _selectedStatus == 'All' ||
            order.status.toLowerCase() == _selectedStatus.toLowerCase();
        return matchesQuery &&
            matchesStatus &&
            order.status.toLowerCase() == 'shipped';
      }).toList();
      _filteredOrdersOther = _orders.where((order) {
        final matchesQuery =
            order.orderId.toString().toLowerCase().contains(query) ||
                order.status.toLowerCase().contains(query);
        final matchesStatus = _selectedStatus == 'All' ||
            order.status.toLowerCase() == _selectedStatus.toLowerCase();
        return matchesQuery &&
            matchesStatus &&
            order.status.toLowerCase() != 'shipped';
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: isDark ? Colors.white : Colors.black87,
          ),
          iconTheme:
              IconThemeData(color: isDark ? Colors.white : Colors.black87),
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryColor.withOpacity(0.8),
                  primaryColor.withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text('my_order_status'.tr()),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'shipped'.tr()),
              Tab(text: 'other'.tr()),
            ],
            labelColor: primaryColor,
            unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
            indicatorColor: primaryColor,
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Colors.grey[900]!, Colors.grey[800]!]
                      : [Colors.grey[50]!, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 80),
                _buildSearchBar(isDark),
                _buildStatusFilters(isDark),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrdersList(isDark, _filteredOrdersShipped, true),
                      _buildOrdersList(isDark, _filteredOrdersOther, false),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'search_by_order_id'.tr(),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    _filterOrders();
                  },
                )
              : null,
          filled: true,
          fillColor: isDark
              ? Colors.grey[800]!.withOpacity(0.7)
              : Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.transparent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: pkColor, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
    );
  }

  Widget _buildStatusFilters(bool isDark) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _statusFilters.length,
        itemBuilder: (context, index) {
          final status = _statusFilters[index];
          final isSelected = _selectedStatus == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status.toLowerCase().tr(),
                  style: const TextStyle(fontSize: 14)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedStatus = status;
                  _filterOrders();
                });
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : isDark
                        ? Colors.grey[300]
                        : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrdersList(
      bool isDark, List<OrderModel> orders, bool isShippedTab) {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    } else if (orders.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: Theme.of(context).primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) =>
            _buildOrderCard(orders[index], isDark, index, isShippedTab),
      ),
    );
  }

  Widget _buildOrderCard(
      OrderModel order, bool isDark, int index, bool isShippedTab) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 4,
        color: isDark
            ? Colors.grey[850]!.withOpacity(0.8)
            : Colors.white.withOpacity(0.95),
        child: ExpansionTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Icon(Icons.local_shipping,
                color: Theme.of(context).primaryColor),
          ),
          title: Text(
            '${'order_id'.tr()} ${order.orderId}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${'date'.tr()} ${order.orderDate.toLocal().toString().split(' ')[0]}',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          trailing: _buildStatusChip(order.status, isDark),
          children: [
            ...order.items.map((item) {
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image, color: Colors.grey, size: 20),
                ),
                title: Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                subtitle: Text(
                  '${'quantity'.tr()} ${item.quantity} | ${'price'.tr()} \$${item.unitPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              );
            }).toList(),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
              title: ElevatedButton(
                onPressed: _isUpdatingStatus
                    ? null
                    : () {
                        final newStatus =
                            isShippedTab ? 'Processing' : 'Shipped';
                        _updateOrderStatus(order.orderId, newStatus);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  isShippedTab
                      ? 'mark_as_not_shipped'.tr()
                      : 'mark_as_shipped'.tr(),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isDark) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'pending':
        chipColor = Colors.grey;
        break;
      case 'processing':
        chipColor = Colors.orange;
        break;
      case 'shipped':
        chipColor = Colors.blue;
        break;
      case 'delivered':
        chipColor = Colors.green;
        break;
      case 'cancelled':
        chipColor = Colors.red;
        break;
      case 'assigned':
        chipColor = Colors.purple;
        break;
      default:
        chipColor = Colors.grey;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        status.toLowerCase().tr(),
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            height: 100,
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchData,
            icon: const Icon(Icons.refresh),
            label: Text('retry'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'no_orders_found'.tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
