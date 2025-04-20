import 'package:flutter/material.dart';
import 'package:graduation_project/core/constants/constant.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget({super.key, required this.image});
  final String image;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  bool isFavourite = false;

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
            onPressed: () {
              showSnackbar(context, "Added To FAV Successfully");
              setState(() {
                isFavourite = !isFavourite;
              });
            },
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
}
