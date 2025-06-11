import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/product_page.dart';
import 'package:graduation_project/services/Favourites/favourites_service.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:easy_localization/easy_localization.dart';

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavouritePage> {
  List<ProductModel> favourites = [];
  List<ProductModel> filteredFavourites = [];
  bool isLoading = true;
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
          _showErrorToast("Failed to load favourites".tr());
          setState(() {
            favourites = [];
            filteredFavourites = [];
            isLoading = false;
          });
        }
      } catch (e) {
        _showErrorToast("Error loading favourites.".tr());
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
      ),
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title.tr()),
            content: Text(message.tr()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel'.tr(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Confirm'.tr(),
                  style: const TextStyle(color: pkColor),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _removeFavourite(int index) async {
    final confirmed = await _showConfirmationDialog(
      'Remove Item',
      'Are you sure you want to remove this item from favourites?',
    );
    if (!confirmed) return;

    final product = filteredFavourites[index];
    try {
      final response =
          await FavouritesService().removeFromFavourites(product.productId);
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 204)) {
        setState(() {
          favourites.removeWhere((p) => p.productId == product.productId);
          filteredFavourites.removeAt(index);
        });
        _showSuccessToast("Removed from favourites".tr());
      } else {
        _showErrorToast("Failed to remove".tr());
      }
    } catch (e) {
      _showErrorToast("Error removing favourite.".tr());
    }
  }

  Future<void> _removeAllFavourites() async {
    if (favourites.isEmpty) {
      _showErrorToast("No favourites to remove".tr());
      return;
    }

    final confirmed = await _showConfirmationDialog(
      'Remove All',
      'Are you sure you want to remove all items from favourites?',
    );
    if (!confirmed) return;

    try {
      final response = await FavouritesService().removeALLFromFavourites();
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 204)) {
        setState(() {
          favourites.clear();
          filteredFavourites.clear();
        });
        _showSuccessToast("All favourites removed".tr());
      } else {
        _showErrorToast("Failed to remove all favourites".tr());
      }
    } catch (e) {
      _showErrorToast("Error removing all favourites.".tr());
    }
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
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
        backgroundColor: const Color(0xFF134FAF),
        title: Text("Favorites".tr(),
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search favourites...'.tr(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
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
                        style:
                            const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchFavourites,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: GridView.builder(
                      itemCount: filteredFavourites.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        final item = filteredFavourites[index];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductPage(product: item),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(12)),
                                        child: item.images.isNotEmpty
                                            ? Image.network(
                                                item.images[0],
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                errorBuilder: (context, error,
                                                        _) =>
                                                    Image.asset(
                                                        'assets/images/placeholder.png'),
                                              )
                                            : Image.asset(
                                                defaultProductImage,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: IconButton(
                                          icon: const Icon(Icons.favorite,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _removeFavourite(index),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "₹${item.price}",
                                        style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
      floatingActionButton: favourites.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _removeAllFavourites,
              backgroundColor: pkColor,
              icon: const Icon(Icons.delete),
              label: Text("Remove All".tr()),
            )
          : null,
    );
  }
}
