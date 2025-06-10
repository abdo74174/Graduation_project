import 'package:flutter/material.dart';
import 'package:graduation_project/Models/order_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/services/Order/order_service.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrderPage> {
  List<OrderModel> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final fetchedOrders =
          await OrderService().getAllOrders(); // Replace with actual userId
      setState(() {
        orders = fetchedOrders;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load orders: $e')),
      );
    }
  }

  void _confirmDeleteOrder(int orderId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('delete_order'.tr()),
          content: Text('delete_order_confirmation'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await OrderService().deleteOrder(orderId);
                  setState(() {
                    orders.removeWhere((order) => order.orderId == orderId);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('order_deleted'.tr())),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete order: $e')),
                  );
                }
              },
              child: Text('delete'.tr(),
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('my_orders'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : orders.isEmpty
              ? Center(child: Text('no_orders'.tr()))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order #${order.orderId}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      _confirmDeleteOrder(order.orderId),
                                  child: const Icon(Icons.delete_outline,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Date: ${DateFormat('yyyy-MM-dd').format(order.orderDate)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Status: ${order.status}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Total: \$${order.totalPrice.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Items:',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    '${item.productName} (x${item.quantity}) - \$${item.unitPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
