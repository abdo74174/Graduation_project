import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graduation_project/screens/pr_cat_sub.dart/add_subcategory_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:graduation_project/services/Product/subcategory_service.dart';
import 'package:graduation_project/Models/subcateoery_model.dart';

class ManageSubCategoriesPage extends StatefulWidget {
  const ManageSubCategoriesPage({super.key});

  @override
  State<ManageSubCategoriesPage> createState() =>
      _ManageSubCategoriesPageState();
}

class _ManageSubCategoriesPageState extends State<ManageSubCategoriesPage> {
  final SubCategoryService _subCategoryService = SubCategoryService();
  late Future<List<SubCategory>> _subCategoriesFuture;
  List<SubCategory> _allSubCategories = [];
  String _searchQuery = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _subCategoriesFuture = _loadSubCategories();
  }

  Future<List<SubCategory>> _loadSubCategories() async {
    try {
      setState(() => _isLoading = true);

      final subcategories = await _subCategoryService.fetchAllSubCategories();

      setState(() {
        _allSubCategories = subcategories;
        _isLoading = false;
      });

      return subcategories;
    } catch (error) {
      setState(() => _isLoading = false);

      if (mounted) {
        _showErrorSnackBar('Failed to load subcategories: $error');
      }

      rethrow;
    }
  }

  Future<void> _deleteSubCategory(
      int subCategoryId, String subcategoryName) async {
    try {
      final shouldDelete = await _showDeleteConfirmation(subcategoryName);
      if (!shouldDelete) return;

      setState(() => _isLoading = true);

      await _subCategoryService.deleteSubCategory(subCategoryId);

      _subCategoriesFuture = _loadSubCategories();

      if (mounted) {
        _showSuccessSnackBar('Subcategory deleted successfully');
      }
    } catch (error) {
      setState(() => _isLoading = false);

      if (mounted) {
        String errorMessage = _getErrorMessage(error);
        _showErrorSnackBar(errorMessage);
      }
    }
  }

  Future<void> _editSubCategory(SubCategory subcategory) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditSubCategoryPage(subcategory: subcategory),
      ),
    );

    if (result == true) {
      // Refresh the list if editing was successful
      setState(() {
        _subCategoriesFuture = _loadSubCategories();
      });
    }
  }

  String _getErrorMessage(dynamic error) {
    String errorString = error.toString();

    if (errorString.contains('400')) {
      return 'Cannot delete this subcategory because it has associated products. Please remove all products first.';
    }

    if (errorString.contains('404')) {
      return 'Subcategory not found. It may have already been deleted.';
    }

    if (errorString.contains('403')) {
      return 'You don\'t have permission to delete this subcategory.';
    }

    if (errorString.contains('500')) {
      return 'Server error occurred. Please try again later.';
    }

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }

    return 'Cant delete sub because have product ';
  }

  List<SubCategory> _getFilteredSubCategories() {
    if (_searchQuery.isEmpty) {
      return _allSubCategories;
    }

    return _allSubCategories.where((subcategory) {
      final name = subcategory.name?.toLowerCase() ?? '';
      final description = subcategory.description?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return name.contains(query) || description.contains(query);
    }).toList();
  }

  Future<bool> _showDeleteConfirmation(String subcategoryName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 28),
                const SizedBox(width: 12),
                const Text('Confirm Deletion'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to delete "$subcategoryName"?'),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.orange, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'This action cannot be undone.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Subcategories with products cannot be deleted. Please remove all associated products first.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Manage SubCategories',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSubCategory,
            tooltip: 'Add new Sub category',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchSection(),
          Expanded(child: _buildSubCategoriesList()),
        ],
      ),
    );
  }

  Future<void> _addSubCategory() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddSubCategoryPage(),
      ),
    );

    // if (result == true) {
    //   setState(() {
    //     _categoriesFuture = _loadCategories();
    //   });
    // }
  }

  Widget _buildSearchSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search subcategories...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildSubCategoriesList() {
    return FutureBuilder<List<SubCategory>>(
      future: _subCategoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading subcategories...',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final filteredSubCategories = _getFilteredSubCategories();

        if (filteredSubCategories.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filteredSubCategories.length,
          itemBuilder: (context, index) {
            final subcategory = filteredSubCategories[index];
            return _buildSubCategoryCard(subcategory);
          },
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          const Text(
            'Error loading subcategories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () =>
                setState(() => _subCategoriesFuture = _loadSubCategories()),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.category_outlined : Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No subcategories found'
                : 'No subcategories match your search',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Add some subcategories to get started'
                : 'Try a different search term',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryCard(SubCategory subcategory) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: subcategory.image?.isNotEmpty == true
                  ? Image.network(
                      subcategory.image!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subcategory.name ?? 'Unnamed Subcategory',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (subcategory.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      subcategory.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ID: ${subcategory.subCategoryId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Actions
            Column(
              children: [
                IconButton(
                  onPressed:
                      _isLoading ? null : () => _editSubCategory(subcategory),
                  icon: const Icon(Icons.edit_outlined),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    foregroundColor: Colors.blue,
                  ),
                  tooltip: 'Edit subcategory',
                ),
                const SizedBox(height: 8),
                IconButton(
                  onPressed: _isLoading
                      ? null
                      : () => _deleteSubCategory(subcategory.subCategoryId,
                          subcategory.name ?? 'Unknown'),
                  icon: const Icon(Icons.delete_outline),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                  ),
                  tooltip: 'Delete subcategory',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.image_outlined,
        color: Colors.grey[400],
        size: 32,
      ),
    );
  }
}

// Edit SubCategory Page
class EditSubCategoryPage extends StatefulWidget {
  final SubCategory subcategory;

  const EditSubCategoryPage({super.key, required this.subcategory});

  @override
  State<EditSubCategoryPage> createState() => _EditSubCategoryPageState();
}

class _EditSubCategoryPageState extends State<EditSubCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final SubCategoryService _subCategoryService = SubCategoryService();
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.subcategory.name ?? '';
    _descriptionController.text = widget.subcategory.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _updateSubCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _subCategoryService.updateSubCategory(
        id: widget.subcategory.subCategoryId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: widget.subcategory.categoryId,
        imageFile: _selectedImage,
      );

      if (mounted) {
        _showSuccessSnackBar('Subcategory updated successfully');
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (error) {
      if (mounted) {
        _showErrorSnackBar('Failed to update subcategory: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Subcategory',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildImageSection(),
            const SizedBox(height: 24),
            _buildNameField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 32),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Subcategory Image',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!, width: 2),
                color: Colors.grey[50],
              ),
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        _selectedImage!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : widget.subcategory.image?.isNotEmpty == true
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            widget.subcategory.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildImagePlaceholder(),
                          ),
                        )
                      : _buildImagePlaceholder(),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Tap to change image',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 32, color: Colors.grey[400]),
        const SizedBox(height: 8),
        Text(
          'Add Image',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Subcategory Name',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.category_outlined),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a subcategory name';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _descriptionController,
        decoration: const InputDecoration(
          labelText: 'Description',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.description_outlined),
        ),
        maxLines: 3,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter a description';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateSubCategory,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Updating...'),
                ],
              )
            : const Text(
                'Update Subcategory',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
