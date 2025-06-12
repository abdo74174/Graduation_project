import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/product_page.dart';
import 'package:graduation_project/services/Favourites/favourites_service.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavouritePage> {
  List<ProductModel> favourites = [];
  List<ProductModel> filteredFavourites = [];
  bool isLoading = true;
  bool isRemoving = false;
  bool isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchFavourites();
    _searchController.addListener(_filterFavourites);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFavourites() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredFavourites = favourites.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.description.toLowerCase().contains(query);
      }).toList();
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
          final List<ProductModel> loaded = (response.data as List)
              .map((json) => ProductModel.fromJson(json['product']))
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
        content: Text('You are offline. Showing dummy favourites.').tr(),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        backgroundColor: Theme.of(context).colorScheme.error,
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
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title:
                Text(title.tr(), style: Theme.of(context).textTheme.titleLarge),
            content: Text(message.tr(),
                style: Theme.of(context).textTheme.bodyMedium),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel'.tr(),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Confirm'.tr(),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _removeFavourite(int index) async {
    if (isRemoving || index < 0 || index >= filteredFavourites.length) {
      debugPrint(
          "Invalid index or removal in progress: index=$index, length=${filteredFavourites.length}");
      return;
    }

    setState(() => isRemoving = true);
    final product =
        filteredFavourites[index]; // Store product to avoid index issues
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
      debugPrint("Error removing favourite: $e");
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
      filteredFavourites.sort((a, b) =>
          ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                pkColor,
                Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: isSearchExpanded
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search favourites...'.tr(),
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => isSearchExpanded = false);
                    },
                  ),
                ),
              )
            : Text(
                "Favorites".tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isSearchExpanded ? Icons.search_off : Icons.search,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                isSearchExpanded = !isSearchExpanded;
                if (!isSearchExpanded) _searchController.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.arrow_upward),
                      title: Text('Price: Low to High'.tr()),
                      onTap: () {
                        _sortItems(true);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.arrow_downward),
                      title: Text('Price: High to Low'.tr()),
                      onTap: () {
                        _sortItems(false);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16), // Add spacing below AppBar
            Expanded(
              child: isLoading
                  ? _buildShimmerGrid()
                  : filteredFavourites.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.favorite_border,
                                  size: 60, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'No favorites available'.tr(),
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.grey,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: fetchFavourites,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: favourites.isNotEmpty
          ? AnimatedOpacity(
              opacity: isRemoving ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: FloatingActionButton.extended(
                onPressed: isRemoving ? null : _removeAllFavourites,
                backgroundColor: Colors.white,
                elevation: 8,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                icon: Icon(
                  Icons.delete,
                  color: pkColor,
                ),
                label: Text(
                  "Remove All".tr(),
                  style: TextStyle(color: pkColor),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                height: 250,
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
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      child: item.images.isNotEmpty
                          ? Image.network(
                              item.images[0],
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                );
                              },
                              errorBuilder: (context, error, _) => Image.asset(
                                'assets/images/placeholder.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              defaultProductImage,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: isRemoving ? Colors.grey : Colors.red,
                        ),
                        onPressed:
                            isRemoving ? null : () => _removeFavourite(index),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
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
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            "₹${item.price}",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Spacer(),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            "4.5", // Replace with item.rating if available
                            style: Theme.of(context).textTheme.bodySmall,
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
}
