import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/Models/cart_item.dart';
import 'package:graduation_project/Models/user_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/screens/payment/PaymentSuccessfulscreen.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:graduation_project/services/USer/sign.dart';
import 'package:graduation_project/services/cart/cart_service.dart';
import 'package:graduation_project/services/order/order_service.dart';
import 'package:graduation_project/services/payment/payment_service.dart';
import 'package:graduation_project/services/product/product_service.dart';
import 'package:graduation_project/screens/payment/add_card_screen.dart';

class Logger {
  static void log(String method, String message) {
    final timestamp = DateTime.now().toIso8601String();
    debugPrint('[$timestamp] [$method] $message');
  }
}

class PaymentScreen extends StatefulWidget {
  final double total;
  final List<CartItems> cartItems;

  const PaymentScreen({
    super.key,
    required this.total,
    required this.cartItems,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  String _selectedPaymentMethod = 'card';
  bool _isProcessing = false;
  int? _customerId;
  List<dynamic> _savedCards = [];
  bool _isLoadingCards = true;
  late List<CartItems> _filteredCartItems;
  UserModel? user;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  String? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _filteredCartItems =
        widget.cartItems.where((item) => item.productId != 42).toList();
    _setupAnimations();
    _fetchUserData();
    Logger.log('PaymentScreen.initState', 'Initializing PaymentScreen');
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      final email = await UserServicee().getEmail();
      if (email == null || email.isEmpty) {
        Logger.log('PaymentScreen._fetchUserData',
            'No email found in SharedPreferences');
        return;
      }
      final fetchedUser = await USerService().fetchUserByEmail(email);
      if (fetchedUser != null && mounted) {
        setState(() {
          user = fetchedUser;
          _selectedAddress = fetchedUser.address ?? 'sohag';
        });
        await _loadCustomerId();
      } else {
        Logger.log('PaymentScreen._fetchUserData', 'User not found');
      }
    } catch (e, stackTrace) {
      Logger.log('PaymentScreen._fetchUserData',
          'Error fetching user: $e\n$stackTrace');
    }
  }

  Future<void> _loadCustomerId() async {
    const method = 'PaymentScreen._loadCustomerId';
    Logger.log(method, 'Starting to load customer ID');
    try {
      final customerId = await UserServicee().getUserId();
      if (customerId == null || customerId.isEmpty) {
        throw Exception('Customer ID is null or empty');
      }
      if (mounted) {
        setState(() {
          _customerId = int.parse(customerId);
          Logger.log(method, 'Set _customerId to $_customerId');
        });
        await _fetchSavedCards();
      }
    } catch (e, stackTrace) {
      Logger.log(method, 'Failed to load customer ID: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('failed_to_load_customer'.tr(args: [e.toString()]))),
        );
        setState(() => _isLoadingCards = false);
      }
    }
  }

  Future<void> _fetchSavedCards() async {
    const method = 'PaymentScreen._fetchSavedCards';
    if (_customerId == null) {
      Logger.log(method, 'Customer ID is null, skipping card fetch');
      if (mounted) setState(() => _isLoadingCards = false);
      return;
    }

    try {
      setState(() => _isLoadingCards = true);
      final response = await PaymentService().getCustomerCards(_customerId!);
      if (mounted) {
        setState(() {
          _savedCards = (response['cards'] as List?) ?? [];
          _isLoadingCards = false;
        });
        Logger.log(method, 'Fetched ${_savedCards.length} cards');
      }
    } catch (e, stackTrace) {
      Logger.log(method, 'Failed to load cards: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('failed_to_load_cards'.tr(args: [e.toString()]))),
        );
        setState(() => _isLoadingCards = false);
      }
    }
  }

  Map<String, dynamic>? get _lastCard {
    if (_savedCards.isEmpty) return null;
    return _savedCards.last;
  }

  Future<Map<String, dynamic>> _createPaymentIntent(double amount) async {
    const method = 'PaymentScreen._createPaymentIntent';
    Logger.log(method, 'Creating payment intent for amount: $amount');

    if (_customerId == null) {
      throw Exception('customer_id_missing'.tr());
    }

    try {
      final response = await PaymentService().createPaymentIntent(
        amount: amount,
        currency: 'egp',
        customerId: _customerId!,
      );
      Logger.log(method, 'Payment intent created: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      Logger.log(method, 'Failed to create payment intent: $e\n$stackTrace');
      throw Exception('payment_intent_failed'.tr(args: [e.toString()]));
    }
  }

  Future<bool> _processPayment(BuildContext context, double amount) async {
    const method = 'PaymentScreen._processPayment';
    Logger.log(method, 'Starting payment process for amount: $amount');

    try {
      if (_savedCards.isEmpty && _selectedPaymentMethod == 'card') {
        Logger.log(method, 'No saved cards available');
        throw Exception('no_cards_added'.tr());
      }

      final paymentIntent = await _createPaymentIntent(amount);
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Medical Store',
          allowsDelayedPaymentMethods: true,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'EG',
            testEnv: true,
          ),
        ),
      );
      Logger.log(method, 'Payment sheet initialized');

      await Stripe.instance.presentPaymentSheet();
      Logger.log(method, 'Payment sheet presented successfully');

      final verification = await PaymentService()
          .verifyPayment(paymentIntentId: paymentIntent['id']);
      if (verification['status'] != 'succeeded') {
        throw Exception(
            'Payment verification failed: ${verification['status']}');
      }

      return true;
    } on StripeException catch (e) {
      Logger.log(method, 'StripeException: ${e.error.localizedMessage}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('payment_failed'
                .tr(args: [e.error.localizedMessage ?? 'Unknown error'])),
          ),
        );
      }
      return false;
    } catch (e, stackTrace) {
      Logger.log(method, 'General payment error: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('payment_failed'.tr(args: [e.toString()]))),
        );
      }
      return false;
    }
  }

  Future<bool> _validateStock() async {
    const method = 'PaymentScreen._validateStock';
    Logger.log(
        method, 'Validating stock for ${_filteredCartItems.length} items');

    try {
      final products = await ProductService().fetchAllProducts();
      final productMap = {for (var p in products) p.productId: p};

      for (var item in _filteredCartItems) {
        final product = productMap[item.productId];
        if (product == null) {
          throw Exception(
              'product_not_found'.tr(args: [item.productId.toString()]));
        }
        if (product.StockQuantity < item.quantity) {
          throw Exception('insufficient_stock'
              .tr(args: [product.name, product.StockQuantity.toString()]));
        }
      }
      Logger.log(method, 'Stock validation passed');
      return true;
    } catch (e, stackTrace) {
      Logger.log(method, 'Stock validation failed: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('validation_failed'.tr(args: [e.toString()]))),
        );
      }
      return false;
    }
  }

  Future<void> _updateStock() async {
    const method = 'PaymentScreen._updateStock';
    Logger.log(method, 'Updating stock for ${_filteredCartItems.length} items');

    try {
      final products = await ProductService().fetchAllProducts();
      final productMap = {for (var p in products) p.productId: p};

      for (var item in _filteredCartItems) {
        final product = productMap[item.productId];
        if (product != null) {
          final newStock = product.StockQuantity - item.quantity;
          await ProductService()
              .updateProductStock(product.productId, newStock);
          Logger.log(method,
              'Updated stock for product ${product.productId}: ${product.StockQuantity} -> $newStock');
        } else {
          throw Exception(
              'product_not_found'.tr(args: [item.productId.toString()]));
        }
      }
    } catch (e, stackTrace) {
      Logger.log(method, 'Stock update failed: $e\n$stackTrace');
      throw Exception('stock_update_failed'.tr(args: [e.toString()]));
    }
  }

  Future<void> _createOrder() async {
    const method = 'PaymentScreen._createOrder';
    Logger.log(method, 'Creating order for ${_filteredCartItems.length} items');

    try {
      setState(() => _isProcessing = true);

      if (!await _validateStock()) {
        Logger.log(method, 'Stock validation failed');
        return;
      }

      if (_customerId == null || user == null) {
        throw Exception('customer_id_missing'.tr());
      }

      final items = _filteredCartItems
          .map((item) =>
              {'productId': item.productId, 'quantity': item.quantity})
          .toList();

      await OrderService()
          .createOrder(_customerId!, items, _selectedAddress ?? 'sohag');
      await _updateStock();

      for (var item in _filteredCartItems) {
        await CartService().deleteFromCart(item.productId);
        Logger.log(method, 'Removed product ${item.productId} from cart');
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (c) => PaymentSuccessScreen(
              totalAmount: widget.total + 5.0,
              customerId: _customerId!,
            ),
          ),
        ).then((_) {
          Navigator.pop(context, true);
        });
      }
    } catch (e, stackTrace) {
      Logger.log(method, 'Order creation failed: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('order_failed'.tr(args: [e.toString()]))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _handlePayment() async {
    const method = 'PaymentScreen._handlePayment';
    Logger.log(method, 'Handling payment for total: ${widget.total + 5.0}');

    try {
      if (_filteredCartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('empty_cart'.tr())),
        );
        return;
      }

      setState(() => _isProcessing = true);

      bool paymentSuccessful = false;
      final totalAmount = widget.total + 5.0;

      if (_selectedPaymentMethod == 'card') {
        if (_savedCards.isEmpty) {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCardScreen()),
          );
          if (result == true) {
            await _fetchSavedCards();
          } else {
            Logger.log(method, 'User cancelled adding card');
            setState(() => _isProcessing = false);
            return;
          }
        }
        paymentSuccessful = await _processPayment(context, totalAmount);
      } else {
        paymentSuccessful = true; // Cash on delivery
      }

      if (paymentSuccessful) {
        await _createOrder();
      }
    } catch (e, stackTrace) {
      Logger.log(method, 'Payment handling error: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('payment_error'.tr(args: [e.toString()]))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Widget _buildPriceRow(String label, String amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? Color(0xFF1A1A1A) : Colors.grey[700],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: isBold ? Color(0xFF1A1A1A) : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDisplay() {
    final card = _lastCard;
    if (card == null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Icon(Icons.credit_card_off, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'no_cards_added'.tr(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'add_card_to_continue'.tr(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: pkColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: pkColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.network(
                card['brand']?.toLowerCase() == 'visa'
                    ? 'https://upload.wikimedia.org/wikipedia/commons/0/04/Visa.svg'
                    : 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Mastercard-logo.svg',
                width: 50,
                height: 30,
                color: Colors.white,
                errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.credit_card,
                    color: Colors.white,
                    size: 30),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'default'.tr().toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            '•••• •••• •••• ${card['last4'] ?? 'XXXX'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'expires'.tr().toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${card['exp_month']?.toString().padLeft(2, '0') ?? 'XX'}/${card['exp_year']?.toString().substring(2) ?? 'XX'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'select_payment_method'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          _buildPaymentOption(
            'card',
            'pay_with_card'.tr(),
            Icons.credit_card,
            pkColor,
          ),
          const Divider(height: 1, indent: 60),
          _buildPaymentOption(
            'cod',
            'pay_when_shipped'.tr(),
            Icons.local_shipping,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
      String value, String title, IconData icon, Color color) {
    final isSelected = _selectedPaymentMethod == value;
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? color : Color(0xFF1A1A1A),
          ),
        ),
        trailing: Radio<String>(
          value: value,
          groupValue: _selectedPaymentMethod,
          activeColor: color,
          onChanged: (newValue) {
            setState(() {
              _selectedPaymentMethod = newValue!;
            });
          },
        ),
        onTap: () {
          setState(() {
            _selectedPaymentMethod = value;
          });
        },
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'delivery_address'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 16),
          if (_selectedAddress != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on, color: pkColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedAddress!,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            )
          else
            Text(
              'no_address_selected'.tr(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () async {
                final newAddress = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('enter_address'.tr()),
                    content: TextField(
                      decoration: InputDecoration(
                        labelText: 'address'.tr(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        _selectedAddress = value;
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('cancel'.tr()),
                      ),
                      TextButton(
                        onPressed: () {
                          if (_selectedAddress?.isNotEmpty ?? false) {
                            Navigator.pop(context, _selectedAddress);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('please_enter_valid_address'.tr()),
                              ),
                            );
                          }
                        },
                        child: Text('save'.tr()),
                      ),
                    ],
                  ),
                );
                if (newAddress != null && mounted) {
                  setState(() {
                    _selectedAddress = newAddress;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('address_updated_successfully'.tr()),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              icon: Icon(Icons.edit_location, color: pkColor),
              label: Text(
                _selectedAddress != null
                    ? 'change_address'.tr()
                    : 'add_address'.tr(),
                style: TextStyle(
                  color: pkColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: pkColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.total;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'payment'.tr(),
          style: const TextStyle(
              fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Color(0xFF1A1A1A),
      ),
      body: _isLoadingCards
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(pkColor),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'order_summary'.tr(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildPriceRow('subtotal'.tr(),
                                '${total.toStringAsFixed(2)} EGP'),
                            _buildPriceRow('shipping'.tr(), '5.00 EGP'),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(thickness: 1),
                            ),
                            _buildPriceRow(
                              'total'.tr(),
                              '${(total + 5.0).toStringAsFixed(2)} EGP',
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildAddressSection(),
                      const SizedBox(height: 24),
                      _buildPaymentMethodSelector(),
                      const SizedBox(height: 24),
                      if (_selectedPaymentMethod == 'card') ...[
                        Text(
                          'payment_card'.tr(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildCardDisplay(),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddCardScreen(),
                                ),
                              );
                              if (result == true && mounted) {
                                await _fetchSavedCards();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('card_added_successfully'.tr()),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            icon: Icon(Icons.add, color: pkColor),
                            label: Text(
                              'add_new_card'.tr(),
                              style: TextStyle(
                                color: pkColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: pkColor),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: pkColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: pkColor.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isProcessing ? null : _handlePayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _selectedPaymentMethod == 'card'
                                      ? 'pay_now'.tr()
                                      : 'confirm_order'.tr(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
