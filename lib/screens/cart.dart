import 'package:flutter/material.dart';
import 'package:graduation_project/Models/cart_item.dart';
import 'package:graduation_project/Models/cart_model.dart' show CartModel;
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/coupon_management.dart';
import 'package:graduation_project/screens/coupon_management_page.dart';
import 'package:graduation_project/screens/homepage.dart';
import 'package:graduation_project/screens/payment/PaymentScreen.dart';
import 'package:graduation_project/services/Cart/cart_service.dart';
import 'package:graduation_project/services/Product/product_service.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'dart:convert';
import 'package:graduation_project/services/cuoponService.dart';
import 'package:graduation_project/screens/Auth/login_page.dart';

class ShoppingCartPage extends StatefulWidget {
  const ShoppingCartPage({super.key});

  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage>
    with TickerProviderStateMixin {
  CartModel? cartModel;
  Map<int, ProductModel> productMap = {};
  final TextEditingController discountController = TextEditingController();
  double discountPercent = 0.0;
  String appliedCode = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final UserServicee _userServicee = UserServicee();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadEverything();
  }

  @override
  void dispose() {
    _animationController.dispose();
    discountController.dispose();
    super.dispose();
  }

  Future<void> _loadEverything() async {
    final serverStatusService = ServerStatusService();
    final isOnline = await serverStatusService.checkAndUpdateServerStatus();

    if (isOnline) {
      try {
        final products = await ProductService().fetchAllProducts();
        final cart = await CartService().getCart();

        if (mounted) {
          setState(() {
            productMap = {for (var p in products) p.productId: p};
            cartModel = cart;
          });
          _animationController.forward();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load cart: $e'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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

  Future<bool> _checkLoginStatus() async {
    final token = await _userServicee.getJwtToken();
    return token != null;
  }

  void _showLoginPrompt() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'You must be logged in to proceed'.tr(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Login'.tr(),
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            ).then((_) {
              // Reload cart after login to ensure data consistency
              _loadEverything();
            });
          },
        ),
      ),
    );
  }

  void _applyDiscount() async {
    final isLoggedIn = await _checkLoginStatus();
    if (!isLoggedIn) {
      _showLoginPrompt();
      return;
    }

    String enteredCode = discountController.text.trim().toUpperCase();
    try {
      final couponService = CouponService();
      final coupon = await couponService.validateCoupon(enteredCode);

      if (coupon != null) {
        setState(() {
          discountPercent = coupon['discountPercent'] / 100;
          appliedCode = enteredCode;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Discount applied successfully!'.tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        setState(() {
          discountPercent = 0.0;
          appliedCode = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Invalid or expired coupon code'.tr(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      print('Error applying coupon: $e'); // Log for debugging
      setState(() {
        discountPercent = 0.0;
        appliedCode = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Expired Coupon.'.tr(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('remove_item'.tr(),
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          content: Text(
            'remove_item_confirmation'.tr(),
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('cancel'.tr(),
                  style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                final productId = cartModel!.cartItems[index].productId;
                await CartService().deleteFromCart(productId);

                setState(() {
                  cartModel!.cartItems.removeAt(index);
                });

                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text('remove'.tr(), style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cartModel == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(pkColor),
                strokeWidth: 3,
              ),
              SizedBox(height: 16),
              Text(
                'Loading your cart...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final validCartItems = cartModel!.cartItems
        .asMap()
        .entries
        .where((entry) => productMap.containsKey(entry.value.productId))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Text(
          'my_cart'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        leading: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: Colors.grey[700],
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            ),
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: pkColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.local_offer_outlined, color: pkColor),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Cuopon()),
              ),
            ),
          ),
        ],
      ),
      body: validCartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartContent(validCartItems.cast<MapEntry<int, CartItems>>()),
      bottomNavigationBar: validCartItems.isNotEmpty ? _buildBottomBar() : null,
    );
  }

  Widget _buildEmptyCart() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'your_cart_is_empty'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add some items to get started',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: pkColor,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                'Continue Shopping',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(List<MapEntry<int, CartItems>> validCartItems) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Text(
                  '${validCartItems.length} ${validCartItems.length == 1 ? 'Item' : 'Items'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                Spacer(),
                Text(
                  'Swipe to delete',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 20),
              itemCount: validCartItems.length,
              itemBuilder: (context, index) {
                final entry = validCartItems[index];
                final cartItem = entry.value;
                final originalIndex = entry.key;
                final product = productMap[cartItem.productId]!;

                return Dismissible(
                  key: Key('cart_item_${cartItem.productId}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.centerRight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete_outline,
                            color: Colors.white, size: 28),
                        SizedBox(height: 4),
                        Text(
                          'Delete',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onDismissed: (direction) async {
                    final productId =
                        cartModel!.cartItems[originalIndex].productId;
                    await CartService().deleteFromCart(productId);
                    setState(() {
                      cartModel!.cartItems.removeAt(originalIndex);
                    });
                  },
                  child: _buildCartItemCard(cartItem, originalIndex, product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(
      CartItems cartItem, int originalIndex, ProductModel product) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[100],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: product.images.isNotEmpty
                    ? Image.network(
                        product.images[0],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            defaultProductImage,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        defaultProductImage,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    product.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuantityButton(
                        icon: Icons.remove,
                        onPressed: () => _decrementQuantity(originalIndex),
                        isEnabled: cartItem.quantity > 1,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: pkColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${cartItem.quantity}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: pkColor,
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        icon: Icons.add,
                        onPressed: () => _incrementQuantity(originalIndex),
                        isEnabled: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => _confirmRemoveItem(originalIndex),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  '\$${(product.price * cartItem.quantity).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: pkColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isEnabled,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isEnabled ? pkColor.withOpacity(0.1) : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isEnabled ? pkColor.withOpacity(0.3) : Colors.grey[300]!,
        ),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 18,
          color: isEnabled ? pkColor : Colors.grey[400],
        ),
        onPressed: isEnabled ? onPressed : null,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.local_offer_outlined, color: pkColor),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: discountController,
                    decoration: InputDecoration(
                      hintText: 'enter_discount_code'.tr(),
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _applyDiscount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pkColor,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'apply'.tr(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _buildPriceRow(
                    'subtotal'.tr(), '\$${subtotal.toStringAsFixed(2)}'),
                if (discountPercent > 0) ...[
                  SizedBox(height: 8),
                  _buildPriceRow(
                    'discount'.tr(),
                    '-\$${(subtotal * discountPercent).toStringAsFixed(2)}',
                    color: Colors.green,
                  ),
                ],
                Divider(height: 24, color: Colors.grey[300]),
                _buildPriceRow(
                  'total'.tr(),
                  '\$${total.toStringAsFixed(2)}',
                  isBold: true,
                  fontSize: 18,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final isLoggedIn = await _checkLoginStatus();
                if (!isLoggedIn) {
                  _showLoginPrompt();
                  return;
                }

                final isValid = await _validateStock();
                if (!isValid) return;

                if (appliedCode.isNotEmpty) {
                  final couponService = CouponService();
                  final success = await couponService.useCoupon(appliedCode);
                  if (!success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to use coupon'.tr()),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                    return;
                  }
                }

                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      total: total,
                      cartItems: cartModel!.cartItems,
                    ),
                  ),
                );

                if (result == true && mounted) {
                  await _loadEverything();
                  setState(() {
                    discountPercent = 0.0;
                    appliedCode = '';
                    discountController.clear();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: pkColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.credit_card, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'proceed_to_checkout'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _validateStock() async {
    try {
      final products = await ProductService().fetchAllProducts();
      final productMap = {for (var p in products) p.productId: p};

      for (var item in cartModel!.cartItems) {
        final product = productMap[item.productId];
        if (product == null) {
          await CartService().deleteFromCart(item.productId);
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //         'Product ${item.productId} has been removed as it is no longer available'
          //             .tr()),
          //     backgroundColor: Colors.orange,
          //     behavior: SnackBarBehavior.floating,
          //     shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(12)),
          //   ),
          // );
          setState(() {
            cartModel!.cartItems.removeWhere(
                (cartItem) => cartItem.productId == item.productId);
          });
          return false;
        }
        if (product.StockQuantity < item.quantity) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${'Not enough stock for '.tr()}${product.name}${'. Available:'.tr()} ${product.StockQuantity}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          return false;
        }
      }
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error validating stock: $e'.tr()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return false;
    }
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 16,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            fontSize: fontSize,
            color: color ?? Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            fontSize: fontSize,
            color: color ?? (isBold ? Color(0xFF1A1A1A) : Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
