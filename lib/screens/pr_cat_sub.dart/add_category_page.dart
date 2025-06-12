import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/services/Product/category_service.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  final _categoryFormKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  final _categoryDescController = TextEditingController();
  File? _categoryImage;
  bool _isLoading = false;

  final CategoryService _categoryService = CategoryService();

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
          _categoryImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _addCategory() async {
    if (!_categoryFormKey.currentState!.validate() || _categoryImage == null) {
      _showError('Please fill all fields and select an image');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _categoryService.addCategory(
        name: _categoryNameController.text,
        description: _categoryDescController.text,
        imageFile: _categoryImage!,
      );

      _showSuccess('Category added successfully'.tr());
      _categoryNameController.clear();
      _categoryDescController.clear();
      setState(() => _categoryImage = null);
    } catch (e) {
      _showError('Error adding category: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _categoryDescController.dispose();
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
          'add_category'.tr(),
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
                    key: _categoryFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Name
                        TextFormField(
                          controller: _categoryNameController,
                          decoration: InputDecoration(
                            labelText: 'category_name'.tr(),
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
                                  BorderSide(color: Colors.blue, width: 2),
                            ),
                          ),
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'please_enter_category_name'.tr();
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Category Description
                        TextFormField(
                          controller: _categoryDescController,
                          decoration: InputDecoration(
                            labelText: 'category_description'.tr(),
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
                                  BorderSide(color: Colors.blue, width: 2),
                            ),
                          ),
                          maxLines: 3,
                          style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87),
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
                                if (_categoryImage == null)
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
                                      _categoryImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                if (_categoryImage != null)
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
                            onPressed: _addCategory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                            ),
                            child: Text(
                              'add_category'.tr(),
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
