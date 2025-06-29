import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:graduation_project/Models/category_model.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/Models/subcateoery_model.dart';

import 'package:graduation_project/components/category/Category_view.dart';
import 'package:graduation_project/components/category/subcategory.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/product_page.dart';
import 'package:graduation_project/services/Product/category_service.dart';
import 'package:graduation_project/services/Product/product_service.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:graduation_project/services/Product/subcategory_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key, this.id});
  final int? id;

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen>
    with SingleTickerProviderStateMixin {
  int? selectedCategoryId;
  int? selectedSubCategoryId;
  List<CategoryModel> categories = [];
  List<SubCategory> subcategories = [];
  List<ProductModel> products = [];
  bool isLoading = true;
  bool isOffline = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _initApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      if (!mounted) return;
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
        if (!mounted) return;
        subcategories = dummySubCategories;
        isLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      if (isOffline) {
        if (mounted) {
          setState(() {
            products = dummyProducts;
            isLoading = false;
          });
        }
      } else {
        final result = await Future.any([
          ProductService().fetchAllProducts(),
          Future.delayed(const Duration(seconds: 15),
              () => throw TimeoutException('Timeout')),
        ]);
        if (mounted) {
          setState(() {
            products = result;
            isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          products = dummyProducts;
          isLoading = false;
        });
      }
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
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        title: Text(
          "Categories",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          "Categories".tr(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 170,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final isSelected = categories[index].categoryId ==
                                  selectedCategoryId;
                              return Padding(
                                padding: EdgeInsets.only(
                                  left: index == 0 ? 0 : 12,
                                  right: index == categories.length - 1 ? 0 : 0,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  transform: Matrix4.identity()
                                    ..scale(isSelected ? 1.05 : 1.0),
                                  child: CategoryView(
                                    borderColor: isSelected
                                        ? Theme.of(context).primaryColor
                                        : isDark
                                            ? Colors.white24
                                            : Colors.black12,
                                    category: categories[index],
                                    onTap: () {
                                      setState(() {
                                        selectedCategoryId =
                                            categories[index].categoryId;
                                        selectedSubCategoryId = null;
                                        _animationController.reset();
                                        _animationController.forward();
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (filteredSubCategories.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Subcategories".tr(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                              Text(
                                "${filteredSubCategories.length} " "Items".tr(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      isDark ? Colors.white38 : Colors.black45,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SizedBox(
                              height: 170,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: filteredSubCategories.length,
                                itemBuilder: (context, index) {
                                  final isSelected =
                                      filteredSubCategories[index]
                                              .subCategoryId ==
                                          selectedSubCategoryId;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      left: index == 0 ? 0 : 12,
                                      right: index ==
                                              filteredSubCategories.length - 1
                                          ? 0
                                          : 0,
                                    ),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      transform: Matrix4.identity()
                                        ..scale(isSelected ? 1.05 : 1.0),
                                      child: SubCategoryView(
                                        borderColor: isSelected
                                            ? Theme.of(context).primaryColor
                                            : isDark
                                                ? Colors.white24
                                                : Colors.black,
                                        subCategory:
                                            filteredSubCategories[index],
                                        onTap: () {
                                          setState(() {
                                            selectedSubCategoryId =
                                                filteredSubCategories[index]
                                                    .subCategoryId;
                                            _animationController.reset();
                                            _animationController.forward();
                                          });
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                if (selectedSubCategoryId != null)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= filteredProducts.length) return null;
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: CustomProductTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductPage(
                                      product: filteredProducts[index],
                                    ),
                                  ),
                                );
                              },
                              product: filteredProducts[index],
                            ),
                          );
                        },
                        childCount: filteredProducts.length,
                      ),
                    ),
                  )
                else
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 64,
                            color: isDark ? Colors.white24 : Colors.black12,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedCategoryId == null
                                ? "Select a Category".tr()
                                : "Choose a Subcategory".tr(),
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark ? Colors.white54 : Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 24),
                ),
              ],
            ),
    );
  }
}

class CustomProductTile extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const CustomProductTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  _CustomProductTileState createState() => _CustomProductTileState();
}

class _CustomProductTileState extends State<CustomProductTile> {
  bool isHovered = false;
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black54 : Colors.grey.withOpacity(0.3),
                blurRadius: isHovered ? 12 : 8,
                offset: isHovered ? const Offset(0, 4) : const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedScale(
                        scale: isHovered ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Image.network(
                          widget.product.images[0].toString(),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      // Favorite Button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isFavorite = !isFavorite;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black54 : Colors.white70,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite
                                  ? Colors.redAccent
                                  : isDark
                                      ? Colors.white70
                                      : Colors.black54,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Product Details
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.product.price.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff003F5C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      decoration: BoxDecoration(
                          color: pkColor,
                          borderRadius: BorderRadius.circular(12)),
                      width: 40,
                      height: 30,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                              color: pkColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            widget.product.isNew == true
                                ? 'New'.tr()
                                : 'Used'.tr(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
