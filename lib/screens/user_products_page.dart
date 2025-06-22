import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/components/productc/product.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/screens/pr_cat_sub.dart/add_product.dart';
import 'package:graduation_project/services/Product/product_service.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/screens/Auth/login_page.dart';
import 'package:graduation_project/routes.dart';

class UserProductsPage extends StatefulWidget {
  const UserProductsPage({super.key});

  @override
  State<UserProductsPage> createState() => _UserProductsPageState();
}

class _UserProductsPageState extends State<UserProductsPage> {
  List<ProductModel> userProducts = [];
  bool isLoading = true;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUserProducts();
  }

  Future<void> _loadUserProducts() async {
    try {
      final userId = await UserServicee().getUserId();
      print('Current User ID: $userId (Type: ${userId.runtimeType})');
      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please log in to view your products'.tr())),
          );
        }
        return;
      }

      final allProducts = await ProductService().fetchAllProducts();
      print('All Products Count: ${allProducts.length}');
      print(
          'All Products User IDs: ${allProducts.map((p) => p.userId).toSet()}');

      if (mounted) {
        final filteredProducts = allProducts.where((product) {
          final productUserId = product.userId?.toString();
          final currentUserId = userId.toString();
          print(
              'Comparing: product.userId=$productUserId, currentUserId=$currentUserId');
          return productUserId == currentUserId;
        }).toList();

        print('Filtered Products Count: ${filteredProducts.length}');
        if (filteredProducts.isNotEmpty) {
          print(
              'Filtered Products: ${filteredProducts.map((p) => p.productId).toList()}');
        }

        setState(() {
          userProducts = filteredProducts;
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading products: $e\n$stackTrace');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products: $e'.tr())),
        );
      }
    }
  }

  Future<void> _deleteProduct(ProductModel product) async {
    final shouldDelete = await _showDeleteConfirmationDialog(product);
    if (!shouldDelete) return;

    try {
      setState(() {
        isLoading = true;
      });
      final success = await ProductService().deleteProduct(product.productId);
      if (success) {
        setState(() {
          userProducts.remove(product);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Product deleted successfully'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete product'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting product: $e'.tr()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<bool> _showDeleteConfirmationDialog(ProductModel product) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Delete Product'.tr()),
            content: Text(
                'Are you sure you want to delete "${product.name}"? This action cannot be undone.'
                    .tr()),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[900]
                : Colors.white,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel'.tr(),
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Delete'.tr()),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _editProduct(ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(product: product),
      ),
    ).then((_) => _loadUserProducts());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Products'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 2,
        shadowColor: isDark ? Colors.black26 : Colors.grey[300],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            tooltip: 'Logout'.tr(),
            color: isDark ? Colors.white : Colors.black87,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          ).then((_) => _loadUserProducts());
        },
        backgroundColor: pkColor,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
                strokeWidth: 3,
              ),
            )
          : userProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 80,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No products found'.tr(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddProductScreen(),
                            ),
                          ).then((_) => _loadUserProducts());
                        },
                        icon: const Icon(Icons.add, size: 24),
                        label: Text(
                          'Add Your First Product'.tr(),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadUserProducts,
                  color: Theme.of(context).primaryColor,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: userProducts.length,
                    itemBuilder: (context, index) {
                      final product = userProducts[index];
                      return ProductCard(
                        product: product,
                        isOwner: true,
                        onDelete: () => _deleteProduct(product),
                        onEdit: () => _editProduct(product),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.productPage,
                            arguments: ProductPageArguments(product: product),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}
