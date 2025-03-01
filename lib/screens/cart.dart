import 'package:flutter/material.dart';
import 'package:graduation_project/components/cart/cart_item.dart';
import 'package:graduation_project/components/cart/checkout_button.dart';
import 'package:graduation_project/components/cart/total_amount_row.dart';
import 'package:graduation_project/screens/homepage.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int quantity1 = 1;
  int quantity2 = 2;
  int price1 = 300;
  int price2 = 150;
  String selectedCategory = 'All';
  String selectedSort = 'Price: Low to High';

  int get totalAmount => (quantity1 * price1) + (quantity2 * price2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('My Cart',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
            SizedBox(width: 10),
            Icon(Icons.favorite_border, color: Colors.black),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return HomePage();
              }));
            },
            child: Icon(Icons.arrow_back, color: Colors.black)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Items',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    DropdownButton<String>(
                      value: selectedSort,
                      items: ['Price: Low to High', 'Price: High to Low']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedSort = newValue!;
                        });
                      },
                    ),
                    SizedBox(width: 10),
                    DropdownButton<String>(
                      value: selectedCategory,
                      items: ['All', 'Dental', 'Surgical', 'Therapy']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedCategory = newValue!;
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CartItem(
                    imagePath: 'assets/images/photo.jpg',
                    price: 400,
                    oldPrice: '600',
                    title: 'Anesthesia Machine WATO EX-20',
                    quantity: 3,
                    onQuantityChanged: (value) {
                      setState(() => quantity2 = value);
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: CartItem(
                    imagePath: 'assets/images/photo2.jpg',
                    oldPrice: '400',
                    price: 300,
                    onQuantityChanged: (value) {
                      setState(() => quantity2 = value);
                    },
                    quantity: 4,
                    title: 'Air Compressing Therapy Device Power-Q1000 Plus',
                  ),
                ),
              ],
            ),
            Divider(),
            totalAmountRow(),
            SizedBox(height: 20),
            Column(
              children: [
                checkoutButton(),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {},
                  child: Text('Continue Shopping',
                      style: TextStyle(color: Colors.black)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
