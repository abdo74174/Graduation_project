import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/screens/product_page.dart';
import 'package:graduation_project/services/Favourites/favourites_service.dart';
import 'package:graduation_project/services/Server/server_status_service.dart';
import 'package:easy_localization/easy_localization.dart'; // Add this import

class FavouritePage extends StatefulWidget {
  const FavouritePage({super.key});

  @override
  State<FavouritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavouritePage> {
  List<ProductModel> favourites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavourites();
  }

  // Fetch favourites from the API or use dummy data if offline
  Future<void> fetchFavourites() async {
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
            isLoading = false;
          });
        } else {
          Fluttertoast.showToast(msg: "Failed to load favourites");
          setState(() {
            favourites = []; // Empty list in case of failure
            isLoading = false;
          });
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "Error loading favourites.");
        setState(() {
          favourites = []; // Empty list in case of error
          isLoading = false;
        });
      }
    } else {
      if (mounted) return;
      setState(() {
        favourites = dummyProducts; // Assuming you have dummyProducts
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('You are offline. Showing dummy favourites.').tr()),
      );
    }
  }

  // Remove product from favourites
  void _removeFavourite(int index) async {
    final product = favourites[index];
    try {
      await FavouritesService().removeFromFavourites(product.productId);
      setState(() {
        favourites.removeAt(index);
      });
      Fluttertoast.showToast(msg: "Removed from favourites".tr());
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to remove".tr());
    }
  }

  // Sort items based on price
  void _sortItems(bool ascending) {
    setState(() {
      favourites.sort((a, b) =>
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
        leading: PopupMenuButton<String>(
          icon: const Icon(Icons.sort, color: Colors.white),
          onSelected: (value) {
            if (value == 'low_to_high') {
              _sortItems(true);
            } else {
              _sortItems(false);
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem(
              value: 'low_to_high',
              child: Text('Price: Low to High'.tr()),
            ),
            PopupMenuItem(
              value: 'high_to_low',
              child: Text('Price: High to Low'.tr()),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favourites.isEmpty
              ? Center(child: Text('No favorites available'.tr()))
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GridView.builder(
                    itemCount: favourites.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      final item = favourites[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to the product page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductPage(
                                product: item,

                                // Pass the product ID
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: item.images.isNotEmpty
                                              ? Image.network(
                                                  item.images[0],
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error,
                                                          _) =>
                                                      Image.asset(
                                                          'assets/images/placeholder.png'),
                                                )
                                              : Image.asset(
                                                  defaultProductImage,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, error,
                                                          _) =>
                                                      Image.asset(
                                                          'assets/images/placeholder.png'),
                                                )),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => _removeFavourite(index),
                                        child: const Icon(Icons.favorite,
                                            color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0, vertical: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
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
      backgroundColor: const Color(0xFFF5F5F5),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: pkColor,
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: Text(
            "Remove All Favorites".tr(),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
