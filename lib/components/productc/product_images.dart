import 'package:flutter/material.dart';
import 'package:graduation_project/core/constants/constant.dart';
import 'package:graduation_project/core/constants/dummy_static_data.dart';
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
    print("============================");
    print(widget.image.isEmpty);
    print(widget.image.length);
    print(defaultProductImage.isEmpty);
    print("============================");
    super.initState();
    _checkIfFavourite();
  }

  // Check if the product is in favorites
  void _checkIfFavourite() async {
    try {
      final response = await FavouritesService().getFavourites();
      print("Favourites Response: ${response?.data}");
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
      print("Toggling favorite status: $isFavourite");
      if (isFavourite) {
        final response =
            await FavouritesService().removeFromFavourites(widget.productId);
        print("Remove Response: ${response?.statusCode}");
        if (response?.statusCode == 200) {
          setState(() {
            isFavourite = false;
          });
          showSnackbar(context, "Removed from Favorites");
        } else {
          showSnackbar(context, "Failed to remove from Favorites");
        }
      } else {
        final response =
            await FavouritesService().addToFavourites(widget.productId);
        print("Add Response: ${response?.statusCode}");
        if (response?.statusCode == 200) {
          setState(() {
            isFavourite = true;
          });
          showSnackbar(context, "Added to Favorites");
        } else {
          showSnackbar(context, "Failed to add to Favorites");
        }
      }
    } catch (e) {
      print("Error during toggle favorite status: $e");
      showSnackbar(context, "Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    print("Image URL: ${widget.image}");

    return Stack(
      children: [
        SizedBox(
          width: screenWidth,
          height: 400,
          child: widget.image.length > 1 // More generic check
              ? Image.network(
                  widget.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print("Error loading image: $error");
                    print("Stack Trace: $stackTrace");
                    return Image.asset("assets/images/heart 1.jpg",
                        fit: BoxFit.cover);
                  },
                )
              : Image.asset(
                  defaultProductImage,
                  fit: BoxFit.cover,
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
