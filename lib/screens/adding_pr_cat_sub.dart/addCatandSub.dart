import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/subcateoery_model.dart';
import 'package:graduation_project/services/Product/category_service.dart';

class AddCategorySubCategoryPage extends StatefulWidget {
  const AddCategorySubCategoryPage({super.key});

  @override
  _AddCategorySubCategoryPageState createState() =>
      _AddCategorySubCategoryPageState();
}

class _AddCategorySubCategoryPageState
    extends State<AddCategorySubCategoryPage> {
  final _categoryFormKey = GlobalKey<FormState>();
  final _subCategoryFormKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  final _categoryDescController = TextEditingController();
  final _subCategoryNameController = TextEditingController();
  final _subCategoryDescController = TextEditingController();
  File? _categoryImage;
  File? _subCategoryImage;
  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CategoryService().fetchAllCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }

  Future<void> _pickImage(bool isCategory) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isCategory) {
          _categoryImage = File(pickedFile.path);
        } else {
          _subCategoryImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> _addCategory() async {
    if (_categoryFormKey.currentState!.validate() && _categoryImage != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final dio = Dio(BaseOptions(baseUrl: 'https://10.0.2.2:7273'));
        (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
            (HttpClient client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };

        final formData = FormData.fromMap({
          'Name': _categoryNameController.text,
          'Description': _categoryDescController.text,
          'Image': await MultipartFile.fromFile(_categoryImage!.path,
              filename: _categoryImage!.path.split('/').last),
        });

        final response = await dio.post('/api/Categories', data: formData);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category added successfully')),
          );
          _categoryNameController.clear();
          _categoryDescController.clear();
          setState(() {
            _categoryImage = null;
          });
          await _loadCategories(); // Refresh categories for dropdown
        } else {
          throw Exception('Failed to add category');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding category: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else if (_categoryImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
    }
  }

  Future<void> _addSubCategory() async {
    if (_subCategoryFormKey.currentState!.validate() &&
        _subCategoryImage != null &&
        _selectedCategory != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        final dio = Dio(BaseOptions(baseUrl: 'https://10.0.2.2:7273'));
        (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
            (HttpClient client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };

        final formData = FormData.fromMap({
          'Name': _subCategoryNameController.text,
          'Description': _subCategoryDescController.text,
          'CategoryId': _selectedCategory!.categoryId,
          'Image': await MultipartFile.fromFile(_subCategoryImage!.path,
              filename: _subCategoryImage!.path.split('/').last),
        });

        final response = await dio.post('/api/Subcategories', data: formData);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Subcategory added successfully')),
          );
          _subCategoryNameController.clear();
          _subCategoryDescController.clear();
          setState(() {
            _subCategoryImage = null;
            _selectedCategory = null;
          });
        } else {
          throw Exception('Failed to add subcategory');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding subcategory: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and select a category')),
      );
    }
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    _categoryDescController.dispose();
    _subCategoryNameController.dispose();
    _subCategoryDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
        title: Text(
          'add_category_subcategory'.tr(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Category Section
            Text(
            'add_category'.tr(),
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
      const SizedBox(height: 16),
      Form(
        key: _categoryFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: _categoryNameController,
              decoration: InputDecoration(
                labelText: 'category_name'.tr(),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor:
                isDark ? Colors.grey[900] : Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'please_enter_category_name'.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoryDescController,
              decoration: InputDecoration(
                labelText: 'category_description'.tr(),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor:
                isDark ? Colors.grey[900] : Colors.white,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _pickImage(true),
              child: Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: isDark ? Colors.white : Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: isDark ? Colors.grey[900] : Colors.white,
                ),
                child: _categoryImage == null
                    ? Center(
                  child: Text(
                    'select_image'.tr(),
                    style: TextStyle(
                        color: isDark
                            ? Colors.white
                            : Colors.grey),
                  ),
                )
                    : Image.file(_categoryImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text('add_category'.tr()),
            ),
          ],
        ),
      ),
      const SizedBox(height: 32),
      // Subcategory Section
      Text(
        'add_subcategory'.tr(),
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
        ),
      ),
      const SizedBox(height: 16),
      Form(
          key: _subCategoryFormKey,
          child: Column(
            children: [
            TextFormField(
            controller: _subCategoryNameController,
            decoration: InputDecoration(
              labelText: 'subcategory_name'.tr(),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor:
              isDark ? Colors.grey[900] : Colors.white,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'please_enter_subcategory_name'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _subCategoryDescController,
            decoration: InputDecoration(
              labelText: 'subcategory_description'.tr(),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor:
              isDark ? Colors.grey[900] : Colors.white,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<CategoryModel>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'select_category'.tr(),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor:
              isDark ? Colors.grey[900] : Colors.white,
            ),
            items: _categories.map((category) {
              return DropdownMenuItem<CategoryModel>(
                value: category,
                child: Text(category.name),
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
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _pickImage(false),
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                    color: isDark ? Colors.white : Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: isDark ? Colors.grey[900] : Colors.white,
              ),
              child: _subCategoryImage == null
                  ? Center(
                child: Text(
                  'select_image'.tr(),
                  style: TextStyle(
                      color: isDark
                          ? Colors.white
                          : Colors.grey),
                ),
              )
                  : Image.file(
                _subCategoryImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
              onPressed: _addSubCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child :Text('add_subcategory'.tr()),
    ),
    ],
    ),
    ),
    ],
    ),
    ),
    );
  }
}