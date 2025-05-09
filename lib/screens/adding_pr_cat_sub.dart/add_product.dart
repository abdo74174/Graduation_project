// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/subcateoery_model.dart';
import 'package:graduation_project/services/Product/category_service.dart';
import 'package:graduation_project/services/Product/desc_api_ai.dart';
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
  bool _isGeneratingDescription = false;
  final ProductDescriptionService _descriptionService =
      ProductDescriptionService();

  @override
  void initState() {
    super.initState();

    // Fetch categories
    CategoryService().fetchAllCategories().then((fetchedCategories) {
      setState(() {
        _categories = fetchedCategories;
        productCategories =
            fetchedCategories.map((cat) => cat.name).toSet().toList();
      });
    });

    // Fetch subcategories
    SubCategoryService().fetchAllSubCategories().then((fetchedSubCategories) {
      setState(() {
        _subcategories = fetchedSubCategories;
        productSubCategories =
            fetchedSubCategories.map((cat) => cat.name).toSet().toList();
      });
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _comparePriceController.dispose();
    _StockQuantity.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Add New Product"), leading: const BackButton()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BuildTextField(
              controller: _productNameController,
              label: "Product Name",
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            BuildDescriptionField(
              label: "Product Description",
              descriptionController: _descriptionController,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isGeneratingDescription ? null : _generateDescription,
              child: _isGeneratingDescription
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Generate AI Description"),
            ),
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            BuildTextField(
              controller: _StockQuantity,
              label: "Product Quantity",
            ),
            const SizedBox(height: 20),
            ImageUploadSection(
              imageFiles: _imageFiles,
              onTap: _pickImages,
              onRemove: _removeImage,
            ),
            const SizedBox(height: 20),
            PricingSection(
              comparePriceController: _comparePriceController,
              discountController: _discountController,
              priceController: _priceController,
            ),
            const SizedBox(height: 20),
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
                  if (kDebugMode) {
                    print("Error adding product: $e");
                  }
                }
              },
              child: const Text("Add Product"),
            ),
          ],
        ),
      ),
    );
  }

  int getCategoryIdByName(String? name) {
    if (name == null) throw Exception("Category not selected");
    final category = _categories.firstWhere(
      (c) => c.name == name,
      orElse: () => throw Exception("Category not found"),
    );
    return category.categoryId;
  }

  int getSubCategoryIdByName(String? name) {
    if (name == null) throw Exception("Subcategory not selected");
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

  Future<void> _generateDescription() async {
    if (_productNameController.text.isEmpty || selectedCategory == null) {
      showSnackbar(context, "Please enter product name and select a category");
      return;
    }

    setState(() {
      _isGeneratingDescription = true;
    });

    try {
      final description = await _descriptionService.generateDescription(
        productName: _productNameController.text,
        category: selectedCategory!,
        subCategory: selectedSubCategory,
      );
      setState(() {
        _descriptionController.text = description;
      });
    } catch (e) {
      showSnackbar(context, "Failed to generate description: $e");
      if (kDebugMode) {
        print("Error generating description: $e");
      }
    } finally {
      setState(() {
        _isGeneratingDescription = false;
      });
    }
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
        const Text("Product Images",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
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
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: imageFiles
                      .asMap()
                      .entries
                      .map((entry) => _buildImageItem(context, entry.value))
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
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade200,
            image: DecorationImage(
              image: FileImage(imageFile),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () => onRemove(imageFile),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }
}
