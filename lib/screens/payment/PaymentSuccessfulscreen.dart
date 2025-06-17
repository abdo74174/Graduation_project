import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/screens/UserOrderStatusPage.dart';
import 'package:graduation_project/core/constants/constant.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final double totalAmount;
  final int customerId;
  final String? orderId;

  const PaymentSuccessScreen({
    super.key,
    required this.totalAmount,
    required this.customerId,
    this.orderId,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
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
            semanticsLabel: label,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: isBold ? Color(0xFF1A1A1A) : Colors.grey[700],
            ),
            semanticsLabel: value,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'payment_successful'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Color(0xFF1A1A1A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Color(0xFF1A1A1A),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400,
                minWidth: isSmallScreen
                    ? MediaQuery.of(context).size.width * 0.85
                    : 300,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pkColor,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'payment_successful'.tr(),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 22 : 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                      semanticsLabel: 'payment_successful'.tr(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.orderId != null
                          ? 'payment_success_message_with_order'
                              .tr(args: [widget.orderId!])
                          : 'payment_success_message'.tr(),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      semanticsLabel: widget.orderId != null
                          ? 'payment_success_message_with_order'
                              .tr(args: [widget.orderId!])
                          : 'payment_success_message'.tr(),
                    ),
                    const SizedBox(height: 24),
                    if (widget.orderId != null)
                      _buildPriceRow(
                        'order_id'.tr(),
                        widget.orderId!,
                      ),
                    _buildPriceRow(
                      'order'.tr(),
                      '${widget.totalAmount.toStringAsFixed(2)} EGP',
                    ),
                    _buildPriceRow(
                      'amount'.tr(),
                      '${widget.totalAmount.toStringAsFixed(2)} EGP',
                      isBold: true,
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      height: isSmallScreen ? 48 : 56,
                      decoration: BoxDecoration(
                        color: pkColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: pkColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserOrderStatusPage(
                                userId: widget.customerId,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'go_to_orders'.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
