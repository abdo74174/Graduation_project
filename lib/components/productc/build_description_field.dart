import 'package:flutter/material.dart';

class BuildDescriptionField extends StatelessWidget {
  final TextEditingController descriptionController;

  const BuildDescriptionField({super.key, required this.descriptionController});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: descriptionController,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: "Product Description",
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
