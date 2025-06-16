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

class _DeliveryPersonProfilePageState extends State<DeliveryPersonProfilePage>
    with SingleTickerProviderStateMixin {
  final DeliveryPersonService _deliveryPersonService = DeliveryPersonService();
  final OrderService _orderService = OrderService();
  bool _isLoading = false;
  String _errorMessage = '';
  String? _requestStatus;
  bool? _isAvailable;
  List<OrderModel> _orders = [];
  DeliveryPersonRequestModel? deliveryPerson;
  int? deliveryPersonId;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _fetchData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "deliveryPerson?.name" ?? 'delivery_person'.tr(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "deliveryPerson?.email " ?? 'email@example.com',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'delivery_person_profile'.tr(),
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _isLoading
            ? _buildLoadingState()
            : FadeTransition(
                opacity: _fadeAnimation,
                child: RefreshIndicator(
                  onRefresh: _fetchData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileHeader(),
                        const SizedBox(height: 24),
                        _buildInfoCard(
                          'phone'.tr(),
                          deliveryPerson?.phone ?? 'no_phone_available'.tr(),
                          Icons.phone,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          'address'.tr(),
                          deliveryPerson?.address ??
                              'no_address_available'.tr(),
                          Icons.location_on,
                        ),
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          'status'.tr(),
                          _requestStatus?.toUpperCase() ?? 'no_status'.tr(),
                          Icons.info,
                        ),
                        if (_requestStatus == 'Approved') ...[
                          const SizedBox(height: 24),
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 12,
                                        color: _isAvailable ?? false
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'availability'.tr(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
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
                        const SizedBox(height: 24),
                        Text(
                          'assigned_orders'.tr(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _orders.isEmpty
                            ? _buildEmptyState(
                                isDark, 'no_orders_assigned'.tr())
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _orders.length,
                                itemBuilder: (context, index) =>
                                    _buildOrderCard(
                                        _orders[index], isDark, index),
                              ),
                      ],
                    ),
                  ),
                ),
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildShimmerContainer(80),
          const SizedBox(height: 24),
          _buildShimmerContainer(100),
          const SizedBox(height: 12),
          _buildShimmerContainer(100),
          const SizedBox(height: 12),
          _buildShimmerContainer(100),
        ],
      ),
    );
  }

  Widget _buildShimmerContainer(double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark, String message) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800]!.withOpacity(0.3) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
