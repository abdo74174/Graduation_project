import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';

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

  // This method checks if the image is a valid URL, base64, or an asset path.
  ImageProvider getImageProvider(String? image) {
    if (image == null || image.isEmpty) {
      // Default image in case category.image is null or empty
      return const AssetImage("assets/images/category.jpg"); // Fallback image
    }

    // Check if it’s a base64 image
    if (image.startsWith('/9j/')) {
      try {
        return MemoryImage(base64Decode(image));
      } catch (e) {
        // Return fallback image in case of an error
        return const AssetImage("assets/images/category.jpg");
      }
    }

    // Check if it's a valid URL
    if (Uri.tryParse(image)?.isAbsolute == true) {
      return NetworkImage(image);
    }

    // If it's not a URL or base64, treat it as an asset image.
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
