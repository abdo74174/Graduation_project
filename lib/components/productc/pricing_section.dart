import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // Import for localization
import 'package:flutter/services.dart';
import 'package:graduation_project/components/productc/build_text_field.dart';

class PricingSection extends StatefulWidget {
  final TextEditingController priceController;
  final TextEditingController comparePriceController;
  final TextEditingController discountController;
  final VoidCallback? onDiscard;
  final Function(DateTime)? onSchedule;

  const PricingSection({
    super.key,
    required this.priceController,
    required this.comparePriceController,
    required this.discountController,
    this.onDiscard,
    this.onSchedule,
  });

  @override
  State<PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<PricingSection> {
  DateTime? _scheduledDate;

  @override
  void initState() {
    super.initState();
    // Add listeners to automatically calculate the compare price
    widget.priceController.addListener(_updateComparePrice);
    widget.discountController.addListener(_updateComparePrice);

    // Calculate initial compare price if needed
    if (widget.priceController.text.isNotEmpty &&
        widget.discountController.text.isNotEmpty) {
      _updateComparePrice();
    }
  }

  @override
  void dispose() {
    // Remove listeners to avoid memory leaks
    widget.priceController.removeListener(_updateComparePrice);
    widget.discountController.removeListener(_updateComparePrice);
    super.dispose();
  }

  void _updateComparePrice() {
    try {
      final price = double.tryParse(widget.priceController.text) ?? 0.0;
      final discount = double.tryParse(widget.discountController.text) ?? 0.0;

      if (price > 0 && discount > 0) {
        final discountAmount = price * (discount / 100);
        final comparePrice = price - discountAmount;

        // Only update if the value changed to avoid infinite loop
        final formattedComparePrice = comparePrice.toStringAsFixed(2);
        if (widget.comparePriceController.text != formattedComparePrice) {
          widget.comparePriceController.text = formattedComparePrice;
        }
      }
    } catch (e) {
      print('Error updating compare price: $e');
    }
  }

  Widget _buildButton(String text, Color bgColor, Color textColor,
      [bool isOutlined = false, VoidCallback? onPressed]) {
    return Container(
      height: 36,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          side: isOutlined ? BorderSide(color: Colors.black) : BorderSide.none,
          padding: EdgeInsets.symmetric(horizontal: 8),
          textStyle: TextStyle(fontSize: 12),
        ),
        child: Text(text.tr()),
      ),
    );
  }

  // Reset price fields to default values
  void _handleDiscard() {
    widget.priceController.text = "0.00";
    widget.discountController.text = "0";
    // The compare price will automatically update through listeners

    // Call the parent's onDiscard callback if provided
    if (widget.onDiscard != null) {
      widget.onDiscard!();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Pricing information has been reset"),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Show date picker for scheduling
  Future<void> _showSchedulePicker() async {
    final initialDate = _scheduledDate ?? DateTime.now().add(Duration(days: 1));
    final firstDate = DateTime.now();
    final lastDate = DateTime.now().add(Duration(days: 365));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _scheduledDate = pickedDate;
      });

      // Call the parent's onSchedule callback if provided
      if (widget.onSchedule != null) {
        widget.onSchedule!(pickedDate);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Product scheduled for ${_formatDate(pickedDate)}"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Pricing".tr(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (_scheduledDate != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.5))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        _formatDate(_scheduledDate!),
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 16),

          // Price field with currency symbol
          _buildPriceField(
            label: "Price".tr(),
            controller: widget.priceController,
            readOnly: false,
            prefix: '\$',
          ),
          SizedBox(height: 16),

          // Discount field
          _buildPriceField(
            label: "Discount".tr(),
            controller: widget.discountController,
            readOnly: false,
            suffix: '%',
            helperText: "Enter discount percentage",
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          SizedBox(height: 16),

          // Compare at price field - shows calculated value
          _buildPriceField(
            label: "Price After Discount".tr(),
            controller: widget.comparePriceController,
            readOnly: true,
            isStrikethrough: false,
            prefix: '\$',
            hintText: "Calculated based on discount",
            helperText: "This is the final price after applying discount",
            filled: true,
            fillColor: Colors.lightGreen.withOpacity(0.1),
          ),
          SizedBox(height: 20),

          // Wrap instead of Row to avoid overflow
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: [
              _buildButton("Discard".tr(), Colors.white, Colors.black, true,
                  _handleDiscard),
              _buildButton("Schedule".tr(), Colors.blue.shade100, Colors.black,
                  false, _showSchedulePicker),
              _buildButton(
                  "Add Product".tr(), theme.primaryColor, Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    bool isStrikethrough = false,
    String? prefix,
    String? suffix,
    String? hintText,
    String? helperText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool? filled,
    Color? fillColor,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType ?? TextInputType.number,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label.tr(),
        labelStyle: TextStyle(color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600, width: 2),
        ),
        prefixText: prefix,
        suffixText: suffix,
        hintText: hintText?.tr(),
        helperText: helperText?.tr(),
        helperStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        filled: filled ?? readOnly,
        fillColor: fillColor ?? (readOnly ? Colors.grey.shade100 : null),
      ),
      style: TextStyle(
        color: Colors.grey.shade800,
        decoration:
            isStrikethrough ? TextDecoration.lineThrough : TextDecoration.none,
      ),
    );
  }
}
