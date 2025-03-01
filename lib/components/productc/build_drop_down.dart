import 'package:flutter/material.dart';

class BuildDropdown extends StatelessWidget {
  final List<String> options;
  final String label;
  final String? selectedValue;
  final void Function(String?)? onChanged;

  const BuildDropdown({
    super.key,
    required this.options,
    required this.label,
    this.selectedValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedValue, // Handle default selection
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged:
          onChanged ?? (value) {}, // Allow external handling of selection
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}
