import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'coupon_management.dart'; // Import Coupon class

class UserCouponsPage extends StatefulWidget {
  final String userId;

  const UserCouponsPage({super.key, required this.userId});

  @override
  _UserCouponsPageState createState() => _UserCouponsPageState();
}

class _UserCouponsPageState extends State<UserCouponsPage> {
  List<Coupon> coupons = [];

  @override
  void initState() {
    super.initState();
    fetchUserCoupons();
  }

  Future<void> fetchUserCoupons() async {
    final response = await http.get(
      Uri.parse('https://your-api.com/api/coupons/user/${widget.userId}'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        coupons = data.map((json) => Coupon.fromJson(json)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Coupons'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: coupons.isEmpty
            ? const Center(child: Text('No coupons available'))
            : ListView.builder(
                itemCount: coupons.length,
                itemBuilder: (context, index) {
                  final coupon = coupons[index];
                  return Card(
                    child: ListTile(
                      title: Text('Coupon: ${coupon.code}'),
                      subtitle: Text('Discount: ${coupon.discountPercentage}%'),
                      trailing: coupon.isUsed
                          ? const Text('Used',
                              style: TextStyle(color: Colors.red))
                          : const Text('Active',
                              style: TextStyle(color: Colors.green)),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
