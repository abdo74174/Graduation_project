import 'package:flutter/material.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/components/productc/product.dart';
import 'package:graduation_project/screens/pr_cat_sub.dart/add_product.dart';
import 'package:graduation_project/services/Product/product_service.dart';
import 'package:graduation_project/services/SharedPreferences/EmailRef.dart';
import 'package:easy_localization/easy_localization.dart';
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

      if (userId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please log in to view your products'.tr())),
          );
        }
        return;
      }

      final allProducts = await ProductService().fetchAllProducts();

      if (mounted) {
        final filteredProducts =
            allProducts.where((product) => product.userId == userId).toList();

        // Debug product IDs
        for (var product in allProducts) {}

        setState(() {
          userProducts = filteredProducts;
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading products'.tr())),
        );
      }
    }
  }

  Future<void> _deleteProduct(ProductModel product) async {
    try {
      final success = await ProductService().deleteProduct(product.productId);
      if (success) {
        setState(() {
          userProducts.remove(product);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Product deleted successfully'.tr())),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete product'.tr())),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting product: $e'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use hardcoded text values for now to fix the immediate error
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text('My Products'.tr()),
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          ).then((_) => _loadUserProducts()); // Reload products after adding
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No products found'.tr(),
                        style: TextStyle(
                          fontSize: 18,
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
                        icon: const Icon(Icons.add),
                        label: Text('Add Product'.tr()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: userProducts.length,
                  itemBuilder: (context, index) {
                    final product = userProducts[index];
                    return ProductCard(
                      product: product,
                      isOwner: true,
                      onDelete: () => _deleteProduct(product),
                      onTap: () {
                        // Navigate to product detail page
                        Navigator.pushNamed(
                          context,
                          AppRoutes.productPage,
                          arguments: ProductPageArguments(product: product),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
