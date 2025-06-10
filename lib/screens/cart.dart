import 'package:flutter/material.dart';
import 'package:graduation_project/Models/cart_item.dart';
import 'package:graduation_project/Models/cart_model.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/homepage.dart';
import 'package:graduation_project/screens/payment/PaymentScreen.dart';
import 'package:graduation_project/services/Cart/car_service.dart';
import 'package:graduation_project/services/Product/product_service.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:easy_localization/easy_localization.dart';

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
  String appliedCode = 'SAVE100';

  @override
  void initState() {
    super.initState();
    _loadEverything();
  }

  Future<void> _loadEverything() async {
    final serverStatusService = ServerStatusService();
    final isOnline = await serverStatusService.checkAndUpdateServerStatus();

    if (isOnline) {
      try {
        final products = await ProductService().fetchAllProducts();
        final cart = await CartService().getCart();

        setState(() {
          productMap = {for (var p in products) p.productId: p};
          cartModel = cart;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          cartModel = dummyCart;
          productMap = {for (var p in dummyProducts) p.productId: p};
        });
      }
    } else {
      setState(() {
        cartModel = dummyCart;
        productMap = {for (var p in dummyProducts) p.productId: p};
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You are offline. Showing dummy cart data.')),
      );
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
        discountPercent = 1;
        appliedCode = enteredCode;
      });
    } else {
      setState(() {
        discountPercent = 0.0;
        appliedCode = '';
      });
    }
  }

  void _incrementQuantity(int index) async {
    setState(() {
      cartModel!.cartItems[index].quantity++;
    });

    final item = cartModel!.cartItems[index];
    await CartService().updateCartItem(item.productId, item.quantity);
  }

  void _decrementQuantity(int index) async {
    if (cartModel!.cartItems[index].quantity > 1) {
      setState(() {
        cartModel!.cartItems[index].quantity--;
      });

      final item = cartModel!.cartItems[index];
      await CartService().updateCartItem(item.productId, item.quantity);
    }
  }

  void _confirmRemoveItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('remove_item'.tr()),
          content: Text('remove_item_confirmation'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () async {
                final productId = cartModel!.cartItems[index].productId;
                await CartService().deleteFromCart(productId);

                setState(() {
                  cartModel!.cartItems.removeAt(index);
                });

                Navigator.pop(context);
              },
              child: Text('remove'.tr(), style: TextStyle(color: Colors.red)),
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
        title: Text('my_cart'.tr(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const HomePage())),
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
                      child: product.images.isNotEmpty
                          ? Image.network(
                              product.images[0],
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              defaultProductImage,
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
                    hintText: 'enter_discount_code'.tr(),
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
                child: Text('apply'.tr(),
                    style:
                        TextStyle(color: pkColor, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 12),
          _buildPriceRow('subtotal'.tr(), '\$${subtotal.toStringAsFixed(2)}'),
          if (discountPercent > 0)
            _buildPriceRow('discount'.tr(),
                '-\$${(subtotal * discountPercent).toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          _buildPriceRow('total'.tr(), '\$${total.toStringAsFixed(2)}',
              isBold: true),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // for (var item in cartModel!.cartItems) {
                //   await CartService().deleteFromCart(item.productId);
                // }
                // setState(() {
                //   cartModel!.cartItems.clear();
                // });
                // ignore: use_build_context_synchronously
                Navigator.push(context, MaterialPageRoute(builder: (con) {
                  return Paymentscreen(
                      total: total, cartItems: cartModel!.cartItems);
                }));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: pkColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'proceed_to_checkout'.tr(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
