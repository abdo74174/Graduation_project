import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/Favourites/favourites_service.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget({super.key, required this.image, required this.productId});
  final String image;
  final int productId;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  bool isFavourite = false;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _checkIfFavourite();
  }

  void _checkIfFavourite() {
    // Check local cache first
    final cachedFav = _prefs.getBool('fav_${widget.productId}');
    if (cachedFav != null) {
      setState(() => isFavourite = cachedFav);
    }
    _checkServerFavourite();
  }

  void _checkServerFavourite() async {
    try {
      final response = await FavouritesService().getFavourites();
      if (response?.statusCode == 200) {
        final isInFavorites = (response!.data as List)
            .any((favourite) => favourite['productId'] == widget.productId);

        // Update both state and local cache
        _prefs.setBool('fav_${widget.productId}', isInFavorites);
        setState(() => isFavourite = isInFavorites);
      }
    } catch (e) {
      // Offline: Keep cached value
      print('Using cached favorite status: $isFavourite');
    }
  }

  void _toggleFavoriteStatus() async {
    final newStatus = !isFavourite;
    // Update UI and cache immediately
    setState(() => isFavourite = newStatus);
    _prefs.setBool('fav_${widget.productId}', newStatus);

    try {
      if (newStatus) {
        await FavouritesService().addToFavourites(widget.productId);
      } else {
        await FavouritesService().removeFromFavourites(widget.productId);
      }
    } catch (e) {
      print('Sync failed: $e');
      showSnackbar(context, "Changes will sync when online");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ... keep your existing image code ...,
        Positioned(
          right: 16,
          top: 40,
          child: IconButton(
            icon: Icon(
              Icons.favorite,
              color: isFavourite ? Colors.red : Colors.white,
              size: 40,
            ),
            onPressed: _toggleFavoriteStatus,
          ),
        ),
        Positioned(
          left: 16,
          top: 40,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to show snackbar
  void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
