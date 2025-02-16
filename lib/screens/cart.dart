import 'package:flutter/material.dart';
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
                    child: cartItem(
                        'assets/images/photo.jpg',
                        'Anesthesia Machine WATO EX-20',
                        price1,
                        '450',
                        quantity1, (value) {
                  setState(() => quantity1 = value);
                })),
                SizedBox(width: 10),
                Expanded(
                    child: cartItem(
                        'assets/images/photo2.jpg',
                        'Air Compressing Therapy Device Power-Q1000 Plus',
                        price2,
                        '',
                        quantity2, (value) {
                  setState(() => quantity2 = value);
                })),
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

  Widget totalAmountRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Total Amount',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text('\$$totalAmount',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ],
    );
  }

  Widget cartItem(String imagePath, String title, int price, String oldPrice,
      int quantity, Function(int) onQuantityChanged) {
    return Column(
      children: [
        Image.asset(imagePath, width: 100, height: 100, fit: BoxFit.cover),
        SizedBox(height: 5),
        Text(title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('\$$price',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            SizedBox(width: 10),
            if (oldPrice.isNotEmpty)
              Text('\$$oldPrice',
                  style: TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget checkoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent, Colors.cyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return HomePage();
          }));
        },
        child: Text('Check out',
            style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}
