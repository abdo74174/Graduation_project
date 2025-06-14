import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/Models/cart_item.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/screens/payment/PaymentSuccessfulscreen.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
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

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'card';
  bool _isProcessing = false;
  int? _customerId;
  List<dynamic> _savedCards = [];
  bool _isLoadingCards = true;
  late List<CartItems> _filteredCartItems;

  @override
  void initState() {
    super.initState();
    Logger.log('PaymentScreen.initState', 'Initializing PaymentScreen');
    // Filter out-of-stock items (e.g., productId: 42 with stock 0)
    _filteredCartItems =
        widget.cartItems.where((item) => item.productId != 42).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Logger.log('PaymentScreen.didChangeDependencies', 'Dependencies changed');
    _loadCustomerId();
  }

  Future<void> _loadCustomerId() async {
    const method = 'PaymentScreen._loadCustomerId';
    Logger.log(method, 'Starting to load customer ID');
    try {
      final customerId = await UserServicee().getUserId();
      Logger.log(method,
          'Loaded customerId: $customerId (type: ${customerId.runtimeType})');

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
      Logger.log(method, 'Fetched cards: ${response['cards']}');

      if (mounted) {
        setState(() {
          _savedCards = (response['cards'] as List?) ?? [];
          _isLoadingCards = false;
        });
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

  Future<Map<String, dynamic>> _createPaymentIntent(double amount) async {
    const method = 'PaymentScreen._createPaymentIntent';
    Logger.log(method, 'Creating payment intent for amount: $amount');

    try {
      if (_customerId == null) {
        throw Exception('customer_id_missing'.tr());
      }

      final response = await PaymentService().createPaymentIntent(
        amount: amount,
        currency: 'egp',
        customerId: _customerId!,
      );
      Logger.log(method, 'Payment intent response: $response');
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
      Logger.log(method, 'Payment intent created: ${paymentIntent['id']}');

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Medical Store',
          allowsDelayedPaymentMethods: true,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'EG',
            testEnv: true,
          ),
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'EG',
          ),
        ),
      );
      Logger.log(method, 'Payment sheet initialized');

      await Stripe.instance.presentPaymentSheet();
      Logger.log(method, 'Payment sheet presented successfully');

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
          Logger.log(method, 'Product not found: ${item.productId}');
          throw Exception(
              'product_not_found'.tr(args: [item.productId.toString()]));
        }
        if (product.StockQuantity < item.quantity) {
          Logger.log(method,
              'Insufficient stock for ${product.name}: Available ${product.StockQuantity}, Requested ${item.quantity}');
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
          Logger.log(method,
              'Updating stock for product ${product.productId}: ${product.StockQuantity} -> $newStock');
          await ProductService()
              .updateProductStock(product.productId, newStock);
        } else {
          Logger.log(method, 'Product not found for ID: ${item.productId}');
          throw Exception(
              'product_not_found'.tr(args: [item.productId.toString()]));
        }
      }
      Logger.log(method, 'Stock update completed');
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

      if (_customerId == null) {
        Logger.log(method, 'Customer ID is null');
        throw Exception('customer_id_missing'.tr());
      }

      final items = _filteredCartItems
          .map((item) =>
              {'productId': item.productId, 'quantity': item.quantity})
          .toList();

      await OrderService().createOrder(_customerId!, items);
      Logger.log(method, 'Order created successfully');

      await _updateStock();

      for (var item in _filteredCartItems) {
        await CartService().deleteFromCart(item.productId);
        Logger.log(method, 'Removed product ${item.productId} from cart');
      }

      if (mounted) {
        Logger.log(method, 'Navigating to PaymentSuccessScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => const PaymentSuccessScreen()),
        );
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
        Logger.log(method, 'Processing completed');
      }
    }
  }

  Future<void> _handlePayment() async {
    const method = 'PaymentScreen._handlePayment';
    Logger.log(method, 'Handling payment for total: ${widget.total + 5.0}');

    bool paymentSuccessful = false;
    final totalAmount = widget.total + 5.0;

    try {
      if (_filteredCartItems.isEmpty) {
        Logger.log(method, 'No valid items in cart');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('empty_cart'.tr())),
          );
        }
        return;
      }

      if (_selectedPaymentMethod == 'card' && _savedCards.isEmpty) {
        Logger.log(method, 'No saved cards, navigating to AddCardScreen');
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddCardScreen()),
        );
        if (result == true) {
          await _fetchSavedCards();
        } else {
          Logger.log(method, 'User cancelled adding card');
          return;
        }
      }

      if (_selectedPaymentMethod == 'card') {
        paymentSuccessful = await _processPayment(context, totalAmount);
      } else {
        Logger.log(method, 'Cash on delivery selected');
        paymentSuccessful = true;
      }

      if (paymentSuccessful) {
        Logger.log(method, 'Payment successful, creating order');
        await _createOrder();
      } else {
        Logger.log(method, 'Payment failed');
      }
    } catch (e, stackTrace) {
      Logger.log(method, 'Payment handling error: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('payment_error'.tr(args: [e.toString()]))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const method = 'PaymentScreen.build';
    Logger.log(method,
        'Building UI, isLoadingCards: $_isLoadingCards, savedCards: ${_savedCards.length}');

    final total = widget.total;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('payment'.tr()),
        backgroundColor: Colors.white,
      ),
      body: _isLoadingCards
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'payment'.tr(),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('subtotal'.tr(), style: const TextStyle(fontSize: 18)),
                    Text(
                      '${total.toStringAsFixed(2)} EGP',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('shipping'.tr(), style: const TextStyle(fontSize: 18)),
                    Text(
                      '5.00 EGP',
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(thickness: 1, color: Colors.grey),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('total'.tr(),
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(
                      '${(total + 5.0).toStringAsFixed(2)} EGP',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_savedCards.isNotEmpty)
                  ..._savedCards.map((card) => Container(
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Image.network(
                              card['brand']?.toLowerCase() == 'visa'
                                  ? 'https://upload.wikimedia.org/wikipedia/commons/0/04/Visa.svg'
                                  : 'https://upload.wikimedia.org/wikipedia/commons/2/2a/Mastercard-logo.svg',
                              width: 40,
                              height: 24,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.credit_card),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '•••• •••• •••• ${card['last4'] ?? 'XXXX'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ))
                else
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('no_cards_added'.tr()),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      Logger.log(method, 'Navigating to AddCardScreen');
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddCardScreen()),
                      );
                      if (result == true && mounted) {
                        Logger.log(method,
                            'Card added successfully, refetching cards');
                        await _fetchSavedCards();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('card_added_successfully'.tr())),
                        );
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          'add_new_card'.tr(),
                          style:
                              const TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    child: Column(
                      children: [
                        Text(
                          'select_payment_method'.tr(),
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ListTile(
                          title: Text('pay_with_card'.tr()),
                          leading: Radio<String>(
                            value: 'card',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                                Logger.log(
                                    method, 'Selected payment method: $value');
                              });
                            },
                          ),
                        ),
                        ListTile(
                          title: Text('pay_when_shipped'.tr()),
                          leading: Radio<String>(
                            value: 'cod',
                            groupValue: _selectedPaymentMethod,
                            onChanged: (value) {
                              setState(() {
                                _selectedPaymentMethod = value!;
                                Logger.log(
                                    method, 'Selected payment method: $value');
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 200,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _handlePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4285F4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _selectedPaymentMethod == 'card'
                                  ? 'pay_now'.tr()
                                  : 'confirm_order'.tr(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
