import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/subcateoery_model.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/components/category/Category_view.dart';
import 'package:graduation_project/components/productc/product.dart';
import 'package:graduation_project/components/category/subcategory.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/product_page.dart';
import 'package:graduation_project/services/Product/category_service.dart';
import 'package:graduation_project/services/Product/product_service.dart';

import 'package:graduation_project/services/Server/server_status_service.dart';

import '../services/Product/subcategory_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, this.id});
  final int? id;

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int? selectedCategoryId;
  int? selectedSubCategoryId;
  List<CategoryModel> categories = [];
  List<SubCategory> subcategories = [];
  List<ProductModel> products = [];
  bool isLoading = true;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _checkOfflineStatus();
    await _loadCategories();
    await _loadSubCategories();
    await _loadProducts();
  }

  Future<void> _checkOfflineStatus() async {
    final serverStatusService = ServerStatusService();
    final online = await serverStatusService.checkAndUpdateServerStatus();
    setState(() {
      isOffline = !online;
    });
  }

  Future<void> _loadCategories() async {
    try {
      if (isOffline) {
        setState(() {
          categories = dummyCategories;
          isLoading = false;
        });
      } else {
        final result = await Future.any([
          CategoryService().fetchAllCategories(),
          Future.delayed(const Duration(seconds: 15),
                  () => throw TimeoutException('Timeout')),
        ]);
        setState(() {
          categories = result;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        categories = dummyCategories;
        isLoading = false;
      });
    }
  }

  Future<void> _loadSubCategories() async {
    try {
      if (isOffline) {
        setState(() {
          subcategories = dummySubCategories;
          isLoading = false;
        });
      } else {
        final result = await Future.any([
          SubCategoryService().fetchAllSubCategories(),
          Future.delayed(const Duration(seconds: 15),
                  () => throw TimeoutException('Timeout')),
        ]);
        setState(() {
          subcategories = result;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        subcategories = dummySubCategories;
        isLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      if (isOffline) {
        setState(() {
          products = dummyProducts;
          isLoading = false;
        });
      } else {
        final result = await Future.any([
          ProductService().fetchAllProducts(),
          Future.delayed(const Duration(seconds: 15),
                  () => throw TimeoutException('Timeout')),
        ]);
        setState(() {
          products = result;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        products = dummyProducts;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List<SubCategory> filteredSubCategories = selectedCategoryId == null
        ? []
        : subcategories
        .where((sub) => sub.categoryId == selectedCategoryId)
        .toList();

    List<ProductModel> filteredProducts = selectedSubCategoryId == null
        ? []
        : products
        .where((prod) => prod.subCategoryId == selectedSubCategoryId)
        .toList();

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF5F5F5),
        title: Text(
          "categories".tr(),
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 170,
              width: double.infinity,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  return CategoryView(
                    borderColor:
                    categories[index].categoryId == selectedCategoryId
                        ? Colors.blue
                        : isDark
                        ? Colors.white
                        : Colors.black,
                    category: categories[index],
                    onTap: () {
                      setState(() {
                        selectedCategoryId = categories[index].categoryId;
                        selectedSubCategoryId = null;
                      });
                    },
                  );
                },
              ),
            ),
            Divider(
                color: isDark ? Colors.white : Colors.grey,
                thickness: 0.5),
            Center(
              child: Text(
                "subcategories".tr(),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
              ),
            ),
            const SizedBox(height: 10),
            if (filteredSubCategories.isNotEmpty)
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredSubCategories.length,
                  itemBuilder: (context, index) {
                    return SubCategoryView(
                      borderColor:
                      filteredSubCategories[index].subCategoryId ==
                          selectedSubCategoryId
                          ? Colors.blue
                          : isDark
                          ? Colors.white
                          : Colors.black,
                      subCategory: filteredSubCategories[index],
                      onTap: () {
                        setState(() {
                          selectedSubCategoryId =
                              filteredSubCategories[index].subCategoryId;
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              height: 520,
              child: filteredProducts.isNotEmpty
                  ? GridView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ProductPage(
                              product: filteredProducts[index],
                            );
                          },
                        ),
                      );
                    },
                    product: filteredProducts[index],
                  );
                },
              )
                  : selectedSubCategoryId == null
                  ? Center(
                child: Text(
                  "choose_subcategory".tr(),
                  style: const TextStyle(
                      color: Colors.blue, fontSize: 24),
                ),
              )
                  : Center(child: Text("no_products".tr())),
            ),
          ],
        ),
      ),
    );
  }
}