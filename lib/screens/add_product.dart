import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduation_project/components/productc/build_text_field.dart';
import 'package:graduation_project/components/productc/build_description_field.dart';
import 'package:graduation_project/components/productc/build_drop_down.dart';
import 'package:graduation_project/components/productc/pricing_section.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/Product/product_service.dart';

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

  final List<File> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();

  String? selectedStatus;
  String? selectedCategory;
  String? selectedSubCategory;

  final String userId = "4"; // Replace with actual user ID

  List<String> productStatus = ["Available", "Out of Stock"];
  List<String> productCategories =
      categories.map((category) => category.name).toList();
  List<String> productSubCategories =
      subCategories.map((sub) => sub.name).toList();

  Future<void> _pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _imageFiles.addAll(pickedFiles.map((xfile) => File(xfile.path)));
      });
    }
  }

  void _removeImage(File image) {
    setState(() {
      _imageFiles.remove(image);
    });
  }

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
                controller: _productNameController, label: "Product Name"),
            SizedBox(height: 10),
            BuildDescriptionField(
                descriptionController: _descriptionController),
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
            ImageUploadSection(
              imageFiles: _imageFiles,
              onTap: _pickImages,
              onRemove: _removeImage,
            ),
            SizedBox(height: 20),
            PricingSection(
              comparePriceController: _comparePriceController,
              discountController: _discountController,
              priceController: _priceController,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ProductService().addProduct(
                    userId: userId,
                    name: _productNameController.text,
                    description: _descriptionController.text,
                    price: double.tryParse(_priceController.text) ?? 0.0,
                    comparePrice:
                        double.tryParse(_comparePriceController.text) ?? 0.0,
                    discount: double.tryParse(_discountController.text) ?? 0.0,
                    status: selectedStatus!,
                    categoryId: getCategoryIdByName(selectedCategory),
                    subCategoryId: getSubCategoryIdByName(selectedSubCategory),
                    imageFiles: _imageFiles,
                  );
                  showSnackbar(context, "Product added successfully!");
                } catch (e) {
                  showSnackbar(context, "Error: $e");
                  print("Error adding product: $e");
                }
              },
              child: Text("Add Product"),
            ),
          ],
        ),
      ),
    );
  }

  int getCategoryIdByName(String? name) {
    final category = categories.firstWhere((c) => c.name == name);
    return category.categoryId;
  }

  int getSubCategoryIdByName(String? name) {
    final sub = subCategories.firstWhere((s) => s.name == name);
    return sub.subCategoryId;
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class ImageUploadSection extends StatelessWidget {
  final List<File> imageFiles;
  final VoidCallback onTap;
  final Function(File) onRemove;

  const ImageUploadSection({
    super.key,
    required this.imageFiles,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Product Images",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: onTap,
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
                      imageFiles.map((file) => _buildImageItem(file)).toList(),
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
      child: Positioned(
        right: 0,
        top: 0,
        child: GestureDetector(
          onTap: () => onRemove(imageFile),
          child: Container(
            padding: EdgeInsets.all(4),
            color: Colors.black.withOpacity(0.5),
            child: Icon(Icons.remove, color: Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}
