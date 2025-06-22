import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/subcateoery_model.dart';
import 'package:graduation_project/Models/user_model.dart';
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
import 'package:graduation_project/Models/product_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';

class AddProductScreen extends StatefulWidget {
  final ProductModel? product;

  const AddProductScreen({super.key, this.product});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _comparePriceController = TextEditingController();
  final TextEditingController _stockQuantity = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _guaranteeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final List<File> _imageFiles = [];
  final List<String> _existingImageUrls = [];
  final ImagePicker _picker = ImagePicker();
  String? selectedStatus;
  String? selectedCategory;
  String? selectedSubCategory;
  String? userId;
  String? userAddress;
  bool isDonation = false;
  bool _isReturnAgreementAccepted = false;
  bool _installmentAvailable = false;

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
        return;
      }

      // Fetch user data
      if (userId != null) {
        final user = await fetchUserById(int.parse(userId!));
        if (user != null && mounted) {
          setState(() {
            userAddress = user.address;
            if (widget.product == null) {
              _addressController.text = userAddress ?? "";
            }
          });
        }
      }

      // Fetch categories
      final fetchedCategories = await CategoryService().fetchAllCategories();
      print('Fetched Categories: ${fetchedCategories.map((c) => {
            'id': c.categoryId,
            'name': c.name
          }).toList()}');
      if (mounted) {
        setState(() {
          _categories = fetchedCategories;
          productCategories =
              fetchedCategories.map((cat) => cat.name).toSet().toList();
        });

        // Initialize fields for editing
        if (widget.product != null) {
          setState(() {
            _productNameController.text = widget.product!.name;
            _descriptionController.text = widget.product!.description;
            _priceController.text = widget.product!.price.toStringAsFixed(2);
            _comparePriceController.text =
                widget.product!.price.toStringAsFixed(2);
            _discountController.text = widget.product!.discount.toString();
            _guaranteeController.text = widget.product!.guarantee.toString();
            _stockQuantity.text = widget.product!.StockQuantity.toString();
            _addressController.text = widget.product!.address;
            isDonation = widget.product!.donation;
            selectedStatus = widget.product!.isNew ? "New" : "Used";
            _isReturnAgreementAccepted = !widget.product!.isNew;
            _installmentAvailable = widget.product!.installmentAvailable;
            _existingImageUrls.addAll(widget.product!.images);

            // Set category
            final category = _categories.firstWhere(
              (c) => c.categoryId == widget.product!.categoryId,
              orElse: () => CategoryModel(
                  categoryId: 0,
                  name: 'Unknown',
                  description: '',
                  subCategories: [],
                  products: []),
            );
            if (category.categoryId != 0) {
              selectedCategory = category.name;
            }
          });

          // Load subcategories for the selected category and set subcategory
          if (selectedCategory != null) {
            await _updateSubcategories(selectedCategory);
            if (mounted && _subcategories.isNotEmpty) {
              setState(() {
                final subCategory = _subcategories.firstWhere(
                  (s) => s.subCategoryId == widget.product!.subCategoryId,
                  orElse: () => SubCategory(
                      subCategoryId: 0,
                      name: 'Unknown',
                      categoryId: 0,
                      description: '',
                      image: '',
                      products: []),
                );
                if (subCategory.subCategoryId != 0) {
                  selectedSubCategory = subCategory.name;
                }
              });
            }
          }
        } else {
          // Initialize pricing fields for new products
          setState(() {
            _priceController.text = "0.00";
            _comparePriceController.text = "0.00";
            _discountController.text = "0";
            _guaranteeController.text = "0.0";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context, "Error loading initial data: $e".tr());
        print('Error in _loadInitialData: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<UserModel?> fetchUserById(int userId) async {
    try {
      final url = 'https://10.0.2.2:7273/api/User/$userId';
      print('Fetching from: $url');
      final dio = Dio();
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        print('User data: ${response.data}');
        return UserModel.fromJson(response.data);
      } else {
        print('Failed to fetch user. Status code: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print(
          'DioException: ${e.message}, Response: ${e.response}, Type: ${e.type}');
      return null;
    } catch (e) {
      print('Unexpected error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _comparePriceController.dispose();
    _stockQuantity.dispose();
    _discountController.dispose();
    _descriptionController.dispose();
    _guaranteeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          isEditing ? "Edit Product".tr() : "Add New Product".tr(),
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
          ? Center(child: CircularProgressIndicator(color: pkColor))
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
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Product name is required".tr();
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildDonationToggle(),
                              const SizedBox(height: 16),
                              _buildStatusSelector(),
                              const SizedBox(height: 16),
                              BuildDropdown(
                                label: "Product Category",
                                options: productCategories,
                                selectedValue: selectedCategory,
                                onChanged: (value) {
                                  _updateSubcategories(value);
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return "Please select a category".tr();
                                  }
                                  return null;
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
                                    (!_isLoading && selectedCategory != null),
                                hint: _isLoading
                                    ? "Loading subcategories...".tr()
                                    : selectedCategory == null
                                        ? "Select a category first".tr()
                                        : productSubCategories.isEmpty
                                            ? "No subcategories available".tr()
                                            : "Select a subcategory".tr(),
                                validator: (value) {
                                  if (selectedCategory != null &&
                                      productSubCategories.isNotEmpty &&
                                      value == null) {
                                    return "Please select a subcategory".tr();
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              BuildTextField(
                                controller: _stockQuantity,
                                label: "Product Quantity".tr(),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter a quantity".tr();
                                  }
                                  if (int.tryParse(value) == null) {
                                    return "Please enter a valid quantity".tr();
                                  }
                                  return null;
                                },
                              ),
                              if (!isDonation) ...[
                                const SizedBox(height: 16),
                                BuildTextField(
                                  controller: _guaranteeController,
                                  label: "Guarantee (months)".tr(),
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter a guarantee period"
                                          .tr();
                                    }
                                    if (double.tryParse(value) == null) {
                                      return "Please enter a valid guarantee period"
                                          .tr();
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              if (userAddress == null ||
                                  userAddress!.isEmpty) ...[
                                const SizedBox(height: 16),
                                BuildTextField(
                                  controller: _addressController,
                                  label: "Product Address".tr(),
                                  keyboardType: TextInputType.streetAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter a valid address"
                                          .tr();
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              const SizedBox(height: 16),
                              CheckboxListTile(
                                title: Text("Installment Available".tr()),
                                value: _installmentAvailable,
                                onChanged: (value) {
                                  setState(() {
                                    _installmentAvailable = value ?? false;
                                  });
                                },
                                activeColor:pkColor,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Description is required".tr();
                                }
                                return null;
                              },
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
                                backgroundColor:pkColor,
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
                              (_imageFiles.isEmpty &&
                                      _existingImageUrls.isEmpty)
                                  ? "Please add at least one product image".tr()
                                  : "${_imageFiles.length + _existingImageUrls.length} image${(_imageFiles.length + _existingImageUrls.length) > 1 ? 's' : ''} selected",
                              style: TextStyle(
                                color: (_imageFiles.isEmpty &&
                                        _existingImageUrls.isEmpty)
                                    ? Colors.red
                                    : Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ImageUploadSection(
                              imageFiles: _imageFiles,
                              existingImageUrls: _existingImageUrls,
                              onTap: _pickImages,
                              onRemoveFile: _removeImage,
                              onRemoveUrl: _removeExistingImage,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (!isDonation) ...[
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
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:pkColor,
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
                                  Text(isEditing
                                      ? "Updating Product...".tr()
                                      : "Adding Product...".tr()),
                                ],
                              )
                            : Text(
                                isEditing
                                    ? "Update Product".tr()
                                    : "Add Product".tr(),
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
              color: pkColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: pkColor
              ,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationToggle() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Donate this product".tr(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: pkColor,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            setState(() {
              isDonation = !isDonation;
              if (isDonation) {
                _priceController.text = "0.00";
                _comparePriceController.text = "0.00";
                _discountController.text = "0";
                _guaranteeController.text = "0.0";
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDonation ? pkColor

                    : Colors.grey[300]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isDonation ? theme.primaryColor.withOpacity(0.1) : null,
            ),
            child: Row(
              children: [
                Icon(
                  isDonation
                      ? Icons.volunteer_activism
                      : Icons.volunteer_activism_outlined,
                  color: isDonation ? pkColor : Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDonation
                            ? "Donation Enabled".tr()
                            : "Enable Donation".tr(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDonation
                              ?pkColor
                              : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Offer this product for free to support a cause.".tr(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isDonation ? Icons.check_circle : Icons.circle_outlined,
                  color: isDonation ? pkColor : Colors.grey[600],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
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
          if (status == "Used".tr()) {
            _isReturnAgreementAccepted = false;
            _showReturnAgreementBottomSheet();
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? pkColor : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? pkColor.withOpacity(0.1) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? pkColor: Colors.grey[600],
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: TextStyle(
                color: isSelected ? pkColor : Colors.grey[800],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReturnAgreementBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Return Agreement for Used Products".tr(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: pkColor
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "By listing a used product, you agree to accept returns if the product does not function as described."
                        .tr(),
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _isReturnAgreementAccepted,
                        onChanged: (bool? value) {
                          setModalState(() {
                            _isReturnAgreementAccepted = value ?? false;
                          });
                          setState(() {
                            _isReturnAgreementAccepted = value ?? false;
                          });
                        },
                        activeColor: pkColor,
                      ),
                      Expanded(
                        child: Text(
                          "I agree to the return policy for used products".tr(),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isReturnAgreementAccepted
                          ? () => Navigator.pop(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pkColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text("Confirm".tr()),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!isDonation && _discountController.text.isEmpty) {
        showSnackbar(context, "Please enter a discount percentage".tr());
        return;
      } else if (!isDonation &&
          double.tryParse(_discountController.text) == null) {
        showSnackbar(context, "Please enter a valid discount percentage".tr());
        return;
      } else if (!isDonation &&
          double.tryParse(_discountController.text)! > 100) {
        showSnackbar(
            context, "Discount percentage cannot be greater than 100".tr());
        return;
      }

      if (selectedStatus == "Used".tr() && !_isReturnAgreementAccepted) {
        showSnackbar(context,
            "Please accept the return agreement for used products".tr());
        return;
      }

      if (_imageFiles.isEmpty && _existingImageUrls.isEmpty) {
        showSnackbar(context, "Please add at least one product image".tr());
        return;
      }

      final categoryId = getCategoryIdByName(selectedCategory);
      if (categoryId == null || categoryId == 0) {
        showSnackbar(context, "Invalid category selected".tr());
        return;
      }

      if (productSubCategories.isNotEmpty) {
        final subCategoryId = getSubCategoryIdByName(selectedSubCategory);
        if (subCategoryId == null || subCategoryId == 0) {
          showSnackbar(context, "Invalid subcategory selected".tr());
          return;
        }
      }

      if (widget.product != null) {
        await _updateProduct();
      } else {
        await _submitProduct();
      }
    }
  }

  Future<void> _submitProduct() async {
    if (selectedStatus == null) {
      showSnackbar(context, "Please select product status (New or Used)".tr());
      return;
    }

    if (userId == null) {
      showSnackbar(context, "Please login to add a product".tr());
      return;
    }

    final String productAddress = (userAddress == null || userAddress!.isEmpty)
        ? _addressController.text
        : userAddress!;

    if (productAddress.isEmpty) {
      showSnackbar(context, "User address is required".tr());
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ProductService().addProduct(
        userId: userId!,
        name: _productNameController.text,
        description: _descriptionController.text,
        address: productAddress,
        donation: isDonation,
        price: isDonation ? 0.0 : double.tryParse(_priceController.text) ?? 0.0,
        comparePrice: isDonation
            ? 0.0
            : double.tryParse(_comparePriceController.text) ?? 0.0,
        discount:
            isDonation ? 0.0 : double.tryParse(_discountController.text) ?? 0.0,
        status: selectedStatus!,
        guarantee: isDonation
            ? 0.0
            : double.tryParse(_guaranteeController.text) ?? 0.0,
        stockQuantity: int.tryParse(_stockQuantity.text) ?? 1,
        categoryId: getCategoryIdByName(selectedCategory) ?? 0,
        subCategoryId: getSubCategoryIdByName(selectedSubCategory) ?? 0,
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

  Future<void> _updateProduct() async {
    if (selectedStatus == null) {
      showSnackbar(context, "Please select product status (New or Used)".tr());
      return;
    }

    if (userId == null) {
      showSnackbar(context, "Please login to update a product".tr());
      return;
    }

    final String productAddress = (userAddress == null || userAddress!.isEmpty)
        ? _addressController.text
        : userAddress!;

    if (productAddress.isEmpty) {
      showSnackbar(context, "User address is required".tr());
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ProductService().updateProduct(
        productId: widget.product!.productId,
        userId: userId!,
        name: _productNameController.text,
        description: _descriptionController.text,
        address: productAddress,
        donation: isDonation,
        price: isDonation ? 0.0 : double.tryParse(_priceController.text) ?? 0.0,
        discount:
            isDonation ? 0.0 : double.tryParse(_discountController.text) ?? 0.0,
        guarantee: isDonation
            ? 0.0
            : double.tryParse(_guaranteeController.text) ?? 0.0,
        categoryId: getCategoryIdByName(selectedCategory) ?? 0,
        subCategoryId: getSubCategoryIdByName(selectedSubCategory) ?? 0,
        isNew: selectedStatus == "New".tr(),
        installmentAvailable: _installmentAvailable,
        imageFiles: _imageFiles.isNotEmpty ? _imageFiles : null,
      );

      showSnackbar(context, "Product updated successfully!".tr());
      Navigator.pop(context);
    } catch (e) {
      showSnackbar(context, "Error updating product: $e".tr());
      if (kDebugMode) {
        print("Error updating product: $e".tr());
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  int? getCategoryIdByName(String? name) {
    if (name == null || _categories.isEmpty) return null;
    try {
      final category = _categories.firstWhere(
        (c) => c.name == name,
        orElse: () {
          print('Category not found: $name');
          return CategoryModel(
              categoryId: 0,
              name: 'Unknown',
              description: '',
              subCategories: [],
              products: []);
        },
      );
      return category.categoryId != 0 ? category.categoryId : null;
    } catch (e) {
      print('Error finding category $name: $e');
      return null;
    }
  }

  int? getSubCategoryIdByName(String? name) {
    if (name == null ||
        productSubCategories.isEmpty ||
        selectedCategory == null) return null;
    try {
      final subCategory = _subcategories.firstWhere(
        (s) =>
            s.name == name &&
            s.categoryId == getCategoryIdByName(selectedCategory),
        orElse: () {
          print('Subcategory not found: $name in category $selectedCategory');
          return SubCategory(
              subCategoryId: 0,
              name: 'Unknown',
              categoryId: 0,
              description: '',
              image: '',
              products: []);
        },
      );
      print(
          'Found subcategory: ${subCategory.name} (ID: ${subCategory.subCategoryId})');
      return subCategory.subCategoryId != 0 ? subCategory.subCategoryId : null;
    } catch (e) {
      print('Error finding subcategory $name: $e');
      return null;
    }
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

  void _removeExistingImage(String url) {
    setState(() {
      _existingImageUrls.remove(url);
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

  Future<void> _updateSubcategories(String? categoryName) async {
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
      productSubCategories = [];
      _subcategories = [];
    });

    try {
      final category = _categories.firstWhere(
        (cat) => cat.name == categoryName,
        orElse: () => throw Exception('Category not found: $categoryName'.tr()),
      );

      print(
          '🔍 Loading subcategories for category: ${category.name} (ID: ${category.categoryId})');

      final allSubcategories = await SubCategoryService()
          .fetchSubCategoriesByCategory(category.categoryId);

      final filteredSubcategories = allSubcategories
          .where((subcat) => subcat.categoryId == category.categoryId)
          .toList();

      print(
          '📊 Filtered ${filteredSubcategories.length} subcategories for category ${category.categoryId}');

      if (mounted) {
        setState(() {
          _subcategories = filteredSubcategories;
          productSubCategories = filteredSubcategories
              .map((subcat) => subcat.name)
              .toSet()
              .toList();
          _isLoading = false;
        });

        if (filteredSubcategories.isEmpty) {
          print(
              '⚠️ No subcategories found for category ${category.name} (ID: ${category.categoryId})');
        } else {
          print(
              '✅ Loaded ${filteredSubcategories.length} subcategories for ${category.name}');
          print('📝 Subcategories: ${productSubCategories.join(", ")}');
        }
      }
    } catch (e) {
      print('❌ Error loading subcategories: $e');
      if (mounted) {
        setState(() {
          _subcategories = [];
          productSubCategories = [];
          _isLoading = false;
        });
        showSnackbar(context, 'Failed to load subcategories: $e'.tr());
      }
    }
  }
}

class ImageUploadSection extends StatelessWidget {
  final List<File> imageFiles;
  final List<String> existingImageUrls;
  final VoidCallback onTap;
  final Function(File) onRemoveFile;
  final Function(String) onRemoveUrl;

  const ImageUploadSection({
    super.key,
    required this.imageFiles,
    required this.existingImageUrls,
    required this.onTap,
    required this.onRemoveFile,
    required this.onRemoveUrl,
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
                      color: pkColor.withOpacity(0.5), width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: pkColor.withOpacity(0.05),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 36,
                      color: pkColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Add Images".tr(),
                      style: TextStyle(
                        color: pkColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: (imageFiles.isEmpty && existingImageUrls.isEmpty)
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
                        children: [
                          ...existingImageUrls.asMap().entries.map((entry) =>
                              _buildNetworkImageItem(
                                  context, entry.value, entry.key)),
                          ...imageFiles.asMap().entries.map((entry) =>
                              _buildFileImageItem(context, entry.value,
                                  entry.key + existingImageUrls.length)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNetworkImageItem(BuildContext context, String url, int index) {
    final theme = Theme.of(context);

    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: url,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
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
          Positioned(
            right: -5,
            top: -5,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onRemoveUrl(url),
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

  Widget _buildFileImageItem(BuildContext context, File imageFile, int index) {
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
          Positioned(
            right: -5,
            top: -5,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onRemoveFile(imageFile),
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
