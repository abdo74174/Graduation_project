import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/order_model.dart';
import 'package:graduation_project/services/admin_dashboard.dart'
    hide DeliveryPersonRequestModel;
import 'package:graduation_project/services/elivery_person_service.dart';
import 'package:graduation_project/services/order/order_service.dart';
import 'package:shimmer/shimmer.dart';

class DeliveryPersonProfilePage extends StatefulWidget {
  final int userId;
  const DeliveryPersonProfilePage({Key? key, required this.userId})
      : super(key: key);

  @override
  _DeliveryPersonProfilePageState createState() =>
      _DeliveryPersonProfilePageState();
}

class _DeliveryPersonProfilePageState extends State<DeliveryPersonProfilePage> {
  final DeliveryPersonService _deliveryPersonService = DeliveryPersonService();
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  String _errorMessage = '';
  String? _requestStatus;
  bool? _isAvailable;
  List<OrderModel> _orders = [];
  DeliveryPersonRequestModel? deliveryPerson;
  int? deliveryPersonId;

  @override
  void initState() {
    super.initState();
    print('DeliveryPersonProfilePage: userId = ${widget.userId}');
    _fetchData();
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
        deliveryPerson = profile;
        deliveryPersonId = fetchedDeliveryPersonId;
        _requestStatus = profile?.requestStatus;
        _isAvailable = profile?.isAvailable ?? false;
        _orders = orders;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _errorMessage = 'error_fetching_profile'.tr();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateAvailability(bool newValue) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      await _deliveryPersonService.updateAvailability(widget.userId, newValue);
      setState(() {
        _isAvailable = newValue;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('availability_updated'.tr()),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      print('Error updating availability: $e');
      setState(() {
        _errorMessage = 'error_updating_availability'.tr();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage.tr()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
          title: Text('delivery_person_profile'.tr()),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    color: isDark ? Colors.grey[800] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'profile_info'.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            deliveryPersonId != null
                                ? 'delivery_person_id'.tr() +
                                    ': $deliveryPersonId'
                                : 'no_id_available'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            deliveryPerson != null
                                ? 'phone'.tr() + ': ${deliveryPerson!.phone}'
                                : 'no_phone_available'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            deliveryPerson != null
                                ? 'address'.tr() +
                                    ': ${deliveryPerson!.address}'
                                : 'no_address_available'.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'request_status'.tr(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _requestStatus != null
                                ? 'request_status_$_requestStatus'.tr()
                                : 'no_request_submitted'.tr(),
                            style: TextStyle(
                              color: _requestStatus == 'Approved'
                                  ? Colors.green
                                  : _requestStatus == 'Rejected'
                                      ? Colors.red
                                      : Colors.orange,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_requestStatus == 'Approved') ...[
                    const SizedBox(height: 16),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      color: isDark ? Colors.grey[800] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'availability'.tr(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Switch(
                              value: _isAvailable ?? false,
                              onChanged:
                                  _isLoading ? null : _updateAvailability,
                              activeColor: primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'assigned_orders'.tr(),
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  _isLoading
                      ? _buildLoadingState()
                      : _orders.isEmpty
                          ? _buildEmptyState(isDark, 'no_orders_assigned'.tr())
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _orders.length,
                              itemBuilder: (context, index) => _buildOrderCard(
                                  _orders[index], isDark, index),
                            ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        _errorMessage.tr(),
                        style: TextStyle(color: Colors.red[400]),
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

  Widget _buildOrderCard(OrderModel order, bool isDark, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
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
                color: isDark ? Colors.white : Colors.black87),
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
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Address: ${order.address}'.tr(),
                  style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total: ${order.totalPrice.toStringAsFixed(2)} EGP'.tr(),
                  style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
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
                      color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  'Qty: ${item.quantity} | Price: ${item.unitPrice.toStringAsFixed(2)} EGP'
                      .tr(),
                  style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              );
            }).toList(),
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
            color: chipColor, fontWeight: FontWeight.w600, fontSize: 12),
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

  Widget _buildLoadingState() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Shimmer(
            direction: ShimmerDirection.ltr,
            gradient: LinearGradient(
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
                  color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
