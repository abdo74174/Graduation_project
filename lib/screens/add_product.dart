import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:graduation_project/components/productc/build_text_field.dart';
import 'package:graduation_project/components/productc/build_description_field.dart';
import 'package:graduation_project/components/productc/build_drop_down.dart';
import 'package:graduation_project/components/productc/pricing_section.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _comparePriceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? selectedStatus;
  String? selectedCategory;
  String? selectedSubCategory;

  List<String> productStatus = ["Available", "Out of Stock"];
  List<String> productCategories = ["Medicine", "Equipment"];
  List<String> productSubCategories = ["Dental", "Surgical"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Product"), leading: BackButton()),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildTextField(
              controller: _productNameController,
              label: "Product Name",
            ),
            SizedBox(height: 10),
            BuildDescriptionField(
              descriptionController: _descriptionController,
            ),
            SizedBox(height: 10),
            BuildDropdown(
              label: "Product Status",
              options: productStatus,
              selectedValue: selectedStatus,
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                });
              },
            ),
            SizedBox(height: 10),
            BuildDropdown(
              label: "Product Category",
              options: productCategories,
              selectedValue: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
            ),
            SizedBox(height: 10),
            BuildDropdown(
              label: "Product SubCategory",
              options: productSubCategories,
              selectedValue: selectedSubCategory,
              onChanged: (value) {
                setState(() {
                  selectedSubCategory = value;
                });
              },
            ),
            SizedBox(height: 20),
            ImageUploadSection(), // قسم رفع الصور
            SizedBox(height: 20),
            PricingSection(
              comparePriceController: _comparePriceController,
              discountController: _discountController,
              priceController: _priceController,
            ),
          ],
        ),
      ),
    );
  }
}

class ImageUploadSection extends StatefulWidget {
  const ImageUploadSection({super.key});

  @override
  _ImageUploadSectionState createState() => _ImageUploadSectionState();
}

class _ImageUploadSectionState extends State<ImageUploadSection> {
  final List<File> _imageFiles = [];
  // final ImagePicker _picker = ImagePicker();

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _imageFiles.add(File(pickedFile.path));
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Product Images",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              // onTap: _pickImage,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade200,
                ),
                child: Icon(Icons.add_a_photo, color: Colors.grey.shade600),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      _imageFiles.map((file) => _buildImageItem(file)).toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageItem(File imageFile) {
    return Container(
      width: 80,
      height: 80,
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade200,
        image: DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover),
      ),
    );
  }
}
