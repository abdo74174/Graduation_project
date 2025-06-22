import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/product_page.dart';
import 'package:graduation_project/services/Favourites/favourites_service.dart';
import 'package:graduation_project/services/Product/category_service.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:graduation_project/Models/category_model.dart';

// Define pkColor if not present in constant.dart
// const Color pkColor = Colors.blue;
const String defaultProductImage = 'assets/images/placeholder.png';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavouritePage>
    with TickerProviderStateMixin {
  List<ProductModel> favourites = [];
  List<ProductModel> filteredFavourites = [];
  List<CategoryModel> categories = dummyCategories;
  List<CategoryModel> filteredCategories = [];
  bool isLoading = true;
  bool isRemoving = false;
  bool isSearchExpanded = false;
  bool isSidebarVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _categorySearchController =
      TextEditingController();
  String? selectedCategory;
  String? selectedStatus;
  bool sortAscending = true;
  Timer? _debounce;

  Future<void> _loadCategories() async {
    try {
      final result = await Future.any([
        CategoryService().fetchAllCategories(),
        Future.delayed(const Duration(seconds: 15),
            () => throw TimeoutException('Timeout')),
      ]);
      if (mounted) {
        setState(() {
          categories = result;
          filteredCategories = result;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          categories = dummyCategories;
          filteredCategories = dummyCategories;
          isLoading = false;
        });
      }
    }
  }

  late AnimationController _sidebarController;
  late Animation<double> _sidebarAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    fetchFavourites();
    _loadCategories();
    _searchController.addListener(_filterFavourites);
    _categorySearchController.addListener(_onCategorySearchChanged);

    _sidebarController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sidebarAnimation = Tween<double>(begin: -300, end: 0).animate(
      CurvedAnimation(parent: _sidebarController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 0.5).animate(_fadeController);
  }

  void _onCategorySearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      final query = _categorySearchController.text.trim().toLowerCase();
      setState(() {
        if (query.isEmpty) {
          filteredCategories = categories;
        } else {
          filteredCategories = categories.where((category) {
            return category.name.toLowerCase().contains(query);
          }).toList();
        }
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _categorySearchController.dispose();
    _sidebarController.dispose();
    _fadeController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      isSidebarVisible = !isSidebarVisible;
    });

    if (isSidebarVisible) {
      _sidebarController.forward();
      _fadeController.forward();
    } else {
      _sidebarController.reverse();
      _fadeController.reverse();
      _categorySearchController.clear();
    }
  }

  void _filterFavourites() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredFavourites = favourites.where((product) {
        final matchesSearch = product.name.toLowerCase().contains(query) ||
            product.description.toLowerCase().contains(query);
        final matchesCategory = selectedCategory == null ||
            selectedCategory == 'all' ||
            product.categoryId.toString() == selectedCategory;
        final matchesStatus = selectedStatus == null ||
            selectedStatus == 'all' ||
            (product.isNew != null &&
                (product.isNew! ? 'new' : 'used') == selectedStatus);
        return matchesSearch && matchesCategory && matchesStatus;
      }).toList();
      _sortItems(sortAscending);
    });
  }

  Future<void> fetchFavourites() async {
    setState(() => isLoading = true);

    final serverStatusService = ServerStatusService();
    final isOnline = await serverStatusService.checkAndUpdateServerStatus();

    if (isOnline) {
      try {
        final response = await FavouritesService().getFavourites();
        if (response != null && response.statusCode == 200) {
          final List<ProductModel> loaded = (response.data as List<dynamic>)
              .map((json) => ProductModel.fromJson(
                  json['product'] as Map<String, dynamic>))
              .toList();
          setState(() {
            favourites = loaded;
            filteredFavourites = loaded;
            isLoading = false;
          });
        } else {
          _showToast("Failed to load favourites".tr(), isError: true);
          setState(() {
            favourites = [];
            filteredFavourites = [];
            isLoading = false;
          });
        }
      } catch (e) {
        _showToast("Error loading favourites: $e".tr(), isError: true);
        setState(() {
          favourites = [];
          filteredFavourites = [];
          isLoading = false;
        });
      }
    } else {
      setState(() {
        favourites = dummyProducts;
        filteredFavourites = dummyProducts;
        isLoading = false;
      });
      _showOfflineSnackbar();
    }
  }

  void _showOfflineSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.wifi_off, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('You are offline. Showing dummy favourites.'.tr()),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor:
          isError ? Theme.of(context).colorScheme.error : Colors.green,
      textColor: Colors.white,
    );
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Theme.of(context).colorScheme.error, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title.tr(),
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
            content: Text(message.tr(),
                style: Theme.of(context).textTheme.bodyMedium),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  'Cancel'.tr(),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  'Confirm'.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _removeFavourite(int index) async {
    if (isRemoving || index < 0 || index >= filteredFavourites.length) {
      return;
    }

    setState(() => isRemoving = true);
    final product = filteredFavourites[index];
    final confirmed = await _showConfirmationDialog(
      'Remove Item',
      'Are you sure you want to remove this item from favourites?',
    );

    if (!confirmed) {
      setState(() => isRemoving = false);
      return;
    }

    try {
      final response =
          await FavouritesService().removeFromFavourites(product.productId);
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 204)) {
        setState(() {
          favourites.removeWhere((p) => p.productId == product.productId);
          filteredFavourites
              .removeWhere((p) => p.productId == product.productId);
        });
        _showToast("Removed from favourites".tr());
      } else {
        _showToast("Failed to remove: Invalid response".tr(), isError: true);
      }
    } catch (e) {
      _showToast("Error removing favourite: $e".tr(), isError: true);
    } finally {
      setState(() => isRemoving = false);
    }
  }

  Future<void> _removeAllFavourites() async {
    if (favourites.isEmpty) {
      _showToast("No favourites to remove".tr(), isError: true);
      return;
    }

    final confirmed = await _showConfirmationDialog(
      'Remove All',
      'Are you sure you want to remove all items from favourites?',
    );
    if (!confirmed) return;

    setState(() => isRemoving = true);
    try {
      final response = await FavouritesService().removeALLFromFavourites();
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 204)) {
        setState(() {
          favourites.clear();
          filteredFavourites.clear();
        });
        _showToast("All favourites removed".tr());
      } else {
        _showToast("Failed to remove all favourites".tr(), isError: true);
      }
    } catch (e) {
      _showToast("Error removing all favourites: $e".tr(), isError: true);
    } finally {
      setState(() => isRemoving = false);
    }
  }

  void _sortItems(bool ascending) {
    setState(() {
      sortAscending = ascending;
      filteredFavourites.sort((a, b) =>
          ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price));
    });
  }

  void _clearFilters() {
    setState(() {
      selectedCategory = null;
      selectedStatus = null;
      _searchController.clear();
      _categorySearchController.clear();
      _filterFavourites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(),
              _buildFilterChips(),
              Expanded(
                child: isLoading
                    ? _buildShimmerGrid()
                    : filteredFavourites.isEmpty
                        ? _buildEmptyState()
                        : _buildProductGrid(),
              ),
            ],
          ),
          if (isSidebarVisible)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return GestureDetector(
                  onTap: _toggleSidebar,
                  child: Container(
                    color: Colors.black.withOpacity(_fadeAnimation.value),
                  ),
                );
              },
            ),
          AnimatedBuilder(
            animation: _sidebarAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_sidebarAnimation.value, 0),
                child: _buildSidebar(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: favourites.isNotEmpty ? _buildFAB() : null,
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   colors: [
        //     pkColor,
        //     Theme.of(context).colorScheme.primary.withOpacity(0.8),
        //   ],
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: isSearchExpanded
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: 'Search favourites...'.tr(),
                                hintStyle: const TextStyle(color: Colors.black),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 15),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.black),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => isSearchExpanded = false);
                                  },
                                ),
                              ),
                            ),
                          )
                        : Text(
                            "Favorites".tr(),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                  ),
                  IconButton(
                    icon: Icon(
                      isSearchExpanded ? Icons.search_off : Icons.search,
                      color: Colors.black,
                    ),
                    onPressed: () {
                      setState(() {
                        isSearchExpanded = !isSearchExpanded;
                        if (!isSearchExpanded) _searchController.clear();
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune, color: Colors.black),
                    onPressed: _toggleSidebar,
                  ),
                ],
              ),
              if (!isSearchExpanded) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredFavourites.length} ${'items'.tr()}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            sortAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: Colors.black,
                            size: 20,
                          ),
                          onPressed: () => _sortItems(!sortAscending),
                        ),
                        Text(
                          sortAscending
                              ? 'Low to High'.tr()
                              : 'High to Low'.tr(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    if (selectedCategory == null && selectedStatus == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: [
          if (selectedStatus != null && selectedStatus != 'all')
            Chip(
              label: Text(selectedStatus!.toUpperCase()),
              onDeleted: () {
                setState(() {
                  selectedStatus = null;
                  _filterFavourites();
                });
              },
              backgroundColor: pkColor.withOpacity(0.1),
              deleteIconColor: pkColor,
            ),
          if (selectedCategory != null && selectedCategory != 'all')
            Chip(
              label: Text(categories
                  .firstWhere(
                      (c) => c.categoryId.toString() == selectedCategory,
                      orElse: () => CategoryModel(
                          categoryId: 0,
                          name: 'Unknown',
                          description: '',
                          subCategories: [],
                          products: []))
                  .name),
              onDeleted: () {
                setState(() {
                  selectedCategory = null;
                  _filterFavourites();
                });
              },
              backgroundColor: pkColor.withOpacity(0.1),
              deleteIconColor: pkColor,
            ),
          if (selectedCategory != null || selectedStatus != null)
            TextButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.clear_all, size: 18),
              label: Text('Clear All'.tr()),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [pkColor.withOpacity(0.1), pkColor.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune, color: pkColor, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Filters'.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: pkColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _toggleSidebar,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildFilterSection(
                    title: 'Status'.tr(),
                    icon: Icons.new_releases,
                    children: [
                      _buildFilterOption(
                        title: 'All'.tr(),
                        isSelected:
                            selectedStatus == null || selectedStatus == 'all',
                        onTap: () {
                          setState(() {
                            selectedStatus = null;
                            _filterFavourites();
                          });
                        },
                      ),
                      _buildFilterOption(
                        title: 'New'.tr(),
                        isSelected: selectedStatus == 'new',
                        onTap: () {
                          setState(() {
                            selectedStatus = 'new';
                            _filterFavourites();
                          });
                        },
                      ),
                      _buildFilterOption(
                        title: 'Used'.tr(),
                        isSelected: selectedStatus == 'used',
                        onTap: () {
                          setState(() {
                            selectedStatus = 'used';
                            _filterFavourites();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFilterSection(
                    title: 'Categories'.tr(),
                    icon: Icons.category,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: TextField(
                          controller: _categorySearchController,
                          decoration: InputDecoration(
                            hintText: 'Search categories...'.tr(),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      ExpansionTile(
                        title: Text(
                          'Select Category'.tr(),
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: [
                          _buildFilterOption(
                            title: 'All Categories'.tr(),
                            isSelected: selectedCategory == null ||
                                selectedCategory == 'all',
                            onTap: () {
                              setState(() {
                                selectedCategory = null;
                                _filterFavourites();
                              });
                            },
                          ),
                          if (filteredCategories.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'No categories found'.tr(),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            )
                          else
                            ...filteredCategories.map((category) {
                              return _buildFilterOption(
                                title: category.name,
                                isSelected: selectedCategory ==
                                    category.categoryId.toString(),
                                onTap: () {
                                  setState(() {
                                    selectedCategory =
                                        category.categoryId.toString();
                                    _filterFavourites();
                                  });
                                },
                              );
                            }).toList(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all),
                  label: Text('Clear All Filters'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: pkColor, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildFilterOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? pkColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: isSelected
                  ? Border.all(color: pkColor.withOpacity(0.3))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? pkColor : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? pkColor : Colors.grey[700],
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No favorites available'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Items you favorite will appear here'.tr(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: fetchFavourites,
            icon: const Icon(Icons.refresh),
            label: Text('Refresh'.tr()),
            style: ElevatedButton.styleFrom(
              backgroundColor: pkColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return RefreshIndicator(
      onRefresh: fetchFavourites,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StaggeredGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: List.generate(
            filteredFavourites.length,
            (index) => StaggeredGridTile.fit(
              crossAxisCellCount: 1,
              child: _buildProductCard(context, index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: StaggeredGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: List.generate(
          6,
          (index) => StaggeredGridTile.fit(
            crossAxisCellCount: 1,
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, int index) {
    final item = filteredFavourites[index];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductPage(product: item)),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..scale(isRemoving ? 0.95 : 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                      ),
                      child: item.images.isNotEmpty
                          ? Image.network(
                              item.images[0],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: pkColor,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, _) => Image.asset(
                                defaultProductImage,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              defaultProductImage,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: item.isNew
                              ? Color(0xff4CAF50)
                              : Color(0xff607D8B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item.isNew! ? 'NEW' : 'USED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: isRemoving ? Colors.grey : Colors.red,
                            size: 20,
                          ),
                          onPressed:
                              isRemoving ? null : () => _removeFavourite(index),
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              height: 1.3,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: pkColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "₹${item.price}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: pkColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  "4.5",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Colors.amber[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return AnimatedOpacity(
      opacity: isRemoving ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: FloatingActionButton.extended(
        onPressed: isRemoving ? null : _removeAllFavourites,
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        icon: Icon(
          Icons.delete_sweep,
          color: pkColor,
          size: 24,
        ),
        label: Text(
          "Remove All".tr(),
          style: TextStyle(
            color: pkColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
