import 'package:flutter/material.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _comparePriceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<String> productStatus = ["Available", "Out of Stock"];
  List<String> productCategories = ["Medicine", "Equipment"];
  List<String> productSubCategories = ["Dental", "Surgical"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add New Product"),
        leading: BackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Product Name", _productNameController),
            SizedBox(height: 10),
            _buildDescriptionField(),
            SizedBox(height: 10),
            _buildDropdown("Product Status", productStatus),
            SizedBox(height: 10),
            _buildDropdown("Product Category", productCategories),
            _buildDropdown("Product SubCategory", productSubCategories),
            SizedBox(height: 20),
            _buildImageSection(),
            SizedBox(height: 20),
            _buildPricingSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Product Images",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildImageItem('assets/images/photo.jpg'),
              _buildImageItem('assets/images/photo2.jpg'),
              _buildImageItem('assets/images/photo3.jpg'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageItem(String imagePath) {
    return Container(
      width: 80,
      height: 80,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade200,
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildPricingSection() {
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
              Expanded(child: _buildTextField("Price", _priceController)),
              SizedBox(width: 10),
              Expanded(
                  child: _buildTextField(
                      "Compare at Price", _comparePriceController,
                      isStrikethrough: true)),
            ],
          ),
          SizedBox(height: 10),
          _buildTextField("Discount", _discountController, isPercentage: true),
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

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isPercentage = false, bool isStrikethrough = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
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
        suffixText: isPercentage ? "%" : null,
      ),
      style: TextStyle(
        color: Colors.grey.shade800,
        decoration:
            isStrikethrough ? TextDecoration.lineThrough : TextDecoration.none,
      ),
      keyboardType: TextInputType.number,
    );
  }

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

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
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

  Widget _buildDropdown(String label, List<String> options) {
    return DropdownButtonFormField<String>(
      items: options
          .map((option) => DropdownMenuItem(value: option, child: Text(option)))
          .toList(),
      onChanged: (value) {},
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
      ),
    );
  }
}
