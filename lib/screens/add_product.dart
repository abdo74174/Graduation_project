// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/subcateoery_model.dart';
import 'package:graduation_project/services/Product/category_service.dart';
import 'package:graduation_project/services/Product/subcategory_service.dart';
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
  final TextEditingController _StockQuantity = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<File> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();
  String? selectedStatus;
  String? selectedCategory;
  String? selectedSubCategory;
  final String userId = "4";

  List<CategoryModel> _categories = [];
  List<SubCategory> _subcategories = [];
  List<String> productCategories = [];
  List<String> productSubCategories = [];

  List<String> productStatus = ["Used", "New"];

  @override
  void initState() {
    super.initState();

    CategoryService().fetchAllCategories().then((fetchedCategories) {
      setState(() {
        _categories = fetchedCategories;
        productCategories =
            fetchedCategories.map((cat) => cat.name).toSet().toList();
      });
    });

    SubCategoryService().fetchAllSubCategories().then((fetchedSubCategories) {
      setState(() {
        _subcategories = fetchedSubCategories;
        productSubCategories =
            fetchedSubCategories.map((cat) => cat.name).toSet().toList();
        print("----------------------------------------------------------");
        print(fetchedSubCategories);
        print("----------------------------------------------------------");
      });
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
                label: "", descriptionController: _descriptionController),
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
                  selectedSubCategory = null;
                });
              },
            ),
            SizedBox(height: 10),
            BuildDropdown(
              label: "Product SubCategory",
              options: productSubCategories,
              selectedValue: productSubCategories.contains(selectedSubCategory)
                  ? selectedSubCategory
                  : null,
              onChanged: productSubCategories.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        selectedSubCategory = value;
                      });
                    },
            ),
            BuildTextField(
                controller: _StockQuantity, label: "Product Quantity"),
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
                    StockQuantity: int.tryParse(_StockQuantity.text) ?? 1,
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
    final category = _categories.firstWhere(
      (c) => c.name == name,
      orElse: () => throw Exception("Category not found"),
    );
    return category.categoryId;
  }

  int getSubCategoryIdByName(String? name) {
    final subCategory = _subcategories.firstWhere(
      (s) => s.name == name,
      orElse: () => throw Exception("Subcategory not found"),
    );
    return subCategory.subCategoryId;
  }

  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
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
                  children: imageFiles
                      .map((file) => _buildImageItem(context, file))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageItem(BuildContext context, File imageFile) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade200,
            image:
                DecorationImage(image: FileImage(imageFile), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () => onRemove(imageFile),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}
