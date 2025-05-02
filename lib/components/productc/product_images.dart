import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/Favourites/favourites_service.dart';
import 'package:shimmer/shimmer.dart';

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

class _ImageWidgetState extends State<ImageWidget> with SingleTickerProviderStateMixin {
  bool isFavourite = false;
  late SharedPreferences _prefs;
  bool _isPrefsInitialized = false;
  bool _isImageError = false;
  late AnimationController _favAnimationController;
  late Animation<double> _favScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initPrefs();
    _initAnimation();
  }

  void _initAnimation() {
    _favAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _favScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _favAnimationController, curve: Curves.easeInOut),
    );
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

    HapticFeedback.lightImpact();
    _favAnimationController.forward().then((_) => _favAnimationController.reverse());

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
  void dispose() {
    _favAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Main Image with Gradient Overlay
        Container(
          width: screenWidth,
          height: screenHeight * 0.5,
          decoration: BoxDecoration(
            image: _isImageError
                ? const DecorationImage(
              image: AssetImage(defaultProductImage),
              fit: BoxFit.cover,
            )
                : null,
          ),
          child: _isImageError
              ? null
              : Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.image,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.grey[300]),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _isImageError = true);
                  });
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  );
                },
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Favorite Button
        Positioned(
          right: 16,
          top: MediaQuery.of(context).padding.top + 16,
          child: ScaleTransition(
            scale: _favScaleAnimation,
            child: GestureDetector(
              onTap: _toggleFavoriteStatus,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Icon(
                  isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: isFavourite ? Colors.redAccent : Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ),

        // Back Button
        Positioned(
          left: 16,
          top: MediaQuery.of(context).padding.top + 16,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
                // Glassmorphism effect
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 24,
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
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black87,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }
}