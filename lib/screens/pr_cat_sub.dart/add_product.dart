// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/subcateoery_model.dart';
import 'package:graduation_project/screens/homepage.dart';
import 'package:graduation_project/services/Product/category_service.dart';
import 'package:graduation_project/services/Product/desc_api_ai.dart';
import 'package:graduation_project/services/Product/subcategory_service.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduation_project/components/productc/build_text_field.dart';
import 'package:graduation_project/components/productc/build_description_field.dart';
import 'package:graduation_project/components/productc/build_drop_down.dart';
import 'package:graduation_project/components/productc/pricing_section.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/Product/product_service.dart';
import 'package:shimmer/main.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/screens/chat/chat_page.dart';

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

  final _formKey = GlobalKey<FormState>();

  final List<File> _imageFiles = [];
  final ImagePicker _picker = ImagePicker();
  String? selectedStatus;
  String? selectedCategory;
  String? selectedSubCategory;
  String? userId;

  List<CategoryModel> _categories = [];
  List<SubCategory> _subcategories = [];
  List<String> productCategories = [];
  List<String> productSubCategories = [];

  List<String> productStatus = ["New", "Used"];
  bool _isGeneratingDescription = false;
  final ProductDescriptionService _descriptionService =
      ProductDescriptionService();
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    // Initialize pricing fields with default values
    _priceController.text = "0.00";
    _comparePriceController.text = "0.00";
    _discountController.text = "0";
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      // Load user ID
      userId = await UserServicee().getUserId();
      if (userId == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("User ID not found. Please login again.".tr())),
        );
      }

      // Fetch categories
      final fetchedCategories = await CategoryService().fetchAllCategories();
      if (mounted) {
        setState(() {
          _categories = fetchedCategories;
          productCategories =
              fetchedCategories.map((cat) => cat.name).toSet().toList();
        });
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context, "Error loading initial data: $e".tr());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Add New Product".tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        elevation: 0,
        backgroundColor:
            isDark ? theme.appBarTheme.backgroundColor : Colors.white,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
          : Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Basic Information"),
                    Form(
                      key: _formKey,
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 24),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BuildTextField(
                                controller: _productNameController,
                                label: "Product Name".tr(),
                              ),
                              const SizedBox(height: 16),

                              // Product Status
                              _buildStatusSelector(),
                              const SizedBox(height: 16),

                              // Category and Subcategory
                              BuildDropdown(
                                label: "Product Category",
                                options: productCategories,
                                selectedValue: selectedCategory,
                                onChanged: (value) {
                                  _updateSubcategories(value);
                                },
                              ),
                              const SizedBox(height: 16),

                              BuildDropdown(
                                label: "Product SubCategory",
                                options: productSubCategories,
                                selectedValue: selectedSubCategory,
                                onChanged: (value) {
                                  setState(() {
                                    selectedSubCategory = value;
                                  });
                                },
                                enabled:
                                    !_isLoading && selectedCategory != null,
                                hint: _isLoading
                                    ? "Loading subcategories...".tr()
                                    : selectedCategory == null
                                        ? "Select a category first".tr()
                                        : productSubCategories.isEmpty
                                            ? "No subcategories available".tr()
                                            : "Select a subcategory".tr(),
                              ),
                              const SizedBox(height: 16),

                              BuildTextField(
                                controller: _StockQuantity,
                                label: "Product Quantity".tr(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    _buildSectionTitle("Product Description".tr()),
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BuildDescriptionField(
                              label: "Product Description".tr(),
                              descriptionController: _descriptionController,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _isGeneratingDescription
                                  ? null
                                  : _generateDescription,
                              icon: Icon(_isGeneratingDescription
                                  ? null
                                  : Icons.auto_awesome),
                              label: _isGeneratingDescription
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text("Generating...".tr()),
                                      ],
                                    )
                                  : Text("Generate AI Description".tr()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildSectionTitle("Product Images".tr()),
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _imageFiles.isEmpty
                                  ? "Please add at least one product image".tr()
                                  : "${_imageFiles.length} image${_imageFiles.length > 1 ? 's' : ''} selected",
                              style: TextStyle(
                                color: _imageFiles.isEmpty
                                    ? Colors.red
                                    : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ImageUploadSection(
                              imageFiles: _imageFiles,
                              onTap: _pickImages,
                              onRemove: _removeImage,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildSectionTitle("Pricing Information".tr()),
                    Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PricingSection(
                              comparePriceController: _comparePriceController,
                              discountController: _discountController,
                              priceController: _priceController,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        child: _isSubmitting
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text("Adding Product...".tr()),
                                ],
                              )
                            : Text(
                                "Add Product".tr(),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Product Status".tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatusOption("New".tr(), Icons.new_releases),
            ),
            const SizedBox(width: 12),
            Expanded(
              child:
                  _buildStatusOption("Used".tr(), Icons.replay_circle_filled),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusOption(String status, IconData icon) {
    final isSelected = selectedStatus == status;
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        setState(() {
          selectedStatus = status;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? theme.primaryColor.withOpacity(0.1) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? theme.primaryColor : Colors.grey[600],
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: TextStyle(
                color: isSelected ? theme.primaryColor : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_discountController.text.isEmpty) {
        showSnackbar(context, "Please enter a discount percentage".tr());
        return;
      } else if (double.tryParse(_discountController.text) == null) {
        showSnackbar(context, "Please enter a valid discount percentage".tr());
        return;
      } else if (double.tryParse(_discountController.text)! > 100) {
        showSnackbar(
            context, "Discount percentage cannot be greater than 100".tr());
        return;
      }

      await _submitProduct();
    }
  }

  Future<void> _submitProduct() async {
    // Check validation manually since we don't have validators in components
    if (_productNameController.text.isEmpty) {
      showSnackbar(context, "Product name is required".tr());
      return;
    }

    if (selectedCategory == null) {
      showSnackbar(context, "Please select a category".tr());
      return;
    }

    if (selectedCategory != null &&
        selectedSubCategory == null &&
        productSubCategories.isNotEmpty) {
      showSnackbar(context, "Please select a subcategory".tr());
      return;
    }

    if (_StockQuantity.text.isEmpty ||
        int.tryParse(_StockQuantity.text) == null) {
      showSnackbar(context, "Please enter a valid quantity".tr());
      return;
    }

    if (_descriptionController.text.isEmpty) {
      showSnackbar(context, "Description is required".tr());
      return;
    }

    if (_imageFiles.isEmpty) {
      showSnackbar(context, "Please add at least one product image".tr());
      return;
    }

    if (selectedStatus == null) {
      showSnackbar(context, "Please select product status (New or Used)".tr());
      return;
    }

    if (userId == null) {
      showSnackbar(context, "Please login to add a product".tr());
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ProductService().addProduct(
        userId: userId!,
        name: _productNameController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        comparePrice: double.tryParse(_comparePriceController.text) ?? 0.0,
        discount: double.tryParse(_discountController.text) ?? 0.0,
        status: selectedStatus!,
        StockQuantity: int.tryParse(_StockQuantity.text) ?? 1,
        categoryId: getCategoryIdByName(selectedCategory),
        subCategoryId: getSubCategoryIdByName(selectedSubCategory),
        imageFiles: _imageFiles,
      );

      showSnackbar(context, "Product added successfully!".tr());
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } catch (e) {
      showSnackbar(context, "Error: $e".tr());
      if (kDebugMode) {
        print("Error adding product: $e".tr());
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  int getCategoryIdByName(String? name) {
    if (name == null) throw Exception("Category not selected".tr());
    final category = _categories.firstWhere(
      (c) => c.name == name,
      orElse: () => throw Exception("Category not found".tr()),
    );
    return category.categoryId;
  }

  int getSubCategoryIdByName(String? name) {
    if (name == null) throw Exception("Subcategory not selected".tr());
    if (selectedCategory == null) throw Exception("Category not selected".tr());

    final subCategory = _subcategories.firstWhere(
        (s) =>
            s.name == name &&
            s.categoryId == getCategoryIdByName(selectedCategory),
        orElse: () => throw Exception(
              "${"Subcategory".tr()}, $name not found in category ${selectedCategory}",
            ));

    print(
        '✅ Found subcategory: ${subCategory.name} (ID: ${subCategory.subCategoryId}) in category: $selectedCategory');
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
      showSnackbar(
          context, "Please enter product name and select a category".tr());
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
      showSnackbar(context, "Failed to generate description: $e".tr());
      if (kDebugMode) {
        print("Error generating description: $e".tr());
      }
    } finally {
      setState(() {
        _isGeneratingDescription = false;
      });
    }
  }

  // Update subcategories when category changes
  void _updateSubcategories(String? categoryName) async {
    if (categoryName == null) {
      setState(() {
        selectedCategory = null;
        selectedSubCategory = null;
        productSubCategories = [];
        _subcategories = [];
      });
      return;
    }

    setState(() {
      selectedCategory = categoryName;
      selectedSubCategory = null;
      _isLoading = true;
      productSubCategories = []; // Clear existing subcategories
      _subcategories = []; // Clear existing subcategories
    });

    try {
      // Find the category ID for the selected category name
      final category = _categories.firstWhere(
        (cat) => cat.name == categoryName,
        orElse: () => throw Exception('Category not found'.tr()),
      );

      print(
          '🔍 Loading subcategories for category: ${category.name} (ID: ${category.categoryId})');

      // Fetch subcategories for this category ID
      final allSubcategories = await SubCategoryService()
          .fetchSubCategoriesByCategory(category.categoryId);

      // Filter subcategories to only include those matching the selected category ID
      final filteredSubcategories = allSubcategories
          .where((subcat) => subcat.categoryId == category.categoryId)
          .toList();

      print(
          '📊 Filtered ${filteredSubcategories.length} subcategories for category ${category.categoryId}');

      setState(() {
        _subcategories = filteredSubcategories;
        // Create a list of unique subcategory names
        productSubCategories = filteredSubcategories
            .map((subcat) => subcat.name)
            .toSet() // Convert to Set to remove duplicates
            .toList(); // Convert back to List
        _isLoading = false;
      });

      if (filteredSubcategories.isEmpty) {
        showSnackbar(
            context, '${'No subcategories found for '.tr()} ${category.name}');
        print(
            '⚠️ No subcategories found for category ${category.name} (ID: ${category.categoryId})');
      } else {
        print(
            '✅ Loaded ${filteredSubcategories.length} subcategories for ${category.name}');
        print('📝 Subcategories: ${productSubCategories.join(", ")}');
      }
    } catch (e) {
      print('❌ Error loading subcategories: $e');
      setState(() {
        _subcategories = [];
        productSubCategories = [];
        _isLoading = false;
      });
      showSnackbar(context, 'Failed to load subcategories: $e'.tr());
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onTap,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: theme.primaryColor.withOpacity(0.5), width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: theme.primaryColor.withOpacity(0.05),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 36,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Add Images".tr(),
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: imageFiles.isEmpty
                  ? Text(
                      "No images selected".tr(),
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: imageFiles
                            .asMap()
                            .entries
                            .map((entry) => _buildImageItem(
                                context, entry.value, entry.key))
                            .toList(),
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageItem(BuildContext context, File imageFile, int index) {
    final theme = Theme.of(context);

    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: FileImage(imageFile),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image number badge
          Positioned(
            left: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "${index + 1}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Delete button
          Positioned(
            right: -5,
            top: -5,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onRemove(imageFile),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.red[700],
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
