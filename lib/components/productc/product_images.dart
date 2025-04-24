import 'package:flutter/material.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/Favourites/favourites_service.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget({
    super.key,
    required this.image,
    required this.productId,
  });
  final String image;
  final int productId;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  bool isFavourite = false;
  late SharedPreferences _prefs;
  bool _isPrefsInitialized = false;
  bool _isImageError = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() => _isPrefsInitialized = true);
        _checkIfFavourite();
      }
    } catch (e) {
      print("Error initializing preferences: $e");
      if (mounted) setState(() => _isPrefsInitialized = false);
    }
  }

  void _checkIfFavourite() {
    if (!_isPrefsInitialized) return;

    final cachedFav = _prefs.getBool('fav_${widget.productId}');
    if (cachedFav != null && mounted) setState(() => isFavourite = cachedFav);
    _checkServerFavourite();
  }

  void _checkServerFavourite() async {
    try {
      final response = await FavouritesService().getFavourites();
      if (response?.statusCode == 200 && mounted) {
        final isInFavorites = (response!.data as List)
            .any((favourite) => favourite['productId'] == widget.productId);

        await _prefs.setBool('fav_${widget.productId}', isInFavorites);
        if (mounted) setState(() => isFavourite = isInFavorites);
      }
    } catch (e) {
      print('Using cached favorite status: $isFavourite');
    }
  }

  void _toggleFavoriteStatus() {
    if (!_isPrefsInitialized) return;

    final newStatus = !isFavourite;
    setState(() => isFavourite = newStatus);
    _prefs.setBool('fav_${widget.productId}', newStatus);
    _syncWithServer(newStatus);
  }

  Future<void> _syncWithServer(bool newStatus) async {
    try {
      if (newStatus) {
        await FavouritesService().addToFavourites(widget.productId);
      } else {
        await FavouritesService().removeFromFavourites(widget.productId);
      }
    } catch (e) {
      print('Sync failed: $e');
      if (mounted) showSnackbar("Changes will sync when online");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // Main Image
        SizedBox(
          width: screenWidth,
          height: 400,
          child: _isImageError
              ? Image.asset(defaultProductImage, fit: BoxFit.cover)
              : Image.network(
                  widget.image,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) setState(() => _isImageError = true);
                    });
                    return Image.asset(defaultProductImage, fit: BoxFit.cover);
                  },
                ),
        ),

        // Favorite Icon with Border
        Positioned(
          right: 16,
          top: 40,
          child: Material(
            // Use Material to get the ripple (ink splash) effect
            color: Colors.transparent,
            shape: CircleBorder(),
            child: InkWell(
              customBorder: CircleBorder(),
              onTap: _toggleFavoriteStatus,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 250),
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Color(0xFFFFCDD2), // فاتح أحمر (light red)
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white, // crisp white border
                    width: 3, // thicker border for contrast
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.favorite,
                  color: isFavourite ? Colors.redAccent : Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),

        // Back Button
        Positioned(
          left: 16,
          top: 40,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.pop(context),
              splashColor: Colors.white24,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8), // generous tap area
                decoration: BoxDecoration(
                  color:
                      pkColor, // Teal-blue background :contentReference[oaicite:0]{index=0}
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors
                        .white, // crisp white border for 3:1 contrast :contentReference[oaicite:1]{index=1}
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: pkColor,
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 24,
                  color: Colors
                      .white, // white icon ensures 3:1 non-text contrast :contentReference[oaicite:2]{index=2}
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
