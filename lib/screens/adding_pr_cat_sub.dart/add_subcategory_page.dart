import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/services/Product/category_service.dart';
import 'package:graduation_project/services/Product/subcategory_service.dart';

class AddSubCategoryPage extends StatefulWidget {
  const AddSubCategoryPage({super.key});

  @override
  _AddSubCategoryPageState createState() => _AddSubCategoryPageState();
}

class _AddSubCategoryPageState extends State<AddSubCategoryPage> {
  final _subCategoryFormKey = GlobalKey<FormState>();
  final _subCategoryNameController = TextEditingController();
  final _subCategoryDescController = TextEditingController();
  File? _subCategoryImage;
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  bool _isLoading = false;

  final CategoryService _categoryService = CategoryService();
  final SubCategoryService _subCategoryService = SubCategoryService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() => _isLoading = true);
      final categories = await _categoryService.fetchAllCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Failed to load categories: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _subCategoryImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _addSubCategory() async {
    if (!_subCategoryFormKey.currentState!.validate() ||
        _subCategoryImage == null ||
        _selectedCategory == null) {
      _showError('Please fill all fields, select an image and a category');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _subCategoryService.addSubCategory(
        name: _subCategoryNameController.text,
        description: _subCategoryDescController.text,
        categoryId: _selectedCategory!.categoryId,
        imageFile: _subCategoryImage!,
      );

      _showSuccess('Subcategory added successfully');
      _subCategoryNameController.clear();
      _subCategoryDescController.clear();
      setState(() {
        _subCategoryImage = null;
        _selectedCategory = null;
      });
    } catch (e) {
      _showError('Error adding subcategory: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _subCategoryNameController.dispose();
    _subCategoryDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[850] : Colors.white,
        elevation: 0,
        title: Text(
          'add_subcategory'.tr(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                color: isDark ? Colors.grey[850] : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _subCategoryFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Subcategory Name
                        TextFormField(
                          controller: _subCategoryNameController,
                          decoration: InputDecoration(
                            labelText: 'subcategory_name'.tr(),
                            labelStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600]),
                            filled: true,
                            fillColor:
                                isDark ? Colors.grey[800] : Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.green, width: 2),
                            ),
                          ),
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'please_enter_subcategory_name'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Subcategory Description
                        TextFormField(
                          controller: _subCategoryDescController,
                          decoration: InputDecoration(
                            labelText: 'subcategory_description'.tr(),
                            labelStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600]),
                            filled: true,
                            fillColor:
                                isDark ? Colors.grey[800] : Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.green, width: 2),
                            ),
                          ),
                          maxLines: 3,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        // Category Dropdown
                        DropdownButtonFormField<CategoryModel>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'select_category'.tr(),
                            labelStyle: TextStyle(
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600]),
                            filled: true,
                            fillColor:
                                isDark ? Colors.grey[800] : Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: isDark
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.green, width: 2),
                            ),
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem<CategoryModel>(
                              value: category,
                              child: Text(category.name,
                                  style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'please_select_category'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Image Picker
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color:
                                  isDark ? Colors.grey[800] : Colors.grey[50],
                              border: Border.all(
                                  color: isDark
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (_subCategoryImage == null)
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                        size: 40,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'select_image'.tr(),
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _subCategoryImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                if (_subCategoryImage != null)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: _pickImage,
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: Colors.black54,
                                        child: Icon(Icons.edit,
                                            color: Colors.white, size: 16),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _addSubCategory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            child: Text(
                              'add_subcategory'.tr(),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
