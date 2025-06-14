// // ignore_for_file: depend_on_referenced_packages

// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:graduation_project/Models/order_model.dart';
// import 'package:graduation_project/services/order/order_service.dart';
// import 'package:shimmer/shimmer.dart';

// class AdminDashboardPage extends StatefulWidget {
//   const AdminDashboardPage({Key? key}) : super(key: key);

//   @override
//   _AdminDashboardPageState createState() => _AdminDashboardPageState();
// }

// class _AdminDashboardPageState extends State<AdminDashboardPage> {
//   final OrderService _orderService = OrderService();
//   List<OrderModel> _orders = [];
//   List<DeliveryPersonModel> _deliveryPersons = [];
//   List<DeliveryPersonRequestModel> _requests = [];
//   Map<String, int> _orderStats = {};
//   bool _isLoading = false;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   Future<void> _fetchData() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = '';
//     });
//     try {
//       final orders = await _orderService.getAllOrders();
//       final deliveryPersons = await _orderService.getAvailableDeliveryPersons();
//       final requests = await _orderService.getDeliveryPersonRequests();
//       final stats = await _orderService.getOrderStatistics();
//       setState(() {
//         _orders = orders;
//         _deliveryPersons = deliveryPersons;
//         _requests = requests.cast<DeliveryPersonRequestModel>();
//         _orderStats = stats;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _handleRequest(int requestId, String action) async {
//     try {
//       await _orderService.handleDeliveryPersonRequest(requestId, action);
//       await _fetchData();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Request $action successfully'.tr()),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to $action request: $e'.tr()),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//     }
//   }

//   Future<void> _assignDeliveryPerson(int orderId, int deliveryPersonId) async {
//     try {
//       await _orderService.assignDeliveryPerson(orderId, deliveryPersonId);
//       await _fetchData();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Delivery person assigned successfully'.tr()),
//           backgroundColor: Colors.green,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Failed to assign delivery person: $e'.tr()),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primaryColor = Theme.of(context).primaryColor;

//     return Theme(
//       data: Theme.of(context).copyWith(
//         scaffoldBackgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
//         appBarTheme: AppBarTheme(
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           titleTextStyle: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontSize: 24,
//             color: isDark ? Colors.white : Colors.black87,
//           ),
//           iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
//         ),
//       ),
//       child: Scaffold(
//         extendBodyBehindAppBar: true,
//         appBar: AppBar(
//           flexibleSpace: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   primaryColor.withOpacity(0.8),
//                   primaryColor.withOpacity(0.6),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           title: Text('Admin Dashboard'.tr()),
//         ),
//         floatingActionButton: FloatingActionButton(
//           backgroundColor: primaryColor,
//           onPressed: _fetchData,
//           child: const Icon(Icons.refresh),
//           tooltip: 'Refresh Data'.tr(),
//         ),
//         body: Stack(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: isDark
//                       ? [Colors.grey[900]!, Colors.grey[800]!]
//                       : [Colors.grey[50]!, Colors.white],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//             ),
//             SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 80),
//                   _buildStatisticsCard(isDark),
//                   const SizedBox(height: 16),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Text(
//                       'Delivery Person Requests'.tr(),
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: isDark ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   ),
//                   _isLoading
//                       ? _buildLoadingState()
//                       : _requests.isEmpty
//                           ? _buildEmptyState(isDark, 'No requests found'.tr())
//                           : ListView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               padding: const EdgeInsets.all(16),
//                               itemCount: _requests.length,
//                               itemBuilder: (context, index) =>
//                                   _buildRequestCard(_requests[index], isDark, index),
//                             ),
//                   const SizedBox(height: 16),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Text(
//                       'Assign Orders'.tr(),
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: isDark ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   ),
//                   _isLoading
//                       ? _buildLoadingState()
//                       : _orders.isEmpty
//                           ? _buildEmptyState(isDark, 'No orders found'.tr())
//                           : ListView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               padding: const EdgeInsets.all(16),
//                               itemCount: _orders.length,
//                               itemBuilder: (context, index) =>
//                                   _buildOrderCard(_orders[index], isDark, index),
//                             ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatisticsCard(bool isDark) {
//     final data = _orderStats.entries
//         .toList().asMap()
//         .entries
//         .map((entry) => PieChartSectionData(
//               color: _getStatusColor(entry.value.key),
//               value: entry.value.value.toDouble(),
//               title: '${entry.value.key}\n${entry.value.value}',
//               radius: 60,
//               titleStyle: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//             ))
//         .toList();

//     return Card(
//       margin: const EdgeInsets.all(16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       elevation: 4,
//       color: isDark ? Colors.grey[850] : Colors.white,
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Order Statistics'.tr(),
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: isDark ? Colors.white : Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               height: 200,
//               child: PieChart(
//                 PieChartData(
//                   sections: data,
//                   centerSpaceRadius: 40,
//                   sectionsSpace: 2,
//                   borderData: FlBorderData(show: false),
//                 ),
//                 swapAnimationDuration: const Duration(milliseconds: 300),
//                 swapAnimationCurve: Curves.easeInOut,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'pending':
//         return Colors.grey;
//       case 'processing':
//         return Colors.orange;
//       case 'shipped':
//         return Colors.blue;
//       case 'delivered':
//         return Colors.green;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   Widget _buildRequestCard(DeliveryPersonRequestModel request, bool isDark, int index) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0, end: 1),
//       duration: Duration(milliseconds: 300 + (index * 100)),
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(0, 20 * (1 - value)),
//           child: Opacity(
//             opacity: value,
//             child: child,
//           ),
//         );
//       },
//       child: Card(
//         margin: const EdgeInsets.only(bottom: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         elevation: 4,
//         color: isDark ? Colors.grey[850]!.withOpacity(0.8) : Colors.white.withOpacity(0.95),
//         child: ListTile(
//           contentPadding: const EdgeInsets.all(16),
//           title: Text(
//             request.name,
//             style: TextStyle(
//               fontWeight: FontWeight.w700,
//               fontSize: 16,
//               color: isDark ? Colors.white : Colors.black87,
//             ),
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Email: ${request.email}'.tr()),
//               Text('Phone: ${request.phone}'.tr()),
//               Text('Address: ${request.address}'.tr()),
//               Text('Status: ${request.status}'.tr()),
//             ],
//           ),
//           trailing: PopupMenuButton<String>(
//             onSelected: (value) async {
//               if (value == 'contact') {
//                 // Implement contact logic (e.g., open email client)
//               } else {
//                 await _handleRequest(request.id, value);
//               }
//             },
//             itemBuilder: (context) => [
//               PopupMenuItem(value: 'approve', child: Text('Approve'.tr())),
//               PopupMenuItem(value: 'reject', child: Text('Reject'.tr())),
//               PopupMenuItem(value: 'contact', child: Text('Contact'.tr())),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildOrderCard(OrderModel order, bool isDark, int index) {
//     return TweenAnimationBuilder<double>(
//       tween: Tween(begin: 0, end: 1),
//       duration: Duration(milliseconds: 300 + (index * 100)),
//       builder: (context, value, child) {
//         return Transform.translate(
//           offset: Offset(0, 20 * (1 - value)),
//           child: Opacity(
//             opacity: value,
//             child: child,
//           ),
//         );
//       },
//       child: Card(
//         margin: const EdgeInsets.only(bottom: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         elevation: 4,
//         color: isDark ? Colors.grey[850]!.withOpacity(0.8) : Colors.white.withOpacity(0.95),
//         child: ExpansionTile(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           backgroundColor: Colors.transparent,
//           collapsedBackgroundColor: Colors.transparent,
//           leading: CircleAvatar(
//             backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
//             child: Icon(Icons.local_shipping, color: Theme.of(context).primaryColor),
//           ),
//           title: Text(
//             '${'Order ID:'.tr()} ${order.orderId}',
//             style: TextStyle(
//               fontWeight: FontWeight.w700,
//               fontSize: 16,
//               color: isDark ? Colors.white : Colors.black87,
//             ),
//           ),
//           subtitle: Padding(
//             padding: const EdgeInsets.only(top: 8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '${'User:'.tr()} ${order.userName}',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: isDark ? Colors.grey[400] : Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '${'Delivery:'.tr()} ${order.deliveryPersonName ?? 'Unassigned'}',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: isDark ? Colors.grey[400] : Colors.grey[600],
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '${'Total:'.tr()} \$${order.totalPrice.toStringAsFixed(2)}',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: isDark ? Colors.grey[400] : Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           trailing: _buildStatusChip(order.status, isDark),
//           children: [
//             ...order.items.map((item) {
//               return ListTile(
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
//                 leading: Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: const Icon(Icons.image, color: Colors.grey, size: 20),
//                 ),
//                 title: Text(
//                   item.productName,
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: isDark ? Colors.white : Colors.black87,
//                   ),
//                 ),
//                 subtitle: Text(
//                   '${'Qty:'.tr()} ${item.quantity} | ${'Price:'.tr()} \$${item.unitPrice.toStringAsFixed(2)}',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: isDark ? Colors.grey[400] : Colors.grey[600],
//                   ),
//                 ),
//               );
//             }).toList(),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Assign Delivery:'.tr(),
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: isDark ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                   DropdownButton<int>(
//                     value: order.deliveryPersonId,
//                     hint: Text('Select Delivery Person'.tr()),
//                     onChanged: (value) async {
//                       if (value != null) {
//                         bool? confirm = await showDialog(
//                           context: context,
//                           builder: (context) => AlertDialog(
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                             title: Text('Confirm Assignment'.tr()),
//                             content: Text(
//                                 'Assign this order to ${(_deliveryPersons.firstWhere((dp) => dp.id == value)).name}?'
//                                     .tr()),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(context, false),
//                                 child: Text('Cancel'.tr()),
//                               ),
//                               ElevatedButton(
//                                 onPressed: () => Navigator.pop(context, true),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Theme.of(context).primaryColor,
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                 ),
//                                 child: Text('Confirm'.tr()),
//                               ),
//                             ],
//                           ),
//                         );
//                         if (confirm == true) {
//                           await _assignDeliveryPerson(order.orderId, value);
//                         }
//                       }
//                     },
//                     items: _deliveryPersons.map((dp) {
//                       return DropdownMenuItem<int>(
//                         value: dp.id,
//                         child: Text(dp.name.tr()),
//                       );
//                     }).toList(),
//                     style: TextStyle(color: isDark ? Colors.white : Colors.black87),
//                     dropdownColor: isDark ? Colors.grey[800] : Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatusChip(String status, bool isDark) {
//     Color chipColor;
//     switch (status.toLowerCase()) {
//       case 'pending':
//         chipColor = Colors.grey;
//         break;
//       case 'processing':
//         chipColor = Colors.orange;
//         break;
//       case 'shipped':
//         chipColor = Colors.blue;
//         break;
//       case 'delivered':
//         chipColor = Colors.green;
//         break;
//       case 'cancelled':
//         chipColor = Colors.red;
//         break;
//       default:
//         chipColor = Colors.grey;
//     }

//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: chipColor.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: chipColor.withOpacity(0.3)),
//       ),
//       child: Text(
//         status.tr(),
//         style: TextStyle(
//           color: chipColor,
//           fontWeight: FontWeight.w600,
//           fontSize: 12,
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingState() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: 5,
//       itemBuilder: (context, index) {
//         return Shimmer.fromColors(
//           baseColor: Colors.grey[300]!,
//           highlightColor: Colors.grey[100]!,
//           child: Container(
//             margin: const EdgeInsets.only(bottom: 16),
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             height: 100,
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildEmptyState(bool isDark, String message) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             Icons.inbox,
//             size: 64,
//             color: isDark ? Colors.grey[400] : Colors.grey[600],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             message,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: isDark ? Colors.grey[400] : Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class ChartData {
//   final String status;
//   final int count;

//   ChartData(this.status, this.count);
// }

// class DeliveryPersonRequestModel {
//   final int id;
//   final String name;
//   final String email;
//   final String phone;
//   final String address;
//   final String status;
//   final String? cardImageUrl;
//   final String? heraImageUrl;

//   DeliveryPersonRequestModel({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//     required this.address,
//     required this.status,
//     this.cardImageUrl,
//     this.heraImageUrl,
//   });

//   factory DeliveryPersonRequestModel.fromJson(Map<String, dynamic> json) {
//     return DeliveryPersonRequestModel(
//       id: json['id'] ?? 0,
//       name: json['name'],

//       email: json['email'] ?? '',
//       phone: json['phone'] ?? '',
//       address: json['address'] ?? '',
//       status: json['status'] ?? 'Pending',
//       cardImageUrl: json['cardImageUrl'],
//       heraImageUrl: json['heraImageUrl'],
//     );
//   }
// }
