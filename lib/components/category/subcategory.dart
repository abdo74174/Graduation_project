import 'package:flutter/material.dart';
import 'package:graduation_project/Models/subcateoery_model.dart';

class SubCategoryView extends StatelessWidget {
  final SubCategory subCategory;
  final VoidCallback onTap;
  final Color? borderColor;

  const SubCategoryView(
      {super.key, required this.subCategory,
      required this.onTap,
      required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor!, width: 2),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(3, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 1, // Ensures square shape
                  child: Image.asset(
                    "assets/images/eye-exam 1.jpg",
                    fit: BoxFit.cover, // Fill without distortion
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
            Text(
              subCategory.name,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
