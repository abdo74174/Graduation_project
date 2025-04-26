import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/Models/product_model.dart';

class CustomizeSearchBar extends StatelessWidget {
  const CustomizeSearchBar({
    super.key,
    required this.products,
    required this.onChanged,
  });

  final List<ProductModel> products;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: TextFormField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintStyle: const TextStyle(
                  fontFamily: "Inria Serif",
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(50.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                hintText: 'What do you Search for ?'.tr(),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 24),
                  child: Icon(
                    Icons.search,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
