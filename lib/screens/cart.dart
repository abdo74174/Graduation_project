import 'package:flutter/material.dart';
import 'package:graduation_project/Models/cart_item.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/core/constants/constant.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  List<CartItem> cartItems = [
    CartItem(
      id: 1,
      userId: 123,
      product: ProductModel(
        productId: 1,
        name: 'Smart Watch',
        description: 'Electronics',
        price: 55.00,
        isNew: true,
        discount: 10.0,
        subCategoryId: 2,
        categoryId: 1,
        userId: 123,
        images: ['http://example.com/image1.jpg'],
      ),
      quantity: 1,
    ),
    CartItem(
      id: 2,
      userId: 123,
      product: ProductModel(
        productId: 2,
        name: 'Wireless Headphone',
        description: 'Electronics',
        price: 120.00,
        isNew: true,
        discount: 5.0,
        subCategoryId: 3,
        categoryId: 2,
        userId: 123,
        images: ['http://example.com/image2.jpg'],
      ),
      quantity: 1,
    ),
  ];

  final TextEditingController discountController = TextEditingController();
  double discountPercent = 0.0;
  String appliedCode = '';

  double get subtotal => cartItems.fold(
      0, (sum, item) => sum + item.product.price * item.quantity);

  double get total => subtotal * (1 - discountPercent);

  void _applyDiscount() {
    String enteredCode = discountController.text.trim().toUpperCase();
    if (enteredCode == 'SAVE10') {
      setState(() {
        discountPercent = 0.10;
        appliedCode = enteredCode;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Discount applied: 10% OFF')),
      );
    } else {
      setState(() {
        discountPercent = 0.0;
        appliedCode = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid code')),
      );
    }
  }

  void _incrementQuantity(int index) {
    setState(() {
      cartItems[index].quantity++;
    });
  }

  void _decrementQuantity(int index) {
    setState(() {
      if (cartItems[index].quantity > 1) {
        cartItems[index].quantity--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('My Cart',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: cartItems.length,
          itemBuilder: (context, index) {
            final item = cartItems[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        "assets/images/offer.avif",
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(item.product.description,
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _quantityButton(
                                  icon: Icons.remove,
                                  onPressed: () => _decrementQuantity(index)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('${item.quantity}',
                                    style: const TextStyle(fontSize: 16)),
                              ),
                              _quantityButton(
                                  icon: Icons.add,
                                  onPressed: () => _incrementQuantity(index)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _confirmRemoveItem(index);
                          },
                          child: const Icon(Icons.delete_outline,
                              color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        Text(
                            '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
          ],
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: discountController,
                    decoration: InputDecoration(
                      hintText: 'Enter Discount Code',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _applyDiscount,
                  child: Text('Apply',
                      style: TextStyle(
                          color: pkColor, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 12),
            _buildPriceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
            if (discountPercent > 0)
              _buildPriceRow('Discount (${(discountPercent * 100).toInt()}%)',
                  '-\$${(subtotal * discountPercent).toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            _buildPriceRow('Total', '\$${total.toStringAsFixed(2)}',
                isBold: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: pkColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Checkout',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 18),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  void _confirmRemoveItem(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Item'),
          content: const Text(
              'Are you sure you want to remove this item from your cart?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  cartItems.removeAt(index);
                });
                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item removed from cart')),
                );
              },
              child: const Text(
                'Remove',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
