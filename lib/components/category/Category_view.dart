// ignore_for_file: file_names

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';

class CategoryView extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  final Color borderColor;
  const CategoryView({
    super.key,
    required this.category,
    required this.onTap,
    required this.borderColor,
  });

  ImageProvider getImageProvider(String? image) {
    if (image == null || image.isEmpty) {
      return const AssetImage("assets/images/Furniture.jpg");
    }

    // check if it’s base64 image
    if (image.startsWith('/9j/')) {
      try {
        return MemoryImage(base64Decode(image));
      } catch (e) {
        return const AssetImage("assets/images/Furniture.jpg");
      }
    }

    // check if it's a valid URL
    if (Uri.tryParse(image)?.isAbsolute == true) {
      return NetworkImage(image);
    }

    // fallback to asset image
    return const AssetImage("assets/images/Furniture.jpg");
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
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
