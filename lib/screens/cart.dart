import 'package:flutter/material.dart';
import 'package:graduation_project/Models/cart_item.dart';
import 'package:graduation_project/Models/cart_model.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/Cart/car_service.dart';
import 'package:graduation_project/services/Product/product_service.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  CartModel? cartModel;
  Map<int, ProductModel> productMap = {};
  final TextEditingController discountController = TextEditingController();
  double discountPercent = 0.0;
  String appliedCode = '';

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  Future<void> _loadEverything() async {
    try {
      final products = await ProductService().fetchAllProducts();
      final cart = await CartService().getCart();

      setState(() {
        productMap = {for (var p in products) p.productId: p};
        cartModel = cart;
      });

      if (cart.cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🛒 السلة فاضية')),
        );
      }
    } catch (e) {
      print("Error loading cart: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cart: $e')),
      );

      setState(() {
        cartModel = CartModel(id: 0, userId: '', cartItems: []);
      });
    }
  }

  double get subtotal {
    if (cartModel == null) return 0;
    return cartModel!.cartItems.fold(0, (sum, item) {
      final product = productMap[item.productId];
      return sum + ((product?.price ?? 0) * item.quantity);
    });
  }

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

  void _incrementQuantity(int index) async {
    setState(() {
      cartModel!.cartItems[index].quantity++;
    });

    final item = cartModel!.cartItems[index];
    final success =
        await CartService().updateCartItem(item.productId, item.quantity);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Failed to update quantity')),
      );
    }
  }

  void _decrementQuantity(int index) async {
    if (cartModel!.cartItems[index].quantity > 1) {
      setState(() {
        cartModel!.cartItems[index].quantity--;
      });

      final item = cartModel!.cartItems[index];

      print("+++++++++++++++++++++++++++++++++++++");
      print(item.productId);
      print(item.quantity);

      print("+++++++++++++++++++++++++++++++++++++");
      final success =
          await CartService().updateCartItem(item.productId, item.quantity);

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Failed to update quantity')),
        );
      }
    }
  }

  void _confirmRemoveItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Item'),
          content: const Text('Are you sure you want to remove this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Call the API to delete the item
                final productId = cartModel!.cartItems[index].product.productId;
                await CartService().deleteFromCart(productId);

                // Remove from UI
                setState(() {
                  cartModel!.cartItems.removeAt(index);
                });

                Navigator.pop(context); // Close the dialog

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item removed')),
                );
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cartModel == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
          itemCount: cartModel!.cartItems.length,
          itemBuilder: (context, index) {
            final cartItem = cartModel!.cartItems[index];
            final product = productMap[cartItem.productId] ??
                ProductModel(
                  productId: -1,
                  name: 'Unknown Product',
                  description: 'This product is no longer available.',
                  price: 0.0,
                  images: ['https://via.placeholder.com/150'],
                  discount: 0,
                  categoryId: 0,
                  subCategoryId: 0,
                  userId: 0,
                  isNew: false,
                  StockQuantity: 0,
                );

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
                      child: Image.network(
                        product.images.first,
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
                          Text(product.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(product.description,
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
                                child: Text('${cartItem.quantity}',
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
                          onTap: () => _confirmRemoveItem(index),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '\$${(product.price * cartItem.quantity).toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
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

  Widget _buildBottomBar() {
    return Container(
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
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _applyDiscount,
                child: Text('Apply',
                    style:
                        TextStyle(color: pkColor, fontWeight: FontWeight.bold)),
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
              onPressed: () {
                // Handle checkout logic here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: pkColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}
