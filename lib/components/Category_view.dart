// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';

class CategoryView extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final Color borderColor;
  const CategoryView(
      {super.key,
      required this.category,
      required this.onTap,
      required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
                image: DecorationImage(
                    image: AssetImage(category.imageUrl), // Load image here
                    fit: BoxFit.fill // Adjust image fit
                    ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              category.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
