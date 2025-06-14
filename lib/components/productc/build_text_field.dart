import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // Import for localization

class BuildTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isPercentage;
  final bool isStrikethrough;
  final readOnly;
  final String? Function(String?)? validator;

  const BuildTextField({
    this.readOnly = false,
    super.key,
    required this.controller,
    required this.label,
    this.isPercentage = false,
    this.isStrikethrough = false,
    this.validator,
    required TextInputType keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: readOnly,
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label.tr(), // Use the label with localization
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
        suffixText: isPercentage ? "%" : null,
      ),
      style: TextStyle(
        color: Colors.grey.shade800,
        decoration:
            isStrikethrough ? TextDecoration.lineThrough : TextDecoration.none,
      ),
      keyboardType: TextInputType.number,
    );
  }
}
