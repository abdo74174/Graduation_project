import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:graduation_project/Models/order_model.dart';

import 'package:flutter/foundation.dart';
import 'package:graduation_project/services/admin_dashboard.dart';
import 'package:shimmer/shimmer.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminDeliveryService _orderService = AdminDeliveryService();

  List<OrderModel> _orders = [];
  List<DeliveryPersonModel> _deliveryPersons = [];
  List<DeliveryPersonRequestModel> _requests = [];
  Map<String, dynamic> _orderStats = {};
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedAddress = 'Sohag';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final orders = await _orderService.GetAllOrders();
      final deliveryPersons =
          await _orderService.GetAvailableDeliveryPersons(_selectedAddress);
      final requests = await _orderService.GetDeliveryPersonRequests();
      final stats = await _orderService.GetOrderStatistics();
      if (mounted) {
        setState(() {
          _orders = orders;
          _deliveryPersons = deliveryPersons.cast<DeliveryPersonModel>();
          _requests = requests.cast<DeliveryPersonRequestModel>();
          _orderStats = stats;
          _isLoading = false;
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

  Future<void> _handleRequest(int requestId, String action) async {
    try {
      await _orderService.HandleDeliveryPersonRequest(requestId, action);
      await _fetchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request $action successfully'.tr()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('AdminDashboardPage: Failed to $action request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to $action request: $e'.tr()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  Future<void> _assignDeliveryPerson(int orderId, int deliveryPersonId) async {
    try {
      await _orderService.AssignDeliveryPerson(orderId, deliveryPersonId);
      await _fetchData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delivery person assigned successfully'.tr()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      debugPrint('AdminDashboardPage: Failed to assign delivery person: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign delivery person: $e'.tr()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
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
          title: Text('Admin Dashboard'.tr()),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: _fetchData,
          child: const Icon(Icons.refresh),
          tooltip: 'Refresh Data'.tr(),
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
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  _buildStatisticsCard(isDark),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Filter by Address'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedAddress = value.isEmpty ? 'Sohag' : value;
                        });
                        _fetchData();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Error: $_errorMessage'.tr(),
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Delivery Person Requests'.tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  _isLoading
                      ? _buildLoadingState()
                      : _requests.isEmpty
                          ? _buildEmptyState(isDark, 'No requests found'.tr())
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: _requests.length,
                              itemBuilder: (context, index) =>
                                  _buildRequestCard(
                                      _requests[index], isDark, index),
                            ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Assign Orders'.tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  _isLoading
                      ? _buildLoadingState()
                      : _orders.isEmpty
                          ? _buildEmptyState(isDark, 'No orders found'.tr())
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: _orders.length,
                              itemBuilder: (context, index) => _buildOrderCard(
                                  _orders[index], isDark, index),
                            ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(bool isDark) {
    final data = _orderStats.entries
        .toList()
        .asMap()
        .entries
        .map((entry) => PieChartSectionData(
              color: _getStatusColor(entry.value.key),
              value: (entry.value.value as num).toDouble(),
              title: '${entry.value.key}\n${entry.value.value}',
              radius: 60,
              titleStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ))
        .toList();

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      color: isDark ? Colors.grey[850] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Statistics'.tr(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: data.isEmpty
                  ? Center(child: Text('No data available'.tr()))
                  : PieChart(
                      PieChartData(
                        sections: data,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        borderData: FlBorderData(show: false),
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 300),
                      swapAnimationCurve: Curves.easeInOut,
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.grey;
      case 'processing':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'assigned':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRequestCard(
      DeliveryPersonRequestModel request, bool isDark, int index) {
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
          title: Text(
            request.name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          subtitle: Text(
            'Status: ${request.status}'.tr(),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          children: [
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text('Email: ${request.email}'.tr()),
            ),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text('Phone: ${request.phone}'.tr()),
            ),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text('Address: ${request.address}'.tr()),
            ),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text('Card Number: ${request.cardNumber ?? 'N/A'}'.tr()),
            ),
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              title: Text(
                  'Created At: ${request.createdAt?.toString() ?? 'N/A'}'.tr()),
            ),
            if (request.cardImageUrl != null)
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text('Card Image Available'.tr()),
                trailing: IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () {
                    // Implement image viewing logic
                  },
                ),
              ),
            if (request.heraImageUrl != null)
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                title: Text('Hera Image Available'.tr()),
                trailing: IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: () {
                    // Implement image viewing logic
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (request.status.toLowerCase() != 'pending')
                    ElevatedButton(
                      onPressed: () => _handleRequest(request.id, 'pending'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Set to Pending'.tr()),
                    ),
                  const SizedBox(width: 8),
                  if (request.status.toLowerCase() != 'approved')
                    ElevatedButton(
                      onPressed: () => _handleRequest(request.id, 'approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Approve'.tr()),
                    ),
                  const SizedBox(width: 8),
                  if (request.status.toLowerCase() != 'rejected')
                    ElevatedButton(
                      onPressed: () => _handleRequest(request.id, 'reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Reject'.tr()),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Implement contact logic
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Contact'.tr()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, bool isDark, int index) {
    final availableDeliveryPersons = _deliveryPersons
        .where((dp) =>
            dp.address.toLowerCase() == order.address.toLowerCase() &&
            dp.requestStatus == 'Approved' &&
            dp.isAvailable == true)
        .toList();

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
            'Order ID: ${order.orderId}'.tr(),
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
                  'User: ${order.userName}'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Delivery: ${order.deliveryPersonName ?? 'Unassigned'}'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${order.totalPrice.toStringAsFixed(2)} EGP'.tr(),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Address: ${order.address}'.tr(),
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
                  'Qty: ${item.quantity} | Price: ${item.unitPrice.toStringAsFixed(2)} EGP'
                      .tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              );
            }).toList(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assign Delivery:'.tr(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  availableDeliveryPersons.isEmpty
                      ? Text(
                          'No available delivery persons for this address'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: order.deliveryPersonId,
                                hint: Text('Select Delivery Person'.tr()),
                                onChanged: (value) async {
                                  if (value != null) {
                                    bool? confirm = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        title: Text('Confirm Assignment'.tr()),
                                        content: Text(
                                          'Assign this order to ${(_deliveryPersons.firstWhere((dp) => dp.id == value)).name} at ${order.address}?'
                                              .tr(),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: Text('Cancel'.tr()),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .primaryColor,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12)),
                                            ),
                                            child: Text('Confirm'.tr()),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await _assignDeliveryPerson(
                                          order.orderId, value);
                                    }
                                  }
                                },
                                items: availableDeliveryPersons.map((dp) {
                                  return DropdownMenuItem<int>(
                                    value: dp.id,
                                    child:
                                        Text('${dp.name} (${dp.phone})'.tr()),
                                  );
                                }).toList(),
                                style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black87),
                                dropdownColor:
                                    isDark ? Colors.grey[800] : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            if (order.deliveryPersonId != null)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                tooltip: 'Unassign Delivery Person'.tr(),
                                onPressed: () async {
                                  bool? confirm = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      title:
                                          Text('Unassign Delivery Person'.tr()),
                                      content: Text(
                                          'Remove the assigned delivery person from this order?'
                                              .tr()),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: Text('Cancel'.tr()),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                          ),
                                          child: Text('Unassign'.tr()),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    // Placeholder for unassign logic
                                  }
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
    );
  }

  Widget _buildStatusChip(String status, bool isDark) {
    Color chipColor = _getStatusColor(status);

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

  Widget _buildLoadingState() {
    return SizedBox(
      height: 400,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Shimmer(
            direction: ShimmerDirection.ltr,
            gradient: const LinearGradient(
              colors: [Colors.transparent, Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(20),
              ),
              height: 100,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String message) {
    return SizedBox(
      height: 200,
      child: Center(
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
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
