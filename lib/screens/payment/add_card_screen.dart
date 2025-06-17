import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/services/payment/payment_service.dart';
import 'package:graduation_project/core/constants/constant.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  final _cardFormKey = GlobalKey<FormState>();
  CardFieldInputDetails? _cardDetails;

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleAddCard() async {
    if (!_cardFormKey.currentState!.validate() ||
        _cardDetails?.complete != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('invalid_card_details'.tr()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final paymentService = PaymentService();
      // await paymentService.addCustomerCard();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('card_added_successfully'.tr()),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('card_add_failed'.tr(args: [e.toString()])),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'add_new_card'.tr(),
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
                minWidth: isSmallScreen ? screenWidth * 0.85 : 300,
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
                    Text(
                      'add_card_title'.tr(),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 22 : 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                      semanticsLabel: 'add_card_title'.tr(),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'add_card_message'.tr(),
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      semanticsLabel: 'add_card_message'.tr(),
                    ),
                    const SizedBox(height: 24),
                    Form(
                      key: _cardFormKey,
                      child: CardFormField(
                        style: CardFormStyle(
                          backgroundColor: Colors.grey[50]!,
                          borderColor: Colors.grey[200]!,
                          borderRadius: 12,
                          textColor: Color(0xFF1A1A1A),
                          placeholderColor: Colors.grey[500]!,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                        onCardChanged: (details) {
                          setState(() {
                            _cardDetails = details;
                          });
                        },
                      ),
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
                        onPressed: _isLoading ? null : _handleAddCard,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Text(
                                'add_card'.tr(),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
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
