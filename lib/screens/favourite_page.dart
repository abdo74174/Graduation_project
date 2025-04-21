import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:graduation_project/Models/product_model.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/Favourites/favourites_service.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<ProductModel> favourites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFavourites();
  }

  // Fetch favourites from the API
  Future<void> fetchFavourites() async {
    try {
      final response = await FavouritesService()
          .getFavourites(); // Assume this returns a Response from Dio
      if (response != null && response.statusCode == 200) {
        final List<ProductModel> loaded = (response.data as List)
            .map((json) => ProductModel.fromJson(json[
                'product'])) // Assuming the response contains a 'product' field
            .toList();

        setState(() {
          favourites = loaded;
          isLoading = false;
        });
      } else {
        Fluttertoast.showToast(msg: "Failed to load favourites");
      }
    } catch (e) {
      print('Error fetching favourites: $e');
      Fluttertoast.showToast(msg: "Error loading favourites.");
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
      Fluttertoast.showToast(msg: "Removed from favourites");
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to remove");
    }
  }

  // Remove all favorites
  // void _removeAllFavorites() async {
  //   try {
  //     await FavouritesService().();
  //     setState(() {
  //       favourites.clear(); // Clear local list
  //     });
  //     Fluttertoast.showToast(msg: "All favourites removed");
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: "Failed to remove all favourites");
  //   }
  // }

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
        title: const Text("Favorites",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
          itemBuilder: (BuildContext context) => const [
            PopupMenuItem(
              value: 'low_to_high',
              child: Text('Price: Low to High'),
            ),
            PopupMenuItem(
              value: 'high_to_low',
              child: Text('Price: High to Low'),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favourites.isEmpty
              ? const Center(child: Text("No favorites available."))
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
                      return Container(
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
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        item.images[
                                            0], // Update to use the first image
                                        fit: BoxFit.contain,
                                        errorBuilder: (context, error, _) =>
                                            Image.asset(
                                                'assets/images/placeholder.png'),
                                      ),
                                    ),
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
            backgroundColor: pkColor, // Red color for the button
            padding: const EdgeInsets.symmetric(vertical: 15),
          ),
          child: const Text(
            "Remove All Favorites",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
