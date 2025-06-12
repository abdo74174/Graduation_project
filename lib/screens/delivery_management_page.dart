import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/order_model.dart';
import 'package:graduation_project/services/order/order_service.dart';
import 'package:shimmer/shimmer.dart';

enum DeliveryStatus { Pending, Processing, Shipped, Delivered, Cancelled }

class DeliveryManagementPage extends StatefulWidget {
  const DeliveryManagementPage({Key? key}) : super(key: key);

  @override
  _DeliveryManagementPageState createState() => _DeliveryManagementPageState();
}

class _DeliveryManagementPageState extends State<DeliveryManagementPage> {
  final OrderService _orderService = OrderService();
  List<OrderModel> _orders = [];
  List<OrderModel> _filteredOrders = [];
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'All';
  final List<String> _statusFilters = [
    'All',
    'Pending',
    'Processing',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
    _searchController.addListener(_filterOrders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fetches all orders from the backend and updates the UI.
  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final orders = await _orderService.getAllOrders();
      setState(() {
        _orders = orders;
        _filteredOrders = orders;
        _isLoading = false;
      });
      _filterOrders();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load orders: $e';
        _isLoading = false;
      });
    }
  }

  /// Filters orders based on search query and selected status.
  void _filterOrders() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredOrders = _orders.where((order) {
        final matchesQuery = order.items.any(
                (item) => item.productName.toLowerCase().contains(query)) ||
            order.orderId.toString().toLowerCase().contains(query) ||
            order.status.toLowerCase().contains(query) ||
            order.userName.toLowerCase().contains(query);
        final matchesStatus = _selectedStatusFilter == 'All' ||
            order.status.toLowerCase() == _selectedStatusFilter.toLowerCase();
        return matchesQuery && matchesStatus;
      }).toList();
    });
  }

  /// Updates the status of an order and refreshes the order list.
  Future<void> _updateOrderStatus(int orderId, DeliveryStatus status) async {
    try {
      String statusString = status.toString().split('.').last;
      await _orderService.updateOrderStatus(orderId, statusString);
      await _fetchOrders(); // Refresh orders
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $statusString'.tr()),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'.tr()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
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
          title: Text('Delivery Management'.tr()),
          actions: [
            IconButton(
              icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearchVisible = !_isSearchVisible;
                  if (!_isSearchVisible) {
                    _searchController.clear();
                    _filterOrders();
                  }
                });
              },
              tooltip:
                  _isSearchVisible ? 'Close Search'.tr() : 'Search Orders'.tr(),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // Implement advanced filtering if needed
              },
              tooltip: 'Filter Orders'.tr(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: _fetchOrders,
          child: const Icon(Icons.refresh),
          tooltip: 'Refresh Orders'.tr(),
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
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isSearchVisible ? 70 : 0,
                  child: _isSearchVisible
                      ? _buildSearchBar(isDark)
                      : const SizedBox.shrink(),
                ),
                _buildStatusFilters(isDark),
                Expanded(child: _buildOrdersList(isDark)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the search bar widget.
  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search orders...'.tr(),
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
            borderSide:
                BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        ),
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      ),
    );
  }

  /// Builds the horizontal status filter chips.
  Widget _buildStatusFilters(bool isDark) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _statusFilters.length,
        itemBuilder: (context, index) {
          final status = _statusFilters[index];
          final isSelected = _selectedStatusFilter == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(status.tr(), style: const TextStyle(fontSize: 14)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedStatusFilter = status;
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

  /// Builds the list of orders or appropriate loading/error/empty states.
  Widget _buildOrdersList(bool isDark) {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    } else if (_filteredOrders.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: _fetchOrders,
      color: Theme.of(context).primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) =>
            _buildOrderCard(_filteredOrders[index], isDark, index),
      ),
    );
  }

  /// Builds an individual order card with expandable details.
  Widget _buildOrderCard(OrderModel order, bool isDark, int index) {
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
            '${'Order ID:'.tr()} ${order.orderId}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'User:'.tr()} ${order.userName}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${'Total:'.tr()} \$${order.totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
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
                  '${'Qty:'.tr()} ${item.quantity} | ${'Price:'.tr()} \$${item.unitPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              );
            }).toList(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Update Status:'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  DropdownButton<DeliveryStatus>(
                    value: DeliveryStatus.values.firstWhere(
                      (e) =>
                          e.toString().split('.').last.toLowerCase() ==
                          order.status.toLowerCase(),
                      orElse: () => DeliveryStatus.Pending,
                    ),
                    onChanged: (value) async {
                      if (value != null) {
                        bool? confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            title: Text('Confirm Status Change'.tr()),
                            content: Text(
                                'Change order status to ${value.toString().split('.').last}?'
                                    .tr()),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text('Cancel'.tr()),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text('Confirm'.tr()),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await _updateOrderStatus(order.orderId, value);
                        }
                      }
                    },
                    items: DeliveryStatus.values.map((status) {
                      return DropdownMenuItem<DeliveryStatus>(
                        value: status,
                        child: Text(status.toString().split('.').last.tr()),
                      );
                    }).toList(),
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87),
                    dropdownColor: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a status chip with color based on the order status.
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
        status.tr(),
        style: TextStyle(
          color: chipColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Builds a loading state with shimmer effect.
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

  /// Builds an error state with retry button.
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            _errorMessage.tr(),
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _fetchOrders,
            icon: const Icon(Icons.refresh),
            label: Text('Retry'.tr()),
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

  /// Builds an empty state when no orders are found.
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
            'No orders found'.tr(),
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
