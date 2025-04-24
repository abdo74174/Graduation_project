import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // Import for localization

class CustomizeSearchBar extends StatelessWidget {
  const CustomizeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: TextFormField(
              onChanged: (value) {
                // Handle text changes here if needed
              },
              decoration: InputDecoration(
                hintStyle: const TextStyle(
                    fontFamily: "Inria Serif",
                    fontWeight: FontWeight.normal,
                    fontSize: 18),
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
                hintText:
                    'What do you Search for ?'.tr(), // Localized hint text
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
