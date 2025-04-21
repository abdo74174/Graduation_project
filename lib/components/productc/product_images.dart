import 'package:flutter/material.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/services/Favourites/favourites_service.dart'; // Import the Favourites Service

class ImageWidget extends StatefulWidget {
  const ImageWidget({super.key, required this.image, required this.productId});
  final String image;
  final int productId; // Pass the product ID

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  bool isFavourite = false;

  // Fetch the current state of the favorite when the widget is initialized
  @override
  void initState() {
    super.initState();
    _checkIfFavourite();
  }

  // Check if the product is in favorites
  void _checkIfFavourite() async {
    try {
      final response = await FavouritesService().getFavourites();
      if (response != null && response.statusCode == 200) {
        final favouritesList = response.data as List;
        final isInFavorites = favouritesList.any((favourite) =>
            favourite['productId'] ==
            widget.productId); // Check if productId is in the list of favorites
        setState(() {
          isFavourite = isInFavorites;
        });
      }
    } catch (e) {
      print('Error checking if product is in favorites: $e');
    }
  }

  // Add or remove from Favorites function
  void _toggleFavoriteStatus() async {
    try {
      if (isFavourite) {
        // Remove from Favorites
        final response =
            await FavouritesService().removeFromFavourites(widget.productId);
        if (response?.statusCode == 200) {
          setState(() {
            isFavourite =
                false; // Mark as not a favourite after successful removal
          });
          showSnackbar(context, "Removed from Favorites");
        } else {
          showSnackbar(context, "Failed to remove from Favorites");
        }
      } else {
        // Add to Favorites
        final response =
            await FavouritesService().addToFavourites(widget.productId);
        if (response?.statusCode == 200) {
          setState(() {
            isFavourite = true; // Mark as favourite after successful addition
          });
          showSnackbar(context, "Added to Favorites");
        } else {
          showSnackbar(context, "Failed to add to Favorites");
        }
      }
    } catch (e) {
      print(e);
      showSnackbar(context, "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        SizedBox(
          width: screenWidth,
          height: 400,
          child: Image.network(
            widget.image.isNotEmpty
                ? widget.image
                : 'https://via.placeholder.com/400',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print("Error loading image: $error");
              return Image.asset("assets/images/heart 1.jpg",
                  fit: BoxFit.cover);
            },
          ),
        ),
        Positioned(
          right: 16,
          top: 40,
          child: IconButton(
            icon: Icon(
              Icons.favorite,
              color: isFavourite ? Colors.red : Colors.white,
              size: 40,
            ),
            onPressed: _toggleFavoriteStatus, // Toggle the favorite status
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
