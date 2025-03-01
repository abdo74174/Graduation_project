import 'package:flutter/material.dart';
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
      child: Text(text),
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
          Text("Pricing",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: BuildTextField(
                      label: "Price", controller: priceController)),
              SizedBox(width: 10),
              Expanded(
                  child: BuildTextField(
                      label: "Compare at Price",
                      controller: comparePriceController,
                      isStrikethrough: true)),
            ],
          ),
          SizedBox(height: 10),
          BuildTextField(
              label: "Discount",
              controller: discountController,
              isPercentage: true),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildButton("Discard", Colors.white, Colors.black, true),
              SizedBox(width: 10),
              _buildButton("Schedule", Colors.blue.shade100, Colors.black),
              SizedBox(width: 10),
              _buildButton("Add Product", Colors.blue, Colors.white),
            ],
          )
        ],
      ),
    );
  }
}
