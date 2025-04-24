import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // Import for localization

class BuildDescriptionField extends StatelessWidget {
  final TextEditingController descriptionController;
  final String label; // Declare label parameter

  const BuildDescriptionField({
    super.key,
    required this.descriptionController,
    required this.label, // Pass label to the constructor
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: label.tr(), // Use the label parameter with localization
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
      ),
      style: TextStyle(color: Colors.grey.shade800),
    );
  }
}
