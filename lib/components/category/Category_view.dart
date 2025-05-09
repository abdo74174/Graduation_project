import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/core/constants/constant.dart';

class CategoryView extends StatelessWidget {
  const CategoryView({
    super.key,
    required this.category,
    required this.onTap,
    required this.borderColor,
  });

  final CategoryModel category;
  final VoidCallback onTap;
  final Color borderColor;

  ImageProvider getImageProvider(String? image) {
    if (image == null || image.isEmpty) {
      return const AssetImage("assets/images/category.jpg"); // Fallback image
    }

    if (image.startsWith('/9j/')) {
      try {
        return MemoryImage(base64Decode(image));
      } catch (e) {
        return const AssetImage("assets/images/category.jpg");
      }
    }

    if (Uri.tryParse(image)?.isAbsolute == true) {
      return NetworkImage(image);
    }

    return AssetImage(image);
  }

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
                  image: getImageProvider(category.image),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Flexible(
              child: Text(
                category.name.tr(), // Adding .tr() here for localization
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(pkColor.value),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
