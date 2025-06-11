import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Coupon {
  final int id;
  final String code;
  final double discountPercentage;
  final bool isUsed;
  final int userId;
  final List<int> orderIds;

  Coupon({
    required this.id,
    required this.code,
    required this.discountPercentage,
    required this.isUsed,
    required this.userId,
    required this.orderIds,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'],
      code: json['code'],
      discountPercentage: json['discountPercentage'].toDouble(),
      isUsed: json['isUsed'],
      userId: json['userId'],
      orderIds: List<int>.from(json['orderIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discountPercentage': discountPercentage,
      'isUsed': isUsed,
      'userId': userId,
      'orderIds': orderIds,
    };
  }
}

class CouponManagementPage extends StatefulWidget {
  const CouponManagementPage({super.key});

  @override
  _CouponManagementPageState createState() => _CouponManagementPageState();
}

class _CouponManagementPageState extends State<CouponManagementPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _discountController = TextEditingController();
  final _userIdController = TextEditingController();
  List<Coupon> coupons = [];
  bool isEditing = false;
  int? editingCouponId;

  @override
  void initState() {
    super.initState();
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    try {
      final response =
          await http.get(Uri.parse('https://your-api.com/api/coupon'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          coupons = data.map((json) => Coupon.fromJson(json)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching coupons: $e')),
      );
    }
  }

  Future<void> createCoupon() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await http.post(
        Uri.parse('https://your-api.com/api/coupon'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'code': _codeController.text,
          'discountPercentage': double.parse(_discountController.text),
          'userId': int.parse(_userIdController.text),
          'isUsed': false,
          'orderIds': [],
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coupon created successfully')),
        );
        fetchCoupons();
        _clearForm();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating coupon: $e')),
      );
    }
  }

  Future<void> updateCoupon() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final response = await http.put(
        Uri.parse('https://your-api.com/api/coupon/$editingCouponId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': editingCouponId,
          'code': _codeController.text,
          'discountPercentage': double.parse(_discountController.text),
          'userId': int.parse(_userIdController.text),
          'isUsed': false,
          'orderIds':
              coupons.firstWhere((c) => c.id == editingCouponId).orderIds,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coupon updated successfully')),
        );
        fetchCoupons();
        _clearForm();
        setState(() {
          isEditing = false;
          editingCouponId = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating coupon: $e')),
      );
    }
  }

  Future<void> deleteCoupon(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('https://your-api.com/api/coupon/$id'),
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coupon deleted successfully')),
        );
        fetchCoupons();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting coupon: $e')),
      );
    }
  }

  void _clearForm() {
    _codeController.clear();
    _discountController.clear();
    _userIdController.clear();
  }

  void _editCoupon(Coupon coupon) {
    setState(() {
      isEditing = true;
      editingCouponId = coupon.id;
      _codeController.text = coupon.code;
      _discountController.text = coupon.discountPercentage.toString();
      _userIdController.text = coupon.userId.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Coupons'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _codeController,
                    decoration: const InputDecoration(labelText: 'Coupon Code'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a coupon code';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _discountController,
                    decoration:
                        const InputDecoration(labelText: 'Discount Percentage'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a discount percentage';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _userIdController,
                    decoration: const InputDecoration(labelText: 'User ID'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a user ID';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid user ID';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: isEditing ? updateCoupon : createCoupon,
                        child:
                            Text(isEditing ? 'Update Coupon' : 'Create Coupon'),
                      ),
                      if (isEditing)
                        ElevatedButton(
                          onPressed: () {
                            _clearForm();
                            setState(() {
                              isEditing = false;
                              editingCouponId = null;
                            });
                          },
                          child: const Text('Cancel'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: coupons.isEmpty
                  ? const Center(child: Text('No coupons available'))
                  : ListView.builder(
                      itemCount: coupons.length,
                      itemBuilder: (context, index) {
                        final coupon = coupons[index];
                        return Card(
                          child: ListTile(
                            title: Text('Code: ${coupon.code}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Discount: ${coupon.discountPercentage}%'),
                                Text('User ID: ${coupon.userId}'),
                                Text(
                                    'Status: ${coupon.isUsed ? 'Used' : 'Active'}'),
                                Text(
                                    'Orders: ${coupon.orderIds.isEmpty ? 'None' : coupon.orderIds.join(', ')}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editCoupon(coupon),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: Text(
                                            'Are you sure you want to delete coupon ${coupon.code}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              deleteCoupon(coupon.id);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
      ),
    );
  }
}
