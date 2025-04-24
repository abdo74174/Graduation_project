import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // Import for localization
import 'package:graduation_project/components/productc/build_text_field.dart';

class PricingSection extends StatelessWidget {
  final TextEditingController priceController;
  final TextEditingController comparePriceController;
  final TextEditingController discountController;

  const PricingSection({
    super.key,
    required this.priceController,
    required this.comparePriceController,
    required this.discountController,
  });

  Widget _buildButton(String text, Color bgColor, Color textColor,
      [bool isOutlined = false]) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        side: isOutlined ? BorderSide(color: Colors.black) : BorderSide.none,
      ),
      child: Text(text.tr()), // Use .tr() for button text localization
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
              color: const Color.fromARGB(255, 255, 255, 255),
              blurRadius: 3,
              spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pricing".tr(), // Use .tr() for section title localization
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: BuildTextField(
                      label: "Price".tr(), // Localize 'Price' label
                      controller: priceController)),
              SizedBox(width: 10),
              Expanded(
                  child: BuildTextField(
                      readOnly: true,
                      label: "Compare at Price"
                          .tr(), // Localize 'Compare at Price' label
                      controller: comparePriceController,
                      isStrikethrough: true)),
            ],
          ),
          SizedBox(height: 10),
          BuildTextField(
              label: "Discount".tr(), // Localize 'Discount' label
              controller: discountController,
              isPercentage: true),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildButton("Discard".tr(), Colors.white, Colors.black,
                  true), // Localize 'Discard' button
              SizedBox(width: 10),
              _buildButton("Schedule".tr(), Colors.blue.shade100,
                  Colors.black), // Localize 'Schedule' button
              SizedBox(width: 10),
              _buildButton("Add Product".tr(), Colors.blue,
                  Colors.white), // Localize 'Add Product' button
            ],
          )
        ],
      ),
    );
  }
}
